import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class MediaService {
  final _apiService = ApiService();

  // Basic CRUD operations
  Future<List<Media>> getAllMedia({
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

  // Advanced filtering and searching
  Future<List<Media>> filterMedia(MediaFilterRequest request) async {
    try {
      final response = await _apiService.get(
        ApiConfig.mediaFilter,
        queryParameters: request.toQueryParams(),
      );

      final List<dynamic> data = response.data is List 
          ? response.data 
          : response.data['content'] ?? [];
      return data.map((json) => Media.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<PagedResponse<Media>> filterMediaPaged(MediaFilterRequest request) async {
    try {
      final response = await _apiService.get(
        ApiConfig.mediaFilterPaged,
        queryParameters: request.toQueryParams(),
      );

      return PagedResponse.fromJson(
        response.data,
        (json) => Media.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GroupedMediaResponse>> getGroupedMedia(MediaFilterRequest request) async {
    try {
      final response = await _apiService.get(
        ApiConfig.mediaGrouped,
        queryParameters: request.toQueryParams(),
      );

      final List<dynamic> data = response.data is List 
          ? response.data 
          : response.data['content'] ?? [];
      return data.map((json) => GroupedMediaResponse.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<PagedResponse<GroupedMediaResponse>> getGroupedMediaPaged(MediaFilterRequest request) async {
    try {
      final response = await _apiService.get(
        ApiConfig.mediaGroupedPaged,
        queryParameters: request.toQueryParams(),
      );

      return PagedResponse.fromJson(
        response.data,
        (json) => GroupedMediaResponse.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Media>> getMediaByTags(List<String> tagNames, {
    String? sortBy,
    String? sortDirection,
    int? page,
    int? size,
  }) async {
    try {
      final queryParams = <String, String>{
        'tagNames': tagNames.join(','),
      };

      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortDirection != null) queryParams['sortDirection'] = sortDirection;
      if (page != null) queryParams['page'] = page.toString();
      if (size != null) queryParams['size'] = size.toString();

      final response = await _apiService.get(
        ApiConfig.mediaByTags,
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

  Future<PagedResponse<Media>> getMediaByTagsPaged(List<String> tagNames, {
    String? sortBy,
    String? sortDirection,
    int? page,
    int? size,
  }) async {
    try {
      final queryParams = <String, String>{
        'tagNames': tagNames.join(','),
      };

      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortDirection != null) queryParams['sortDirection'] = sortDirection;
      if (page != null) queryParams['page'] = page.toString();
      if (size != null) queryParams['size'] = size.toString();

      final response = await _apiService.get(
        ApiConfig.mediaByTagsPaged,
        queryParameters: queryParams,
      );

      return PagedResponse.fromJson(
        response.data,
        (json) => Media.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Media>> searchMedia(String query, {
    String? sortBy,
    String? sortDirection,
    int? page,
    int? size,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
      };

      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortDirection != null) queryParams['sortDirection'] = sortDirection;
      if (page != null) queryParams['page'] = page.toString();
      if (size != null) queryParams['size'] = size.toString();

      final response = await _apiService.get(
        ApiConfig.mediaSearch,
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

  Future<PagedResponse<Media>> searchMediaPaged(String query, {
    String? sortBy,
    String? sortDirection,
    int? page,
    int? size,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
      };

      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortDirection != null) queryParams['sortDirection'] = sortDirection;
      if (page != null) queryParams['page'] = page.toString();
      if (size != null) queryParams['size'] = size.toString();

      final response = await _apiService.get(
        ApiConfig.mediaSearchPaged,
        queryParameters: queryParams,
      );

      return PagedResponse.fromJson(
        response.data,
        (json) => Media.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaStatsResponse> getMediaStats() async {
    try {
      final response = await _apiService.get(ApiConfig.mediaStats);
      return MediaStatsResponse.fromJson(response.data);
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
