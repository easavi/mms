import '../config/api_config.dart';
import '../models/media_response.dart';
import 'api_service.dart';

class MediaService {
  final _apiService = ApiService();

  Future<List<MediaResponse>> getAllMedia({
    String? search,
    String? type,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await _apiService.get(
        ApiConfig.media,
        queryParameters: queryParams,
      );

      final List<dynamic> content = response.data['content'] ?? [];
      return content.map((json) => MediaResponse.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaResponse> getMediaById(String id) async {
    try {
      final response = await _apiService.get('${ApiConfig.mediaById}$id');
      return MediaResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
