import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class MediaService {
  final _apiService = ApiService();

  Future<List<Media>> getAllMedia({
    String? group,
    String? sortDirection,
    String? start,
    String? end,
    String? type,
    List<String>? tags,
    int? page,
    int? size,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (group != null) queryParams['group'] = group;
      if (sortDirection != null) queryParams['sortDirection'] = sortDirection;
      if (start != null) queryParams['start'] = start;
      if (end != null) queryParams['end'] = end;
      if (type != null) queryParams['type'] = type;
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');
      if (page != null) queryParams['page'] = page.toString();
      if (size != null) queryParams['size'] = size.toString();

      final response = await _apiService.get(
        ApiConfig.media,
        queryParameters: queryParams,
      );
      
      final List<dynamic> data = response.data is List 
          ? response.data 
          : response.data['content'] ?? [];
      
      return data.map((json) => Media.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Media> getMediaById(String id) async {
    try {
      final response = await _apiService.get('${ApiConfig.mediaById}$id');
      return Media.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Media> createMedia(CreateMediaRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConfig.media,
        data: request.toJson(),
      );
      return Media.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Media> updateMedia(String id, UpdateMediaRequest request) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.mediaById}$id',
        data: request.toJson(),
      );
      return Media.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMedia(String id) async {
    try {
      await _apiService.delete('${ApiConfig.mediaById}$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<Media> uploadMedia({
    required String filePath,
    required String title,
    required String mediaType,
    String? description,
    List<String>? tags,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'title': title,
        'mediaType': mediaType,
        'description': description ?? '',
        'tags': tags?.join(',') ?? '',
      });

      final response = await _apiService.uploadFile(
        ApiConfig.mediaUpload,
        formData,
      );
      
      return Media.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
