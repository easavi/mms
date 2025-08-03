import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class MediaService {
  final _apiService = ApiService();

  // Basic CRUD operations - Updated to match new API specification
  Future<List<Media>> getAllMedia({
    String group = 'month',
    String sortDirection = 'desc',
    String? start,
    String? end,
    String? type,
    List<String>? tags,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'group': group,
        'sortDirection': sortDirection,
        'page': page,
        'size': size,
      };

      if (start != null && start.isNotEmpty) {
        queryParams['start'] = start;
      }

      if (end != null && end.isNotEmpty) {
        queryParams['end'] = end;
      }

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      if (tags != null && tags.isNotEmpty) {
        queryParams['tags'] = tags;
      }

      final response = await _apiService.get(
        ApiConfig.media,
        queryParameters: queryParams,
      );

      final List<dynamic> content = response.data['content'] ?? response.data ?? [];
      return content.map((json) => Media.fromJson(json)).toList();
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

  // File upload
  Future<Media> uploadMedia({
    required String name,
    required MediaType mediaType,
    required String fileName,
    required String fileUrl,
    List<String> tags = const [],
  }) async {
    try {
      final request = CreateMediaRequest(
        name: name,
        mediaType: mediaType,
        fileName: fileName,
        fileUrl: fileUrl,
        tags: tags,
      );

      final response = await _apiService.post(
        ApiConfig.mediaUpload,
        data: request.toJson(),
      );

      return Media.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
