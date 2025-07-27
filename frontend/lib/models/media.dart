import 'media_type.dart';

class Media {
  final String id;
  final String name;
  final MediaType mediaType;
  final String fileName;
  final String fileUrl;
  final DateTime createdAt;
  final DateTime? uploadedAt;
  final List<String> tags;

  Media({
    required this.id,
    required this.name,
    required this.mediaType,
    required this.fileName,
    required this.fileUrl,
    required this.createdAt,
    this.uploadedAt,
    required this.tags,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      name: json['name'],
      mediaType: MediaTypeExtension.fromString(json['mediaType']),
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      uploadedAt: json['uploadedAt'] != null ? DateTime.parse(json['uploadedAt']) : null,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mediaType': mediaType.apiValue,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'createdAt': createdAt.toIso8601String(),
      'uploadedAt': uploadedAt?.toIso8601String(),
      'tags': tags,
    };
  }

  String get fileExtension {
    return fileName.split('.').last.toLowerCase();
  }

  bool get isImage => mediaType.isImage;
  bool get isVideo => mediaType.isVideo;
  bool get isFile => mediaType.isFile;

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays > 730 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays > 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String get monthYear {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[createdAt.month - 1]} ${createdAt.year}';
  }

  String get dayMonthYear {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }
}
