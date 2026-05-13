import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Core Dio HTTP client with JWT interceptor and error handling.
/// Requirements: 12.4, 20.5
class ApiService {
  ApiService._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Platform': 'mobile',
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
    _dio.interceptors.add(LogInterceptor());
  }

  static final ApiService _instance = ApiService._();
  static ApiService get instance => _instance;

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Dio get dio => _dio;

  /// Sets the Authorization header for all subsequent requests.
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clears the Authorization header on logout.
  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }
}

/// Interceptor that attaches the JWT token and handles 401 auto-refresh.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage, this._dio);

  final FlutterSecureStorage _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken =
            await _storage.read(key: AppConstants.refreshTokenKey);
        if (refreshToken == null) {
          _isRefreshing = false;
          handler.next(err);
          return;
        }

        // Attempt token refresh
        final response = await _dio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
          options: Options(headers: {'Authorization': null}),
        );

        final responseData = response.data;
        final newToken = responseData?['accessToken'] as String?;
        if (newToken != null) {
          await _storage.write(
              key: AppConstants.accessTokenKey, value: newToken);
          final newRefreshToken = responseData?['refreshToken'] as String?;
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _storage.write(
                key: AppConstants.refreshTokenKey, value: newRefreshToken);
          }

          // Retry original request with new token
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse =
              await _dio.fetch<Map<String, dynamic>>(retryOptions);
          _isRefreshing = false;
          handler.resolve(retryResponse);
          return;
        }
      } on Object {
        // Refresh failed — clear tokens and let the error propagate
        await _storage.delete(key: AppConstants.accessTokenKey);
        await _storage.delete(key: AppConstants.refreshTokenKey);
      }
      _isRefreshing = false;
    }
    handler.next(err);
  }
}

/// Provider for the ApiService singleton.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService.instance);
