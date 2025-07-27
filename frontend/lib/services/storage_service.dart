import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class StorageService {
  final _apiService = ApiService();

  // Basic CRUD operations
  Future<List<Storage>> getAllStorage() async {
    try {
      final response = await _apiService.get(ApiConfig.storage);
      final List<dynamic> data = response.data is List 
          ? response.data 
          : response.data['content'] ?? [];
      return data.map((json) => Storage.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Storage> getStorageById(String id) async {
    try {
      final response = await _apiService.get('${ApiConfig.storageById}$id');
      return Storage.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Storage> createStorage(CreateStorageRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConfig.storage,
        data: request.toJson(),
      );
      return Storage.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Storage> updateStorage(String id, UpdateStorageRequest request) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.storageById}$id',
        data: request.toJson(),
      );
      return Storage.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteStorage(String id) async {
    try {
      await _apiService.delete('${ApiConfig.storageById}$id');
    } catch (e) {
      rethrow;
    }
  }

  // Test storage connection
  Future<Map<String, dynamic>> testStorageConnection(String id) async {
    try {
      final response = await _apiService.get('${ApiConfig.storageTest}$id');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
