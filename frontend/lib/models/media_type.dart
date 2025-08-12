enum MediaType {
  image,
  video,
  file,
}

extension MediaTypeExtension on MediaType {
  String get displayName {
    switch (this) {
      case MediaType.image:
        return 'Image';
      case MediaType.video:
        return 'Video';
      case MediaType.file:
        return 'File';
    }
  }

  String get apiValue {
    return name; // Returns lowercase string (image, video, file)
  }

  bool get isImage => this == MediaType.image;
  bool get isVideo => this == MediaType.video;
  bool get isFile => this == MediaType.file;

  static MediaType fromString(String value) {
    if (value.isEmpty) return MediaType.file;
    
    switch (value.toLowerCase()) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      case 'file':
        return MediaType.file;
      default:
        // Return file as default instead of throwing an error
        return MediaType.file;
    }
  }
}
