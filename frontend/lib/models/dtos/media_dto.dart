class CreateMediaRequest {
  final String name;
  final String fileName;
  final String fileUrl;
  final String mediaType;
  final DateTime createdAt;
  final List<String>? tags;

  CreateMediaRequest({
    required this.name,
    required this.fileName,
    required this.fileUrl,
    required this.mediaType,
    required this.createdAt,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'mediaType': mediaType,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }
}

class UpdateMediaRequest {
  final String? name;
  final List<String>? tags;

  UpdateMediaRequest({
    this.name,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (tags != null) json['tags'] = tags;
    return json;
  }
}
