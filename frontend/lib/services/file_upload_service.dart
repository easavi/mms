import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:watcher/watcher.dart';
import 'package:mime/mime.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../models/models.dart';
import '../services/services.dart';

class FileUploadService extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final ApiService _apiService = ApiService();
  
  final Map<String, StreamSubscription> _watchers = {};
  final Map<String, Set<String>> _processedFiles = {};
  bool _isRunning = false;
  bool _isInitialized = false;
  
  // Upload queue and status tracking
  final List<UploadTask> _uploadQueue = [];
  final Map<String, UploadTask> _activeUploads = {};
  bool _isProcessingQueue = false;
  
  // Getters
  bool get isRunning => _isRunning;
  bool get isInitialized => _isInitialized;
  List<UploadTask> get uploadQueue => List.unmodifiable(_uploadQueue);
  Map<String, UploadTask> get activeUploads => Map.unmodifiable(_activeUploads);
  int get pendingUploadsCount => _uploadQueue.length + _activeUploads.length;
  
  /// Initialize the service and start monitoring storage paths
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('FileUploadService: Initializing...');
      
      // Load all user storages
      final storages = await _storageService.getAllStorage();
      debugPrint('FileUploadService: Found ${storages.length} storage(s)');
      
      // Start monitoring each enabled storage path
      for (final storage in storages) {
        if (storage.isEnabled) {
          await _startMonitoring(storage);
        }
      }
      
      _isInitialized = true;
      _isRunning = storages.any((s) => s.isEnabled);
      
      debugPrint('FileUploadService: Initialized successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('FileUploadService: Initialization failed: $e');
      rethrow;
    }
  }
  
  /// Start monitoring a specific storage path
  Future<void> _startMonitoring(Storage storage) async {
    if (kIsWeb) {
      debugPrint('FileUploadService: File monitoring not supported on web platform');
      return;
    }
    
    try {
      final directory = Directory(storage.path);
      
      if (!directory.existsSync()) {
        debugPrint('FileUploadService: Directory does not exist: ${storage.path}');
        return;
      }
      
      debugPrint('FileUploadService: Starting monitoring for: ${storage.path}');
      
      // Initialize processed files set for this storage
      _processedFiles[storage.id] = <String>{};
      
      // Scan existing files and mark them as processed
      await _scanExistingFiles(storage);
      
      // Create watcher for the directory
      final watcher = DirectoryWatcher(storage.path);
      
      final subscription = watcher.events.listen(
        (event) => _handleFileSystemEvent(storage, event),
        onError: (error) {
          debugPrint('FileUploadService: Watcher error for ${storage.path}: $error');
        },
      );
      
      _watchers[storage.id] = subscription;
      debugPrint('FileUploadService: Monitoring started for: ${storage.path}');
      
    } catch (e) {
      debugPrint('FileUploadService: Failed to start monitoring ${storage.path}: $e');
    }
  }
  
  /// Scan existing files in directory to avoid re-uploading them
  Future<void> _scanExistingFiles(Storage storage) async {
    try {
      final directory = Directory(storage.path);
      final files = directory.listSync(recursive: true).whereType<File>();
      
      for (final file in files) {
        if (_isMediaFile(file.path)) {
          _processedFiles[storage.id]?.add(file.path);
        }
      }
      
      debugPrint('FileUploadService: Marked ${_processedFiles[storage.id]?.length ?? 0} existing files as processed');
    } catch (e) {
      debugPrint('FileUploadService: Error scanning existing files: $e');
    }
  }
  
  /// Handle file system events
  void _handleFileSystemEvent(Storage storage, WatchEvent event) {
    if (event.type == ChangeType.ADD) {
      _handleNewFile(storage, event.path);
    } else if (event.type == ChangeType.REMOVE) {
      _handleDeletedFile(storage, event.path);
    }
  }
  
  /// Handle new file detection
  void _handleNewFile(Storage storage, String filePath) {
    // Check if file was already processed
    if (_processedFiles[storage.id]?.contains(filePath) == true) {
      return;
    }
    
    // Check if it's a media file
    if (!_isMediaFile(filePath)) {
      return;
    }
    
    // Check if file exists and is accessible
    final file = File(filePath);
    if (!file.existsSync()) {
      return;
    }
    
    debugPrint('FileUploadService: New file detected: $filePath');
    
    // Mark as processed to avoid duplicate uploads
    _processedFiles[storage.id]?.add(filePath);
    
    // Add to upload queue
    final uploadTask = UploadTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: filePath,
      storage: storage,
      status: UploadStatus.pending,
      createdAt: DateTime.now(),
    );
    
    _uploadQueue.add(uploadTask);
    notifyListeners();
    
    // Start processing queue if not already running
    _processUploadQueue();
  }
  
  /// Handle deleted file
  void _handleDeletedFile(Storage storage, String filePath) {
    // Remove from processed files
    _processedFiles[storage.id]?.remove(filePath);
    
    // Remove from upload queue if pending
    _uploadQueue.removeWhere((task) => task.filePath == filePath);
    
    debugPrint('FileUploadService: File deleted: $filePath');
    notifyListeners();
  }
  
  /// Check if file is a supported media type
  bool _isMediaFile(String filePath) {
    final mimeType = lookupMimeType(filePath);
    if (mimeType == null) return false;
    
    return mimeType.startsWith('image/') ||
           mimeType.startsWith('video/') ||
           mimeType.startsWith('audio/') ||
           _isSupportedDocument(filePath);
  }
  
  /// Check if file is a supported document type
  bool _isSupportedDocument(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.pdf', '.doc', '.docx', '.txt', '.rtf'].contains(extension);
  }
  
  /// Process upload queue
  Future<void> _processUploadQueue() async {
    if (_isProcessingQueue || _uploadQueue.isEmpty) return;
    
    _isProcessingQueue = true;
    
    while (_uploadQueue.isNotEmpty && _activeUploads.length < 3) { // Max 3 concurrent uploads
      final task = _uploadQueue.removeAt(0);
      _activeUploads[task.id] = task;
      
      // Start upload without waiting
      _uploadFile(task).then((_) {
        _activeUploads.remove(task.id);
        notifyListeners();
        
        // Continue processing queue
        if (_uploadQueue.isNotEmpty) {
          _processUploadQueue();
        }
      });
    }
    
    _isProcessingQueue = false;
  }
  
  /// Upload a single file
  Future<void> _uploadFile(UploadTask task) async {
    try {
      task.status = UploadStatus.uploading;
      task.startedAt = DateTime.now();
      notifyListeners();
      
      final file = File(task.filePath);
      if (!file.existsSync()) {
        throw Exception('File not found: ${task.filePath}');
      }
      
      // Get file info
      final fileName = path.basename(task.filePath);
      final fileSize = file.lengthSync();
      final mimeType = lookupMimeType(task.filePath) ?? 'application/octet-stream';
      
      // Determine media type
      String mediaType;
      if (mimeType.startsWith('image/')) {
        mediaType = 'image';
      } else if (mimeType.startsWith('video/')) {
        mediaType = 'video';
      } else if (mimeType.startsWith('audio/')) {
        mediaType = 'audio';
      } else {
        mediaType = 'document';
      }
      
      // Create form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          task.filePath,
          filename: fileName,
        ),
        'title': _generateTitle(fileName),
        'mediaType': mediaType,
        'description': 'Auto-uploaded from ${task.storage.path}',
        'tags': 'auto-upload,${task.storage.bucket}',
      });
      
      // Update progress
      task.totalBytes = fileSize;
      
      // Upload file
      final response = await _apiService.uploadFile('/api/media/upload', formData);
      
      task.status = UploadStatus.completed;
      task.completedAt = DateTime.now();
      task.result = Media.fromJson(response.data);
      
      debugPrint('FileUploadService: Successfully uploaded: $fileName');
      
    } catch (e) {
      task.status = UploadStatus.failed;
      task.error = e.toString();
      task.completedAt = DateTime.now();
      
      debugPrint('FileUploadService: Failed to upload ${task.filePath}: $e');
    }
    
    notifyListeners();
  }
  
  /// Generate a title from filename
  String _generateTitle(String fileName) {
    final nameWithoutExtension = path.basenameWithoutExtension(fileName);
    return nameWithoutExtension.replaceAll('_', ' ').replaceAll('-', ' ');
  }
  
  /// Add a new storage for monitoring
  Future<void> addStorage(Storage storage) async {
    if (storage.isEnabled) {
      await _startMonitoring(storage);
      _isRunning = _watchers.isNotEmpty;
      notifyListeners();
    }
  }
  
  /// Remove storage from monitoring
  Future<void> removeStorage(String storageId) async {
    await _watchers[storageId]?.cancel();
    _watchers.remove(storageId);
    _processedFiles.remove(storageId);
    
    // Remove pending uploads for this storage
    _uploadQueue.removeWhere((task) => task.storage.id == storageId);
    
    _isRunning = _watchers.isNotEmpty;
    notifyListeners();
  }
  
  /// Update storage monitoring status
  Future<void> updateStorage(Storage storage) async {
    if (storage.isEnabled) {
      if (!_watchers.containsKey(storage.id)) {
        await _startMonitoring(storage);
      }
    } else {
      await removeStorage(storage.id);
    }
  }
  
  /// Stop all monitoring
  Future<void> stop() async {
    debugPrint('FileUploadService: Stopping all monitoring...');
    
    for (final subscription in _watchers.values) {
      await subscription.cancel();
    }
    
    _watchers.clear();
    _processedFiles.clear();
    _uploadQueue.clear();
    _activeUploads.clear();
    
    _isRunning = false;
    _isInitialized = false;
    
    debugPrint('FileUploadService: Stopped');
    notifyListeners();
  }
  
  /// Manually trigger upload for a specific file
  Future<void> uploadFile(String filePath, Storage storage) async {
    if (!_isMediaFile(filePath)) {
      throw Exception('File type not supported');
    }
    
    final uploadTask = UploadTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: filePath,
      storage: storage,
      status: UploadStatus.pending,
      createdAt: DateTime.now(),
    );
    
    _uploadQueue.add(uploadTask);
    notifyListeners();
    
    _processUploadQueue();
  }
  
  /// Retry failed upload
  Future<void> retryUpload(String taskId) async {
    final task = _activeUploads[taskId];
    if (task != null && task.status == UploadStatus.failed) {
      task.status = UploadStatus.pending;
      task.error = null;
      task.startedAt = null;
      task.completedAt = null;
      
      _uploadQueue.add(task);
      _activeUploads.remove(taskId);
      
      notifyListeners();
      _processUploadQueue();
    }
  }
  
  /// Clear completed uploads from history
  void clearCompletedUploads() {
    _activeUploads.removeWhere((_, task) => 
        task.status == UploadStatus.completed || 
        task.status == UploadStatus.failed);
    notifyListeners();
  }
  
  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

