import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class UserService {
  final _apiService = ApiService();

  // Basic CRUD operations
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _apiService.get(ApiConfig.users);
      final List<dynamic> data = response.data is List 
          ? response.data 
          : response.data['content'] ?? [];
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getUserById(String id) async {
    try {
      final response = await _apiService.get('${ApiConfig.userById}$id');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getUserByEmail(String email) async {
    try {
      final response = await _apiService.get('${ApiConfig.userByEmail}$email');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> createUser(CreateUserRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConfig.users,
        data: request.toJson(),
      );
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateUser(String id, UpdateUserRequest request) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.userById}$id',
        data: request.toJson(),
      );
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _apiService.delete('${ApiConfig.userById}$id');
    } catch (e) {
      rethrow;
    }
  }

  // Search users
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await _apiService.get(
        ApiConfig.users,
        queryParameters: {'search': query},
      );
      final List<dynamic> data = response.data is List 
          ? response.data 
          : response.data['content'] ?? [];
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
