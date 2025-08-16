import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'device_service.dart';

class StorageService {
  final _apiService = ApiService();
  final _deviceService = DeviceService.instance;

  // Basic CRUD operations
  Future<List<Storage>> getAllStorage() async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      final response = await _apiService.get('${ApiConfig.storage}?deviceId=$deviceId');
      debugPrint('Storage API Response type: ${response.data.runtimeType}');
      debugPrint('Storage API Response: ${response.data}');
      
      final List<dynamic> data = response.data is List 
          ? response.data 
          : response.data['content'] ?? [];
      
      debugPrint('Processing ${data.length} storage items');
      return data.map((json) {
        try {
          return Storage.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing storage item: $e');
          debugPrint('JSON data: $json');
          rethrow;
        }
      }).toList();
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

  Future<Storage> createStorage(String path) async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      final request = CreateStorageRequest(
        path: path,
        deviceId: deviceId,
      );
      
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

  // Get storage quantity by bucket
  Future<int> getStorageQuantity(String bucket) async {
    try {
      final response = await _apiService.get('${ApiConfig.storage}/$bucket/quantity');
      return response.data as int;
    } catch (e) {
      rethrow;
    }
  }

  // Get storage size by bucket
  Future<int> getStorageSize(String bucket) async {
    try {
      final response = await _apiService.get('${ApiConfig.storage}/$bucket/size');
      return response.data as int;
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

  // Get current device ID
  Future<String> getDeviceId() async {
    return await _deviceService.getDeviceId();
  }

  // Get device info for debugging
  Future<String> getDeviceInfo() async {
    return await _deviceService.getDeviceInfo();
  }
}
