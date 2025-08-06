import '../storage.dart';

class CreateStorageRequest {
  final String path; // Path to local folder on device

  CreateStorageRequest({
    required this.path,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
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
