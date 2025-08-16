
class CreateStorageRequest {
  final String path; // Path to local folder on device
  final String deviceId; // Device identifier

  CreateStorageRequest({
    required this.path,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'deviceId': deviceId,
    };
  }
}

class UpdateStorageRequest {
  final String? path;

  UpdateStorageRequest({
    this.path,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (path != null) json['path'] = path;
    return json;
  }
}
