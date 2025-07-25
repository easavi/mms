enum MediaType {
  image,
  video,
  document,
}

extension MediaTypeExtension on MediaType {
  String get displayName {
    switch (this) {
      case MediaType.image:
        return 'Image';
      case MediaType.video:
        return 'Video';
      case MediaType.document:
        return 'Document';
    }
  }

  bool get isImage => this == MediaType.image;
  bool get isVideo => this == MediaType.video;
  bool get isDocument => this == MediaType.document;
}
