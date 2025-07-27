enum StorageType {
  AWS,
  Minio,
}

extension StorageTypeExtension on StorageType {
  String get displayName {
    switch (this) {
      case StorageType.AWS:
        return 'Amazon S3';
      case StorageType.Minio:
        return 'MinIO';
    }
  }

  String get apiValue {
    return name; // Returns 'AWS' or 'Minio'
  }

  static StorageType fromString(String value) {
    switch (value) {
      case 'AWS':
        return StorageType.AWS;
      case 'Minio':
        return StorageType.Minio;
      default:
        throw ArgumentError('Unknown StorageType: $value');
    }
  }
}

class Storage {
  final String id;
  final StorageType type;
  final String name;
  final String bucket;
  final DateTime updated;
  final int size;
  final int itemsQuantity;
  final String username;

  Storage({
    required this.id,
    required this.type,
    required this.name,
    required this.bucket,
    required this.updated,
    required this.size,
    required this.itemsQuantity,
    required this.username,
  });

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      id: json['id'],
      type: StorageTypeExtension.fromString(json['type']),
      name: json['name'],
      bucket: json['bucket'],
      updated: DateTime.parse(json['updated']),
      size: json['size'],
      itemsQuantity: json['itemsQuantity'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.apiValue,
      'name': name,
      'bucket': bucket,
      'updated': updated.toIso8601String(),
      'size': size,
      'itemsQuantity': itemsQuantity,
      'username': username,
    };
  }

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
