import 'dart:convert';
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
    final response = await _apiService.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'username': username, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);

    // Persist tokens and user data for offline session restore
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    await _storage.write(
        key: AppConstants.userDataKey, value: jsonEncode(user.toJson()));
    if (data['refreshToken'] != null) {
      await _storage.write(
          key: AppConstants.refreshTokenKey,
          value: data['refreshToken'] as String);
    }

    _apiService.setToken(accessToken);
    return (user: user, accessToken: accessToken);
  }

  /// POST /api/v1/auth/register (student/teacher pending approval)
  Future<void> registerAccount({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    await _apiService.dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'fullName': fullName,
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      },
    );
  }

  /// POST /api/v1/auth/logout
  Future<void> logout() async {
    try {
      await _apiService.dio.post<Map<String, dynamic>>('/auth/logout');
    } on DioException {
      // Best-effort logout
    } finally {
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
      await _storage.delete(key: AppConstants.userDataKey);
      _apiService.clearToken();
    }
  }

  /// POST /api/v1/auth/reset-password
  Future<void> requestPasswordReset(String email) async {
    await _apiService.dio.post<Map<String, dynamic>>(
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
      final response =
          await _apiService.dio.get<Map<String, dynamic>>('/auth/me');
      final body = response.data ?? <String, dynamic>{};
      return AuthUser.fromJson(body['user'] as Map<String, dynamic>);
    } on DioException {
      await _storage.delete(key: AppConstants.accessTokenKey);
      _apiService.clearToken();
      return null;
    }
  }

  /// PATCH /api/v1/users/:id — update the user's full name.
  Future<void> updateProfile({
    required String userId,
    required String name,
  }) async {
    await _apiService.dio.patch<Map<String, dynamic>>(
      '/users/$userId',
      data: {'fullName': name},
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiServiceProvider)),
);
