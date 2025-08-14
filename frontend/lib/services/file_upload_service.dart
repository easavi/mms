import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:watcher/watcher.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/media_service.dart';

/// Represents a file upload item in the queue
class UploadItem {
  final String id;
  final String filePath;
  final String fileName;
  final String mediaType;
  final String storageId;
  final DateTime addedAt;
  
  UploadStatus status;
  double progress;
  String? errorMessage;
  String? mediaId;
  
  UploadItem({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.mediaType,
    required this.storageId,
    required this.addedAt,
    this.status = UploadStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
    this.mediaId,
  });
}

enum UploadStatus {
  pending,
  uploading,
  completed,
  failed,
  cancelled,
}

/// Service for monitoring storage folders and automatically uploading files
class FileUploadService extends ChangeNotifier {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  final StorageService _storageService = StorageService();
  final MediaService _mediaService = MediaService();
  
  // File watchers for each storage path
  final Map<String, StreamSubscription<WatchEvent>> _watchers = {};
  
  // Queue management
  final Queue<UploadItem> _uploadQueue = Queue<UploadItem>();
  final Map<String, UploadItem> _uploadItems = {};
  final Set<String> _processedFiles = <String>{};
  
  // Service state
  bool _isRunning = false;
  bool _isProcessingQueue = false;
  int _concurrentUploads = 0;
  static const int _maxConcurrentUploads = 3;
  
  // Supported file extensions
  final Set<String> _supportedExtensions = {
    // Images
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg',
    // Videos
    '.mp4', '.avi', '.mov', '.wmv', '.flv', '.webm', '.mkv', '.3gp',
    // Audio
    '.mp3', '.wav', '.flac', '.aac', '.ogg',
    // Documents
    '.pdf', '.doc', '.docx', '.txt', '.rtf',
  };

  // Getters
  bool get isRunning => _isRunning;
  int get pendingUploads => _uploadQueue.length;
  int get totalUploads => _uploadItems.length;
  List<UploadItem> get uploadItems => _uploadItems.values.toList();
  List<UploadItem> get failedUploads => 
      _uploadItems.values.where((item) => item.status == UploadStatus.failed).toList();

  /// Start the file upload service
  Future<void> start() async {
    if (_isRunning) return;
    
    debugPrint('🎧 Starting File Upload Service...');
    _isRunning = true;
    
    try {
      // Load all enabled storage configurations
      final storages = await _storageService.getAllStorage();
      final enabledStorages = storages.where((storage) => storage.isEnabled).toList();
      
      debugPrint('Found ${enabledStorages.length} enabled storage paths');
      
      // Start monitoring each enabled storage path
      for (final storage in enabledStorages) {
        await _startMonitoringStorage(storage);
      }
      
      // Start processing the upload queue
      _startQueueProcessor();
      
      debugPrint('✅ File Upload Service started successfully');
    } catch (e) {
      debugPrint('❌ Failed to start File Upload Service: $e');
      _isRunning = false;
      rethrow;
    }
    
    notifyListeners();
  }

  /// Stop the file upload service
  Future<void> stop() async {
    if (!_isRunning) return;
    
    debugPrint('🛑 Stopping File Upload Service...');
    _isRunning = false;
    
    // Stop all watchers
    for (final subscription in _watchers.values) {
      await subscription.cancel();
    }
    _watchers.clear();
    
    // Cancel pending uploads
    final pendingItems = _uploadItems.values
        .where((item) => item.status == UploadStatus.pending || item.status == UploadStatus.uploading)
        .toList();
    
    for (final item in pendingItems) {
      item.status = UploadStatus.cancelled;
    }
    
    _uploadQueue.clear();
    _isProcessingQueue = false;
    _concurrentUploads = 0;
    
    debugPrint('✅ File Upload Service stopped');
    notifyListeners();
  }

  /// Add a storage path to monitor
  Future<void> addStorageMonitoring(Storage storage) async {
    if (!_isRunning || !storage.isEnabled) return;
    
    await _startMonitoringStorage(storage);
    notifyListeners();
  }

