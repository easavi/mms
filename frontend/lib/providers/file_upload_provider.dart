import 'package:flutter/foundation.dart';
import '../services/file_upload_service.dart';

class FileUploadProvider extends ChangeNotifier {
  FileUploadService? _uploadService;
  
  FileUploadService? get uploadService => _uploadService;
  bool get isInitialized => _uploadService?.isInitialized ?? false;
  bool get isRunning => _uploadService?.isRunning ?? false;
  int get pendingUploadsCount => _uploadService?.pendingUploadsCount ?? 0;
  
  /// Initialize the upload service
  Future<void> initializeUploadService() async {
    if (_uploadService != null) return;
    
    try {
      _uploadService = FileUploadService();
      _uploadService!.addListener(_onUploadServiceChanged);
      
      await _uploadService!.initialize();
      
      debugPrint('FileUploadProvider: Upload service initialized');
      notifyListeners();
    } catch (e) {
      debugPrint('FileUploadProvider: Failed to initialize upload service: $e');
      rethrow;
    }
  }
  
  /// Stop the upload service
  Future<void> stopUploadService() async {
    if (_uploadService == null) return;
    
    _uploadService!.removeListener(_onUploadServiceChanged);
    await _uploadService!.stop();
    _uploadService = null;
    
    debugPrint('FileUploadProvider: Upload service stopped');
    notifyListeners();
  }
  
  void _onUploadServiceChanged() {
    notifyListeners();
  }
  
  @override
  void dispose() {
    stopUploadService();
    super.dispose();
  }
}
