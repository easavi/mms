import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

      debugPrint('MediaService: Making API call with params: $queryParams');

      final response = await _apiService.get(
        ApiConfig.media,
        queryParameters: queryParams,
      );
      
      debugPrint('API Response type: ${response.data.runtimeType}');
      debugPrint('API Response: ${response.data}');
      
      final List<dynamic> data = response.data is List 
          ? response.data 
          : response.data['content'] ?? [];
      
      debugPrint('Processing ${data.length} media items');
      
      if (data.isEmpty) {
        debugPrint('No media items to process, returning empty list');
        return [];
      }
      
      // Debug first item structure
      if (data.isNotEmpty) {
        debugPrint('First item structure: ${data[0]}');
        debugPrint('First item type: ${data[0].runtimeType}');
      }
      
      return data.map((json) {
        try {
          debugPrint('Processing item: $json');
          return Media.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing media item: $e');
          debugPrint('JSON data: $json');
          rethrow;
        }
      }).toList();
    } catch (e) {
      debugPrint('MediaService getAllMedia error: $e');
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
    String? storageId,
    String? fileHash,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {
        'file': await MultipartFile.fromFile(filePath),
        'title': title,
        'mediaType': mediaType,
        'description': description ?? '',
        'tags': tags?.join(',') ?? '',
      };
      
      // Add storageId if provided
      if (storageId != null) {
        formDataMap['storageId'] = storageId;
      }
      
      // Add fileHash if provided
      if (fileHash != null) {
        formDataMap['fileHash'] = fileHash;
      }
      
      final formData = FormData.fromMap(formDataMap);

      final response = await _apiService.uploadFile(
        ApiConfig.mediaUpload,
        formData,
      );
      
      return Media.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Check if a file with the given hash already exists
  Future<bool> checkFileHashExists(String fileHash) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.media}/hash/$fileHash/exists',
      );
      
      return response.data['exists'] ?? false;
    } catch (e) {
      // If we get a 404 or any error, assume file doesn't exist
      debugPrint('Error checking file hash existence: $e');
      return false;
    }
  }

  /// Get media by file hash
  Future<Media?> getMediaByHash(String fileHash) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.media}/hash/$fileHash',
      );
      
      return Media.fromJson(response.data);
    } catch (e) {
      // If we get a 404 or any error, return null
      debugPrint('Error getting media by hash: $e');
      return null;
    }
  }

  /// Get the full URL for a media thumbnail by ID
  String getThumbnailUrlById(String mediaId) {
    return ApiConfig.getFullUrl('${ApiConfig.mediaThumbnail}$mediaId');
  }

  /// Get the full URL for a media thumbnail by bucket and file ID
  String getThumbnailUrlByBucketAndFileId(String bucket, String fileId) {
    return '${ApiConfig.getFullUrl(ApiConfig.mediaThumbnailByBucket)}?bucket=$bucket&fileId=$fileId';
  }

  /// Get the full thumbnail URL for a media item (convenience method)
  String? getFullThumbnailUrl(Media media) {
    final thumbnailPath = media.thumbnailUrlFromFileUrl;
    if (thumbnailPath != null) {
      return ApiConfig.getFullUrl(thumbnailPath);
    }
    return null;
  }

  /// Check if a media item has a thumbnail (only images have thumbnails)
  bool hasThumbnail(Media media) {
    return media.isImage;
  }
}
