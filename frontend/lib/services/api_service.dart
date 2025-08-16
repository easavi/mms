import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Temporarily commented out
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  late final Dio _dio;
  // final _storage = const FlutterSecureStorage(); // Temporarily commented out

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add JWT token to requests if available
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
          // Handle unauthorized/forbidden access - clear stored token
          debugPrint('ApiService: Authentication error (${error.response?.statusCode}), clearing tokens');
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          await prefs.remove('username');
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      debugPrint('ApiService: Making GET request to $path with params: $queryParameters');
      final response = await _dio.get(path, queryParameters: queryParameters);
      debugPrint('ApiService: Response status: ${response.statusCode}');
      debugPrint('ApiService: Response data type: ${response.data.runtimeType}');
      return response;
    } on DioException catch (e) {
      debugPrint('ApiService: DioException - $e');
      _handleError(e);
      rethrow;
    } catch (e) {
      debugPrint('ApiService: General exception - $e');
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> uploadFile(String path, FormData formData) async {
    try {
      return await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioException error) {
    if (error.response != null) {
      String message = 'An error occurred';
      
      // Check if response data is a Map and contains a message
      if (error.response?.data is Map<String, dynamic>) {
        final data = error.response?.data as Map<String, dynamic>;
        message = data['message'] ?? 'An error occurred';
      } else if (error.response?.data is String) {
        // If response data is a string, use it directly
        message = error.response?.data as String;
      }
      
      debugPrint('ApiService: Error response - Status: ${error.response?.statusCode}, Data type: ${error.response?.data.runtimeType}, Data: ${error.response?.data}');
      throw Exception(message);
    } else {
      debugPrint('ApiService: Network error - ${error.message}');
      throw Exception('Network error occurred');
    }
  }
}
