import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Temporarily commented out
import 'package:shared_preferences/shared_preferences.dart';
import '../services/services.dart';

class AuthProvider extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  
  final ApiService _apiService = ApiService();
  // final FlutterSecureStorage _storage = const FlutterSecureStorage(); // Temporarily commented out
  
  String? _token;
  String? _username;
  bool _isLoading = false;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  String? get token => _token;
  String? get username => _username;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      _username = prefs.getString(_usernameKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading stored auth: $e');
    }
  }

  Future<void> login(String username, String password) async {
    _setLoading(true);
    
    try {
      final response = await _apiService.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      _token = response.data['token'];
      _username = response.data['username'] ?? username;

      // Store credentials securely
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_usernameKey, _username!);

      notifyListeners();
    } catch (e) {
      _token = null;
      _username = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_usernameKey);
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup(String username, String email, String password) async {
    _setLoading(true);
    
    try {
      final response = await _apiService.post('/auth/signup', data: {
        'username': username,
        'email': email,
        'password': password,
      });

      _token = response.data['token'];
      _username = response.data['username'] ?? username;

      // Store credentials securely
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_usernameKey, _username!);

      notifyListeners();
    } catch (e) {
      _token = null;
      _username = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_usernameKey);
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _token = null;
    _username = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