/// Upload task model
class UploadTask {
  final String id;
  final String filePath;
  final Storage storage;
  UploadStatus status;
  DateTime createdAt;
  DateTime? startedAt;
  DateTime? completedAt;
  String? error;
  Media? result;
  int? totalBytes;
  int? uploadedBytes;
  
  UploadTask({
    required this.id,
    required this.filePath,
    required this.storage,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.error,
    this.result,
    this.totalBytes,
    this.uploadedBytes,
  });
  
  String get fileName => path.basename(filePath);
  
  double get progress {
    if (totalBytes == null || totalBytes == 0) return 0.0;
    return (uploadedBytes ?? 0) / totalBytes!;
  }
  
  Duration? get duration {
    if (startedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }
}

/// Upload status enum
enum UploadStatus {
  pending,
  uploading,
  completed,
  failed,
}

extension UploadStatusExtension on UploadStatus {
  String get displayName {
    switch (this) {
      case UploadStatus.pending:
        return 'Pending';
      case UploadStatus.uploading:
        return 'Uploading';
      case UploadStatus.completed:
        return 'Completed';
      case UploadStatus.failed:
        return 'Failed';
    }
  }
  
  bool get isActive => this == UploadStatus.pending || this == UploadStatus.uploading;
  bool get isCompleted => this == UploadStatus.completed;
  bool get isFailed => this == UploadStatus.failed;
}
