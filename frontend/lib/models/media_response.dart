import 'package:frontend/models/media_type.dart';

class MediaResponse {
  final String id;
  final String title;
  final String? description;
  final MediaType mediaType;
  final String url;
  final List<String> tags;
  final String createdAt;
  final String username;

  MediaResponse({
    required this.id,
    required this.title,
    this.description,
    required this.mediaType,
    required this.url,
    required this.tags,
    required this.createdAt,
    required this.username,
  });

  factory MediaResponse.fromJson(Map<String, dynamic> json) {
    return MediaResponse(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      mediaType: MediaType.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == json['mediaType'].toString().toUpperCase(),
        orElse: () => MediaType.image,
      ),
      url: json['url'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: json['createdAt'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'mediaType': mediaType.toString().split('.').last,
      'url': url,
      'tags': tags,
      'createdAt': createdAt,
      'username': username,
    };
  }
}
