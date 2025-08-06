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
  final int fileSize;
  final String mimeType;

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
    return Media(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      mediaType: MediaTypeExtension.fromString(json['mediaType'] ?? 'file'),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      uploadedAt: DateTime.parse(json['uploadedAt'] ?? DateTime.now().toIso8601String()),
      tags: List<String>.from(json['tags'] ?? []),
      thumbnailUrl: json['thumbnailUrl'],
      fileSize: json['fileSize'] ?? 0,
      mimeType: json['mimeType'] ?? '',
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
}
