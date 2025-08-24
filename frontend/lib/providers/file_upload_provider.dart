import 'package:flutter/foundation.dart';
import '../services/file_upload_service.dart';

/// Provider for managing the File Upload Service state
class FileUploadProvider extends ChangeNotifier {
  final FileUploadService _fileUploadService = FileUploadService();
  
  // State
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  // Delegate getters to the service
  bool get isRunning => _fileUploadService.isRunning;
  int get pendingUploads => _fileUploadService.pendingUploads;
  int get totalUploads => _fileUploadService.totalUploads;
  List<UploadItem> get uploadItems => _fileUploadService.uploadItems;
  List<UploadItem> get failedUploads => _fileUploadService.failedUploads;
  
  FileUploadProvider() {
    // Listen to changes from the service
    _fileUploadService.addListener(_onServiceChanged);
  }
  
  @override
  void dispose() {
    _fileUploadService.removeListener(_onServiceChanged);
    super.dispose();
  }
  
  void _onServiceChanged() {
    notifyListeners();
  }
  
  /// Initialize and start the file upload service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('🚀 Initializing File Upload Service...');
      await _fileUploadService.start();
      _isInitialized = _fileUploadService.isRunning; // Only mark as initialized if actually running
      if (_isInitialized) {
        debugPrint('✅ File Upload Service initialized successfully');
      } else {
        debugPrint('ℹ️ File Upload Service not started (platform not supported)');
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize File Upload Service: $e');
      rethrow;
    }
    
    notifyListeners();
  }
  
  /// Stop the file upload service
  Future<void> stop() async {
    if (!_isInitialized) return;
    
    try {
      await _fileUploadService.stop();
      _isInitialized = false;
      debugPrint('✅ File Upload Service stopped successfully');
    } catch (e) {
      debugPrint('❌ Error stopping File Upload Service: $e');
      _isInitialized = false; // Mark as not initialized even if stop failed
    }
    
    notifyListeners();
  }
  
  /// Add storage monitoring
  Future<void> addStorageMonitoring(storage) async {
    await _fileUploadService.addStorageMonitoring(storage);
  }
  
  /// Remove storage monitoring
  Future<void> removeStorageMonitoring(String storageId) async {
    await _fileUploadService.removeStorageMonitoring(storageId);
  }
  
  /// Retry a failed upload
  Future<void> retryUpload(String uploadId) async {
    await _fileUploadService.retryUpload(uploadId);
  }
  
  /// Clear upload history
  void clearHistory() {
    _fileUploadService.clearHistory();
  }
  
  /// Get upload status summary
  Map<UploadStatus, int> getUploadStatusSummary() {
    final summary = <UploadStatus, int>{};
    
    for (final status in UploadStatus.values) {
      summary[status] = 0;
    }
    
    for (final item in uploadItems) {
      summary[item.status] = (summary[item.status] ?? 0) + 1;
    }
    
    return summary;
  }
  
  /// Get upload progress for display
  String getUploadProgressText() {
    if (!isRunning) return 'Service stopped';
    
    final summary = getUploadStatusSummary();
    final pending = summary[UploadStatus.pending] ?? 0;
    final uploading = summary[UploadStatus.uploading] ?? 0;
    final completed = summary[UploadStatus.completed] ?? 0;
    final failed = summary[UploadStatus.failed] ?? 0;
    
    if (pending == 0 && uploading == 0) {
      if (failed > 0) return '$failed failed uploads';
      if (completed > 0) return 'All uploads completed';
      return 'Monitoring for new files';
    }
    
    final active = pending + uploading;
    return '$active uploads in progress';
  }
}
