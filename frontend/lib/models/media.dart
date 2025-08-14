import 'media_type.dart';

class Media {
  final String id;
  final String name;
  final String fileName;
  final String fileUrl;
  final MediaType mediaType;
  final DateTime createdAt;
  final DateTime uploadedAt;
  final List<String> tags;
  final String? thumbnailUrl;
  final int fileSize; // Default to 0 if not provided by backend
  final String mimeType; // Default to empty string if not provided by backend

  Media({
    required this.id,
    required this.name,
    required this.fileName,
    required this.fileUrl,
    required this.mediaType,
    required this.createdAt,
    required this.uploadedAt,
    required this.tags,
    this.thumbnailUrl,
    required this.fileSize,
    required this.mimeType,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    // Safely parse tags - backend returns String[] array
    List<String> parsedTags = [];
    final tagsData = json['tags'];
    if (tagsData is List) {
      parsedTags = List<String>.from(tagsData.map((tag) => tag.toString()));
    } else if (tagsData is String && tagsData.isNotEmpty) {
      // Handle case where tags might be a comma-separated string
      parsedTags = tagsData.split(',').map((tag) => tag.trim()).toList();
    }

    // fileSize and mimeType are not provided by backend MediaResponse
    // We'll default them to safe values
    int parsedFileSize = 0;
    String parsedMimeType = '';

    // Try to determine mime type from file extension if possible
    final fileName = json['fileName']?.toString() ?? '';
    if (fileName.isNotEmpty) {
      final extension = fileName.toLowerCase().split('.').last;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          parsedMimeType = 'image/jpeg';
          break;
        case 'png':
          parsedMimeType = 'image/png';
          break;
        case 'gif':
          parsedMimeType = 'image/gif';
          break;
        case 'mp4':
          parsedMimeType = 'video/mp4';
          break;
        case 'pdf':
          parsedMimeType = 'application/pdf';
          break;
        default:
          parsedMimeType = 'application/octet-stream';
      }
    }

    return Media(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fileName: fileName,
      fileUrl: json['fileUrl']?.toString() ?? '',
      mediaType: MediaTypeExtension.fromString(json['mediaType']?.toString() ?? 'file'),
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      uploadedAt: DateTime.parse(json['uploadedAt']?.toString() ?? DateTime.now().toIso8601String()),
      tags: parsedTags,
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      fileSize: parsedFileSize, // Default to 0 since backend doesn't provide this
      mimeType: parsedMimeType, // Derived from file extension
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'mediaType': mediaType.apiValue,
      'createdAt': createdAt.toIso8601String(),
      'uploadedAt': uploadedAt.toIso8601String(),
      'tags': tags,
      'thumbnailUrl': thumbnailUrl,
      'fileSize': fileSize,
      'mimeType': mimeType,
    };
  }

  // Convenience getters
  bool get isImage => mediaType.isImage;
  bool get isVideo => mediaType.isVideo;
  bool get isFile => mediaType.isFile;
  
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last : '';
  }
  
  String get dayMonthYear {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  /// Get the thumbnail URL for this media item (only available for images)
  String? get thumbnailUrlFromFileUrl {
    if (!isImage) return null;
    
    // Extract bucket and fileId from fileUrl
    // Example fileUrl: "/api/media/content?bucket=local&fileId=username/images/filename.ext"
    final uri = Uri.parse(fileUrl);
    final bucket = uri.queryParameters['bucket'];
    final fileId = uri.queryParameters['fileId'];
    
    if (bucket != null && fileId != null) {
      // Construct thumbnail URL
      final thumbnailUrl = '/api/media/thumbnail?bucket=$bucket&fileId=$fileId';
      print('🎯 Generated thumbnail URL for ${fileName}: $thumbnailUrl');
      return thumbnailUrl;
    }
    
    print('⚠️ Could not generate thumbnail URL for ${fileName}, fileUrl: $fileUrl');
    return null;
  }
}
