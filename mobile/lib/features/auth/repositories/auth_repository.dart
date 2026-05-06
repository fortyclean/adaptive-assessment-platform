import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/providers/auth_provider.dart';

/// Repository for authentication API calls.
class AuthRepository {
  AuthRepository(this._apiService);

  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// POST /api/v1/auth/login
  Future<({AuthUser user, String accessToken})> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiService.dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);

    // Persist tokens
    await _storage.write(
        key: AppConstants.accessTokenKey, value: accessToken);
    if (data['refreshToken'] != null) {
      await _storage.write(
          key: AppConstants.refreshTokenKey,
          value: data['refreshToken'] as String);
    }

    _apiService.setToken(accessToken);
    return (user: user, accessToken: accessToken);
  }

  /// POST /api/v1/auth/logout
  Future<void> logout() async {
    try {
      await _apiService.dio.post('/auth/logout');
    } catch (_) {
      // Best-effort logout
    } finally {
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
      _apiService.clearToken();
    }
  }

  /// POST /api/v1/auth/reset-password
  Future<void> requestPasswordReset(String email) async {
    await _apiService.dio.post(
      '/auth/reset-password',
      data: {'email': email},
    );
  }

  /// Restore session from secure storage on app start.
  Future<AuthUser?> restoreSession() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token == null) return null;

    try {
      _apiService.setToken(token);
      final response = await _apiService.dio.get('/auth/me');
      return AuthUser.fromJson(
          response.data['user'] as Map<String, dynamic>);
    } on DioException {
      await _storage.delete(key: AppConstants.accessTokenKey);
      _apiService.clearToken();
      return null;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiServiceProvider)),
);
