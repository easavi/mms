import '../config/api_config.dart';
import 'api_service.dart';

class SystemService {
  final _apiService = ApiService();

  // Validation endpoints
  Future<Map<String, dynamic>> validateSystem() async {
    try {
      final response = await _apiService.get(ApiConfig.validation);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _apiService.get(ApiConfig.validationHealth);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkFeatures() async {
    try {
      final response = await _apiService.get(ApiConfig.validationFeatures);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Demo endpoints
  Future<Map<String, dynamic>> getDemoStatus() async {
    try {
      final response = await _apiService.get(ApiConfig.demo);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createDemoData() async {
    try {
      final response = await _apiService.post(ApiConfig.demoCreate);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> clearDemoData() async {
    try {
      final response = await _apiService.delete(ApiConfig.demoClear);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // API Info
  Future<Map<String, dynamic>> getApiInfo() async {
    try {
      final response = await _apiService.get(ApiConfig.apiInfo);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
