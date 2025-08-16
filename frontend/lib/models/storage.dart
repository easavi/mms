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
    if (value.isEmpty) return StorageType.Server;
    
    switch (value.toLowerCase()) {
      case 'server':
        return StorageType.Server;
      default:
        // Return Server as default instead of throwing an error
        return StorageType.Server;
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
  final String deviceId;  // Device identifier
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
    required this.deviceId,
    this.isEnabled = true,
  });

  factory Storage.fromJson(Map<String, dynamic> json) {
    // Safely parse size
    int parsedSize = 0;
    final sizeData = json['size'];
    if (sizeData is int) {
      parsedSize = sizeData;
    } else if (sizeData is String) {
      parsedSize = int.tryParse(sizeData) ?? 0;
    }

    // Safely parse itemsQuantity
    int parsedItemsQuantity = 0;
    final itemsQuantityData = json['itemsQuantity'];
    if (itemsQuantityData is int) {
      parsedItemsQuantity = itemsQuantityData;
    } else if (itemsQuantityData is String) {
      parsedItemsQuantity = int.tryParse(itemsQuantityData) ?? 0;
    }

    return Storage(
      id: json['id']?.toString() ?? '',
      bucket: json['bucket']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      type: StorageTypeExtension.fromString(json['type']?.toString() ?? 'server'),
      updated: DateTime.parse(json['updated']?.toString() ?? DateTime.now().toIso8601String()),
      size: parsedSize,
      itemsQuantity: parsedItemsQuantity,
      username: json['username']?.toString() ?? '',
      deviceId: json['deviceId']?.toString() ?? '',
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
      'deviceId': deviceId,
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
