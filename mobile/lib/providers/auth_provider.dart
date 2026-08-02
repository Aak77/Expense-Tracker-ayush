import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:fintrack_mobile/core/network/api_client.dart';
import 'package:fintrack_mobile/core/network/api_constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  bool _isLoading = true;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;

  AuthProvider({required ApiClient apiClient, required FlutterSecureStorage storage})
      : _apiClient = apiClient,
        _storage = storage {
    _checkAuthStatus();
  }

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  ApiClient get apiClient => _apiClient;

  Future<void> _checkAuthStatus() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      try {
        await _fetchUserProfile();
        _isAuthenticated = true;
      } catch (e) {
        _isAuthenticated = false;
        await _storage.deleteAll();
      }
    } else {
      _isAuthenticated = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchUserProfile() async {
    final response = await _apiClient.dio.get(ApiConstants.me);
    _user = response.data;
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      
      final access = response.data['access_token'];
      final refresh = response.data['refresh_token'];
      
      await _storage.write(key: 'access_token', value: access);
      await _storage.write(key: 'refresh_token', value: refresh);
      
      await _fetchUserProfile();
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return null; // success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Login error details: $e");
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data is Map) {
          final detail = e.response?.data['detail'];
          if (detail != null) return detail.toString();
        }
        return 'Network error: ${e.message}';
      }
      return e.toString();
    }
  }

  /// Register a new user and auto-login on success.
  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );

      final access = response.data['access_token'];
      final refresh = response.data['refresh_token'];

      await _storage.write(key: 'access_token', value: access);
      await _storage.write(key: 'refresh_token', value: refresh);

      await _fetchUserProfile();
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return null; // success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Try to extract a useful error message
      if (e is DioException && e.response != null) {
        final data = e.response?.data;
        if (data is Map && data['detail'] != null) {
          return data['detail'].toString();
        }
      }
      return 'Registration failed. Please try again.';
    }
  }

  Future<void> logout() async {
    try {
      final refresh = await _storage.read(key: 'refresh_token');
      if (refresh != null) {
        await _apiClient.dio.post(
          ApiConstants.logout,
          data: {'refresh_token': refresh},
        );
      }
    } catch (_) {}
    
    await _storage.deleteAll();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
