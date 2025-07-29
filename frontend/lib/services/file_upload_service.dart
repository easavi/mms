import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import 'auth_service.dart';

class FileUploadService {
  final Dio _dio;
  final AuthService _authService;

  FileUploadService(this._dio, this._authService);

  /// Upload a single file to the backend
  Future<Media?> uploadFile(File file, {
    List<String>? tags,
    String? storageId,
  }) async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw Exception('Authentication required');
      }

      // Create form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _getFileName(file.path),
        ),
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
        if (storageId != null) 'storageId': storageId,
      });

      final response = await _dio.post(
        ApiConfig.mediaUpload,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: (int sent, int total) {
          final progress = sent / total;
          debugPrint('Upload progress: ${(progress * 100).toInt()}%');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Media.fromJson(response.data);
      } else {
        throw Exception('Upload failed: ${response.statusMessage}');
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
      rethrow;
    }
  }

  /// Upload multiple files
  Future<List<Media>> uploadFiles(
    List<File> files, {
    List<String>? tags,
    String? storageId,
    Function(int current, int total)? onProgress,
  }) async {
    final uploadedMedia = <Media>[];
    
    for (int i = 0; i < files.length; i++) {
      try {
        onProgress?.call(i + 1, files.length);
        
        final media = await uploadFile(
          files[i],
          tags: tags,
          storageId: storageId,
        );
        
        if (media != null) {
          uploadedMedia.add(media);
        }
      } catch (e) {
        debugPrint('Failed to upload file ${files[i].path}: $e');
        // Continue with next file even if one fails
      }
    }
    
    return uploadedMedia;
  }

  /// Upload files from a directory
  Future<List<Media>> uploadFromDirectory(
    String directoryPath, {
    List<String>? tags,
    String? storageId,
    bool recursive = false,
    Function(int current, int total)? onProgress,
  }) async {
    try {
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        throw Exception('Directory does not exist: $directoryPath');
      }

      final files = await _getMediaFilesFromDirectory(directory, recursive);
      
      if (files.isEmpty) {
        return [];
      }

      return uploadFiles(
        files,
        tags: tags,
        storageId: storageId,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('Error uploading from directory: $e');
      return [];
    }
  }

  /// Get media files from a directory
  Future<List<File>> _getMediaFilesFromDirectory(
    Directory directory,
    bool recursive,
  ) async {
    final files = <File>[];
    
    await for (final entity in directory.list(recursive: recursive)) {
      if (entity is File && _isMediaFile(entity.path)) {
        files.add(entity);
      }
    }
    
    return files;
  }

  /// Check if file is a supported media file
  bool _isMediaFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    const supportedExtensions = [
      // Images
      'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg',
      // Videos
      'mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv', '3gp'
    ];
    return supportedExtensions.contains(extension);
  }

  /// Get file name from path
  String _getFileName(String filePath) {
    return filePath.split('/').last.split('\\').last;
  }

  /// Get media type from file extension
  MediaType _getMediaType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'];
    const videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv', '3gp'];
    
    if (imageExtensions.contains(extension)) {
      return MediaType.image;
    } else if (videoExtensions.contains(extension)) {
      return MediaType.video;
    } else {
      return MediaType.file;
    }
  }
}

/// Upload progress callback
typedef UploadProgressCallback = void Function(int current, int total);

/// Upload result model
class UploadResult {
  final List<Media> successful;
  final List<UploadError> failed;

  UploadResult({
    required this.successful,
    required this.failed,
  });

  bool get hasErrors => failed.isNotEmpty;
  int get totalUploaded => successful.length;
  int get totalFailed => failed.length;
}

/// Upload error model
class UploadError {
  final String filePath;
  final String error;

  UploadError({
    required this.filePath,
    required this.error,
  });
}
