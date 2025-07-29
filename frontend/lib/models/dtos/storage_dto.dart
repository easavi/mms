import '../storage.dart';

class CreateStorageRequest {
  final String name;
  final StorageType type;
  final String bucket;
  final String username;

  CreateStorageRequest({
    required this.name,
    required this.type,
    required this.bucket,
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.apiValue,
      'bucket': bucket,
      'username': username,
    };
  }
}

class UpdateStorageRequest {
  final String? name;
  final String? bucket;
  final int? size;
  final int? itemsQuantity;

  UpdateStorageRequest({
    this.name,
    this.bucket,
    this.size,
    this.itemsQuantity,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (bucket != null) json['bucket'] = bucket;
    if (size != null) json['size'] = size;
    if (itemsQuantity != null) json['itemsQuantity'] = itemsQuantity;
    return json;
  }
}
