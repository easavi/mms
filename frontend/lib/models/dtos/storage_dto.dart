import '../storage.dart';

class CreateStorageRequest {
  final String name;
  final StorageType storageType;
  final String accessKey;
  final String secretKey;
  final String bucketName;
  final String? region;
  final String? endpoint;

  CreateStorageRequest({
    required this.name,
    required this.storageType,
    required this.accessKey,
    required this.secretKey,
    required this.bucketName,
    this.region,
    this.endpoint,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'storageType': storageType.apiValue,
      'accessKey': accessKey,
      'secretKey': secretKey,
      'bucketName': bucketName,
      'region': region,
      'endpoint': endpoint,
    };
  }
}

class UpdateStorageRequest {
  final String? name;
  final StorageType? storageType;
  final String? accessKey;
  final String? secretKey;
  final String? bucketName;
  final String? region;
  final String? endpoint;

  UpdateStorageRequest({
    this.name,
    this.storageType,
    this.accessKey,
    this.secretKey,
    this.bucketName,
    this.region,
    this.endpoint,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (storageType != null) json['storageType'] = storageType!.apiValue;
    if (accessKey != null) json['accessKey'] = accessKey;
    if (secretKey != null) json['secretKey'] = secretKey;
    if (bucketName != null) json['bucketName'] = bucketName;
    if (region != null) json['region'] = region;
    if (endpoint != null) json['endpoint'] = endpoint;
    return json;
  }
}
