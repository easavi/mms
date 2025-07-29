import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FileService {
  static const List<String> supportedImageExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'
  ];
  
  static const List<String> supportedVideoExtensions = [
    'mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv', '3gp'
  ];

  /// Pick a single file from the file system
  static Future<File?> pickSingleFile({
    String? dialogTitle,
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  /// Pick multiple files from the file system
  static Future<List<File>> pickMultipleFiles({
    String? dialogTitle,
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        dialogTitle: dialogTitle,
      );

      if (result != null) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error picking files: $e');
      return [];
    }
  }

  /// Pick media files (images and videos)
  static Future<List<File>> pickMediaFiles() async {
    return pickMultipleFiles(
      dialogTitle: 'Select Media Files',
      allowedExtensions: [
        ...supportedImageExtensions,
        ...supportedVideoExtensions,
      ],
      type: FileType.custom,
    );
  }

  /// Pick image files only
  static Future<List<File>> pickImageFiles() async {
    return pickMultipleFiles(
      dialogTitle: 'Select Image Files',
      allowedExtensions: supportedImageExtensions,
      type: FileType.custom,
    );
  }

  /// Pick video files only
  static Future<List<File>> pickVideoFiles() async {
    return pickMultipleFiles(
      dialogTitle: 'Select Video Files',
      allowedExtensions: supportedVideoExtensions,
      type: FileType.custom,
    );
  }

  /// Pick a directory
  static Future<String?> pickDirectory({String? dialogTitle}) async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle ?? 'Select Directory',
      );
      return selectedDirectory;
    } catch (e) {
      debugPrint('Error picking directory: $e');
      return null;
    }
  }

  /// Check if file is an image
  static bool isImageFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return supportedImageExtensions.contains(extension);
  }

  /// Check if file is a video
  static bool isVideoFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return supportedVideoExtensions.contains(extension);
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }

  /// Get file name from path
  static String getFileName(String filePath) {
    return filePath.split('/').last.split('\\').last;
  }

  /// Format file size to human readable string
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
