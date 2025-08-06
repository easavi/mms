enum StorageType {
  Server, // Only option available now
}

extension StorageTypeExtension on StorageType {
  String get displayName {
    switch (this) {
      case StorageType.Server:
        return 'Server';
    }
  }

  String get apiValue {
    return 'server'; // Always lowercase 'server'
  }

  static StorageType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'server':
        return StorageType.Server;
      default:
        throw ArgumentError('Unknown StorageType: $value');
    }
  }
}

class Storage {
  final String id;
  final String bucket;    // Auto-generated, not visible to user
  final String path;      // Path to local folder on device
  final StorageType type; // Always Server
  final DateTime updated;
  final int size;         // Total size in bytes
  final int itemsQuantity; // Number of items
  final String username;  // User owning this storage
  final bool isEnabled;   // Whether storage is enabled (for UI state)

  Storage({
    required this.id,
    required this.bucket,
    required this.path,
    required this.type,
    required this.updated,
    required this.size,
    required this.itemsQuantity,
    required this.username,
    this.isEnabled = true,
  });

  factory Storage.fromJson(Map<String, dynamic> json) {
    return Storage(
      id: json['id'],
      bucket: json['bucket'],
      path: json['path'],
      type: StorageTypeExtension.fromString(json['type']),
      updated: DateTime.parse(json['updated']),
      size: json['size'] ?? 0,
      itemsQuantity: json['itemsQuantity'] ?? 0,
      username: json['username'],
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bucket': bucket,
      'path': path,
      'type': type.apiValue,
      'updated': updated.toIso8601String(),
      'size': size,
      'itemsQuantity': itemsQuantity,
      'username': username,
      'isEnabled': isEnabled,
    };
  }

  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
