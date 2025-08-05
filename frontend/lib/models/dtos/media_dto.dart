import '../media_type.dart';

class CreateMediaRequest {
  final String name;
  final MediaType mediaType;
  final String fileName;
  final String fileUrl;
  final List<String> tags;

  CreateMediaRequest({
    required this.name,
    required this.mediaType,
    required this.fileName,
    required this.fileUrl,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mediaType': mediaType.apiValue,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'tags': tags,
    };
  }
}

class UpdateMediaRequest {
  final String? name;
  final MediaType? mediaType;
  final String? fileName;
  final String? fileUrl;
  final List<String>? tags;

  UpdateMediaRequest({
    this.name,
    this.mediaType,
    this.fileName,
    this.fileUrl,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (mediaType != null) json['mediaType'] = mediaType!.apiValue;
    if (fileName != null) json['fileName'] = fileName;
    if (fileUrl != null) json['fileUrl'] = fileUrl;
    if (tags != null) json['tags'] = tags;
    return json;
  }
}

// Note: MediaFilterRequest has been removed as the API now uses simpler parameters
// directly in the getAllMedia method
