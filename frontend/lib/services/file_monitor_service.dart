import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';
import 'auth_service.dart';

class FolderWatcher {
  final String id;
  final String folderPath;
  final List<String> tags;
  final bool autoUpload;
  final Duration scanInterval;
  bool isActive;
  DateTime lastScan;
  int uploadedFiles;
  final Set<String> _processedFiles = {};

  FolderWatcher({
    required this.id,
    required this.folderPath,
    required this.tags,
    required this.autoUpload,
    required this.scanInterval,
    this.isActive = true,
    DateTime? lastScan,
    this.uploadedFiles = 0,
  }) : lastScan = lastScan ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'folderPath': folderPath,
    'tags': tags,
    'autoUpload': autoUpload,
    'scanInterval': scanInterval.inMinutes,
    'isActive': isActive,
    'lastScan': lastScan.millisecondsSinceEpoch,
    'uploadedFiles': uploadedFiles,
    'processedFiles': _processedFiles.toList(),
  };

  factory FolderWatcher.fromJson(Map<String, dynamic> json) {
    final watcher = FolderWatcher(
      id: json['id'],
      folderPath: json['folderPath'],
      tags: List<String>.from(json['tags'] ?? []),
      autoUpload: json['autoUpload'] ?? true,
      scanInterval: Duration(minutes: json['scanInterval'] ?? 5),
      isActive: json['isActive'] ?? true,
      lastScan: DateTime.fromMillisecondsSinceEpoch(json['lastScan'] ?? DateTime.now().millisecondsSinceEpoch),
      uploadedFiles: json['uploadedFiles'] ?? 0,
    );
    
    final processedFiles = List<String>.from(json['processedFiles'] ?? []);
    watcher._processedFiles.addAll(processedFiles);
    
    return watcher;
  }
}

class FileMonitorService extends ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;
  final List<FolderWatcher> _watchers = [];
  final Map<String, Timer> _scanTimers = {};
  
  static const String _storageKey = 'folder_watchers';
  
  FileMonitorService(this._apiService, this._authService) {
    _loadWatchers();
  }

  List<FolderWatcher> get watchers => List.unmodifiable(_watchers);

  Future<void> addFolderWatcher(
    String folderPath, {
    List<String> tags = const [],
    bool autoUpload = true,
    Duration scanInterval = const Duration(minutes: 5),
  }) async {
    // Validate folder exists
    final directory = Directory(folderPath);
    if (!await directory.exists()) {
      throw Exception('Folder does not exist: $folderPath');
    }

    // Check if folder is already being watched
    if (_watchers.any((w) => w.folderPath == folderPath)) {
      throw Exception('Folder is already being monitored');
    }

    final watcher = FolderWatcher(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      folderPath: folderPath,
      tags: tags,
      autoUpload: autoUpload,
      scanInterval: scanInterval,
    );

    _watchers.add(watcher);
    
    if (watcher.isActive) {
      _startScanning(watcher);
    }
    
    await _saveWatchers();
    notifyListeners();
  }

  Future<void> removeFolderWatcher(String watcherId) async {
    final watcher = _watchers.firstWhere((w) => w.id == watcherId);
    _stopScanning(watcher);
    _watchers.removeWhere((w) => w.id == watcherId);
    
    await _saveWatchers();
    notifyListeners();
  }

  Future<void> toggleWatcherActive(String watcherId) async {
    final watcher = _watchers.firstWhere((w) => w.id == watcherId);
    watcher.isActive = !watcher.isActive;
    
    if (watcher.isActive) {
      _startScanning(watcher);
    } else {
      _stopScanning(watcher);
    }
    
    await _saveWatchers();
    notifyListeners();
  }

  Future<void> manualScan(String watcherId) async {
    final watcher = _watchers.firstWhere((w) => w.id == watcherId);
    await _scanFolder(watcher);
    notifyListeners();
  }

  void _startScanning(FolderWatcher watcher) {
    _stopScanning(watcher); // Stop any existing timer
    
    _scanTimers[watcher.id] = Timer.periodic(watcher.scanInterval, (timer) async {
      await _scanFolder(watcher);
      notifyListeners();
    });
    
    // Perform initial scan
    _scanFolder(watcher);
  }

  void _stopScanning(FolderWatcher watcher) {
    _scanTimers[watcher.id]?.cancel();
    _scanTimers.remove(watcher.id);
  }

  Future<void> _scanFolder(FolderWatcher watcher) async {
    try {
      final directory = Directory(watcher.folderPath);
      if (!await directory.exists()) {
        debugPrint('Folder no longer exists: ${watcher.folderPath}');
        return;
      }

      watcher.lastScan = DateTime.now();
      
      final files = await directory.list(recursive: false).toList();
      final mediaFiles = files
          .whereType<File>()
          .where((file) => _isMediaFile(file.path))
          .toList();

      for (final file in mediaFiles) {
        final filePath = file.path;
        final fileName = path.basename(filePath);
        
        // Skip if already processed
        if (watcher._processedFiles.contains(filePath)) {
          continue;
        }

        if (watcher.autoUpload) {
          try {
            await _uploadFile(file, watcher.tags);
            watcher._processedFiles.add(filePath);
            watcher.uploadedFiles++;
            debugPrint('Uploaded: $fileName');
          } catch (e) {
            debugPrint('Failed to upload $fileName: $e');
            // Don't add to processed files if upload failed
          }
        }
      }

      await _saveWatchers();
    } catch (e) {
      debugPrint('Error scanning folder ${watcher.folderPath}: $e');
    }
  }

  bool _isMediaFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    const supportedExtensions = {
      // Images
      '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg', '.tiff',
      // Videos
      '.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm', '.m4v',
      // Audio
      '.mp3', '.wav', '.flac', '.aac', '.ogg', '.wma', '.m4a',
      // Documents
      '.pdf', '.doc', '.docx', '.txt', '.rtf',
      // Archives
      '.zip', '.rar', '.7z', '.tar', '.gz',
    };
    
    return supportedExtensions.contains(extension);
  }

  Future<void> _uploadFile(File file, List<String> tags) async {
    if (!_authService.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    final fileName = path.basename(file.path);
    final fileBytes = await file.readAsBytes();
    
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
      ),
      'title': fileName,
      'description': 'Auto-uploaded from folder monitor',
      if (tags.isNotEmpty) 'tags': tags,
    });

    await _apiService.uploadFile('/api/media/upload', formData);
  }

  Future<void> _loadWatchers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchersJson = prefs.getString(_storageKey);
      
      if (watchersJson != null) {
        final List<dynamic> watchersList = jsonDecode(watchersJson);
        _watchers.clear();
        
        for (final watcherData in watchersList) {
          final watcher = FolderWatcher.fromJson(watcherData);
          _watchers.add(watcher);
          
          // Start scanning for active watchers
          if (watcher.isActive) {
            _startScanning(watcher);
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading watchers: $e');
    }
  }

  Future<void> _saveWatchers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchersJson = jsonEncode(_watchers.map((w) => w.toJson()).toList());
      await prefs.setString(_storageKey, watchersJson);
    } catch (e) {
      debugPrint('Error saving watchers: $e');
    }
  }

  @override
  void dispose() {
    // Stop all timers
    for (final timer in _scanTimers.values) {
      timer.cancel();
    }
    _scanTimers.clear();
    super.dispose();
  }
}
