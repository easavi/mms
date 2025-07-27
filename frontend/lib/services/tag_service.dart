import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class TagService {
  final _apiService = ApiService();

  // Basic CRUD operations
  Future<List<Tag>> getAllTags() async {
    try {
      final response = await _apiService.get(ApiConfig.tags);
      final List<dynamic> data = response.data is List 
          ? response.data 
          : response.data['content'] ?? [];
      return data.map((json) => Tag.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Tag> getTagById(String id) async {
    try {
      final response = await _apiService.get('${ApiConfig.tagById}$id');
      return Tag.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Tag> getTagByName(String name) async {
    try {
      final response = await _apiService.get('${ApiConfig.tagByName}$name');
      return Tag.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Tag> createTag(CreateTagRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConfig.tags,
        data: request.toJson(),
      );
      return Tag.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Tag> updateTag(String id, UpdateTagRequest request) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.tagById}$id',
        data: request.toJson(),
      );
      return Tag.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTag(String id) async {
    try {
      await _apiService.delete('${ApiConfig.tagById}$id');
    } catch (e) {
      rethrow;
    }
  }

  // Search tags by name
  Future<List<Tag>> searchTags(String query) async {
    try {
      final response = await _apiService.get(
        ApiConfig.tags,
        queryParameters: {'search': query},
      );
      final List<dynamic> data = response.data is List 
          ? response.data 
          : response.data['content'] ?? [];
      return data.map((json) => Tag.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