  /// Remove storage path monitoring
  Future<void> removeStorageMonitoring(String storageId) async {
    if (_watchers.containsKey(storageId)) {
      await _watchers[storageId]!.cancel();
      _watchers.remove(storageId);
      
      // Cancel any pending uploads for this storage
      final itemsToCancel = _uploadItems.values
          .where((item) => item.storageId == storageId && 
                          (item.status == UploadStatus.pending || item.status == UploadStatus.uploading))
          .toList();
      
      for (final item in itemsToCancel) {
        item.status = UploadStatus.cancelled;
        _uploadQueue.remove(item);
      }
      
      debugPrint('🗑️ Stopped monitoring storage: $storageId');
    }
    
    notifyListeners();
  }

  /// Retry a failed upload
  Future<void> retryUpload(String uploadId) async {
    final item = _uploadItems[uploadId];
    if (item == null || item.status != UploadStatus.failed) return;
    
    item.status = UploadStatus.pending;
    item.progress = 0.0;
    item.errorMessage = null;
    
    _uploadQueue.add(item);
    
    if (!_isProcessingQueue) {
      _startQueueProcessor();
    }
    
    notifyListeners();
  }

  /// Clear completed and failed uploads from history
  void clearHistory() {
    final itemsToRemove = _uploadItems.entries
        .where((entry) => entry.value.status == UploadStatus.completed || 
                         entry.value.status == UploadStatus.failed ||
                         entry.value.status == UploadStatus.cancelled)
        .map((entry) => entry.key)
        .toList();
    
    for (final id in itemsToRemove) {
      _uploadItems.remove(id);
    }
    
    notifyListeners();
  }

