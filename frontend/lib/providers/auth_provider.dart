import 'package:flutter/foundation.dart';
import 'dart:async';
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
  Timer? _authCheckTimer;

  bool get isAuthenticated {
    final authenticated = _token != null && _token!.isNotEmpty;
    debugPrint('AuthProvider: isAuthenticated = $authenticated, token = ${_token?.substring(0, _token!.length > 10 ? 10 : _token!.length)}...');
    return authenticated;
  }
  String? get token => _token;
  String? get username => _username;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadStoredAuth();
    _startAuthStateCheck();
  }

  /// Start periodic check for authentication state changes
  void _startAuthStateCheck() {
    _authCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_token != null) {
        final prefs = await SharedPreferences.getInstance();
        final storedToken = prefs.getString(_tokenKey);
        
        // If stored token was cleared externally, update our state
        if (storedToken == null && _token != null) {
          debugPrint('AuthProvider: Token was cleared externally, logging out');
          _token = null;
          _username = null;
          notifyListeners();
        }
      }
    });
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      _username = prefs.getString(_usernameKey);
      debugPrint('AuthProvider: Loaded stored auth - username: $_username, hasToken: ${_token != null}');
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
    debugPrint('AuthProvider: Logging out user');
    _token = null;
    _username = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    
    notifyListeners();
  }

  /// Refresh authentication state from storage (useful when tokens are cleared externally)
  Future<void> refreshAuthState() async {
    debugPrint('AuthProvider: Refreshing authentication state');
    await _loadStoredAuth();
  }

  /// Check if stored token is still valid by making an API call
  Future<bool> validateToken() async {
    if (!isAuthenticated) return false;
    
    try {
      // Try to make a simple API call to validate the token
      await _apiService.get('/auth/validate');
      return true;
    } catch (e) {
      debugPrint('AuthProvider: Token validation failed: $e');
      // Token is invalid, logout
      await logout();
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _authCheckTimer?.cancel();
    super.dispose();
  }
}