  /// Start monitoring a specific storage path
  Future<void> _startMonitoringStorage(Storage storage) async {
    if (_watchers.containsKey(storage.id)) return;
    
    final directory = Directory(storage.path);
    if (!directory.existsSync()) {
      debugPrint('⚠️ Storage directory does not exist: ${storage.path}');
      return;
    }
    
    debugPrint('📂 Starting to monitor: ${storage.path}');
    
    // Scan existing files first
    await _scanExistingFiles(storage);
    
    // Start watching for new files (desktop only)
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      try {
        final watcher = DirectoryWatcher(storage.path);
        final subscription = watcher.events.listen(
          (event) => _handleFileSystemEvent(event, storage),
          onError: (error) => debugPrint('❌ Watcher error for ${storage.path}: $error'),
        );
        
        _watchers[storage.id] = subscription;
        debugPrint('✅ File watcher started for: ${storage.path}');
      } catch (e) {
        debugPrint('❌ Failed to start watcher for ${storage.path}: $e');
      }
    } else {
      debugPrint('⚠️ File monitoring not supported on this platform');
    }
  }

  /// Scan existing files in a directory and upload them
  Future<void> _scanExistingFiles(Storage storage) async {
    try {
      final directory = Directory(storage.path);
      int existingFilesCount = 0;
      int queuedForUploadCount = 0;
      
      // Get all media items once before checking files
      debugPrint('🔍 Fetching existing media items to check against...');
      final mediaItems = await _mediaService.getAllMedia();
      final existingFileNames = mediaItems.map((item) => item.fileName).toSet();
      debugPrint('📊 Found ${existingFileNames.length} existing files in backend');
      
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File && _shouldProcessFile(entity.path)) {
          existingFilesCount++;
          
          // Check if file already exists in backend
          final fileName = path.basename(entity.path);
          final fileExists = existingFileNames.contains(fileName);
          
          if (!fileExists) {
            // File doesn't exist in backend, add to upload queue
            debugPrint('📤 Queuing existing file for upload: $fileName');
            _addToUploadQueue(entity.path, storage);
            queuedForUploadCount++;
          } else {
            debugPrint('✅ File already exists in backend: $fileName');
          }
          
          _processedFiles.add(entity.path);
        }
      }
      
      debugPrint('📁 Scanned $existingFilesCount existing files in ${storage.path}');
      if (queuedForUploadCount > 0) {
        debugPrint('📤 Queued $queuedForUploadCount existing files for upload');
      }
    } catch (e) {
      debugPrint('❌ Error scanning directory ${storage.path}: $e');
    }
  }

  /// Handle file system events
  void _handleFileSystemEvent(WatchEvent event, Storage storage) {
    if (event.type == ChangeType.ADD) {
      final filePath = event.path;
      
      if (_shouldProcessFile(filePath) && !_processedFiles.contains(filePath)) {
        debugPrint('📝 New file detected: ${path.basename(filePath)}');
        _addToUploadQueue(filePath, storage);
        _processedFiles.add(filePath);
      }
    }
  }

  /// Check if a file should be processed
  bool _shouldProcessFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return _supportedExtensions.contains(extension);
  }

  /// Add a file to the upload queue
  void _addToUploadQueue(String filePath, Storage storage) {
    final fileName = path.basename(filePath);
    final mediaType = _determineMediaType(filePath);
    final uploadId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final uploadItem = UploadItem(
      id: uploadId,
      filePath: filePath,
      fileName: fileName,
      mediaType: mediaType,
      storageId: storage.id,
      addedAt: DateTime.now(),
    );
    
    _uploadItems[uploadId] = uploadItem;
    _uploadQueue.add(uploadItem);
    
    debugPrint('📋 Added to upload queue: $fileName (type: $mediaType)');
    
    if (!_isProcessingQueue) {
      _startQueueProcessor();
    }
    
    notifyListeners();
  }

  /// Determine media type from file extension
  String _determineMediaType(String filePath) {
    final mimeType = lookupMimeType(filePath);
    if (mimeType == null) return 'file';
    
    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('video/')) return 'video';
    if (mimeType.startsWith('audio/')) return 'audio';
    return 'file';
  }

  /// Start processing the upload queue
  void _startQueueProcessor() {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning || _uploadQueue.isEmpty) {
        if (_uploadQueue.isEmpty && _concurrentUploads == 0) {
          _isProcessingQueue = false;
          timer.cancel();
        }
        return;
      }
      
      // Process queue if we have capacity
      while (_uploadQueue.isNotEmpty && _concurrentUploads < _maxConcurrentUploads) {
        final item = _uploadQueue.removeFirst();
        _processUpload(item);
      }
    });
  }

  /// Process a single upload
  Future<void> _processUpload(UploadItem item) async {
    _concurrentUploads++;
    item.status = UploadStatus.uploading;
    notifyListeners();
    
    try {
      debugPrint('📤 Starting upload: ${item.fileName}');
      
      // Check if file still exists
      final file = File(item.filePath);
      if (!file.existsSync()) {
        throw Exception('File no longer exists: ${item.filePath}');
      }
      
      // Upload the file
      final media = await _mediaService.uploadMedia(
        filePath: item.filePath,
        title: item.fileName,
        mediaType: item.mediaType,
        description: 'Auto-uploaded by File Upload Service',
        tags: ['auto-upload', 'file-watcher'],
      );
      
      // Update item status
      item.status = UploadStatus.completed;
      item.progress = 1.0;
      item.mediaId = media.id;
      
      debugPrint('✅ Successfully uploaded: ${item.fileName} -> ID: ${media.id}');
      
      // Delete file after successful upload
      await _deleteFileAfterUpload(file);
      
    } catch (e) {
      item.status = UploadStatus.failed;
      item.errorMessage = e.toString();
      debugPrint('❌ Failed to upload ${item.fileName}: $e');
    } finally {
      _concurrentUploads--;
      notifyListeners();
    }
  }

  /// Delete file after successful upload
  Future<void> _deleteFileAfterUpload(File file) async {
    try {
      await file.delete();
      debugPrint('🗑️ Deleted uploaded file: ${file.path}');
    } catch (e) {
      debugPrint('⚠️ Failed to delete file after upload ${file.path}: $e');
    }
  }
}
