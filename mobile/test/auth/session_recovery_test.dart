import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:adaptive_assessment/core/constants/app_constants.dart';
import 'package:adaptive_assessment/core/network/api_service.dart';
import 'package:adaptive_assessment/features/auth/repositories/auth_repository.dart';
import 'package:adaptive_assessment/shared/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _SessionAdapter implements HttpClientAdapter {
  _SessionAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Map<String, dynamic> body, int statusCode) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

Map<String, dynamic> _studentJson() => {
      '_id': 'offline-student-1',
      'username': 'offline.student',
      'fullName': 'طالب محفوظ',
      'email': 'offline.student@example.edu',
      'role': 'student',
      'classroomIds': ['class-a'],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApiService apiService;
  late HttpClientAdapter originalAdapter;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    apiService = ApiService.instance;
    originalAdapter = apiService.dio.httpClientAdapter;
    apiService.clearToken();
  });

  tearDown(() {
    apiService.dio.httpClientAdapter = originalAdapter;
    apiService.clearToken();
  });

  group('AuthRepository session recovery', () {
    test('restores the cached user when /auth/me is unavailable offline',
        () async {
      const storage = FlutterSecureStorage();
      await storage.write(
        key: AppConstants.accessTokenKey,
        value: 'cached-access-token',
      );
      await storage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(_studentJson()),
      );

      final adapter = _SessionAdapter((options) async {
        expect(options.path, '/auth/me');
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const SocketException('offline'),
        );
      });
      apiService.dio.httpClientAdapter = adapter;

      final user = await AuthRepository(apiService).restoreSession();

      expect(user, isNotNull);
      expect(user!.id, 'offline-student-1');
      expect(user.role, UserRole.student);
      expect(await storage.read(key: AppConstants.accessTokenKey),
          'cached-access-token');
      expect(apiService.dio.options.headers['Authorization'],
          'Bearer cached-access-token');
    });

    test('refreshes an expired token and returns the live user', () async {
      const storage = FlutterSecureStorage();
      await storage.write(
        key: AppConstants.accessTokenKey,
        value: 'expired-access-token',
      );
      await storage.write(
        key: AppConstants.refreshTokenKey,
        value: 'valid-refresh-token',
      );
      await storage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(_studentJson()),
      );

      var meCalls = 0;
      final adapter = _SessionAdapter((options) async {
        if (options.path == '/auth/me') {
          meCalls += 1;
          if (meCalls == 1) {
            return _jsonBody({'status': 'unauthorized'}, 401);
          }
          return _jsonBody(
            {
              'user': {
                ..._studentJson(),
                '_id': 'live-student-1',
                'fullName': 'طالب مباشر',
              },
            },
            200,
          );
        }

        if (options.path == '/auth/refresh') {
          return _jsonBody(
            {
              'accessToken': 'fresh-access-token',
              'refreshToken': 'fresh-refresh-token',
            },
            200,
          );
        }

        fail('Unexpected request: ${options.method} ${options.path}');
      });
      apiService.dio.httpClientAdapter = adapter;

      final user = await AuthRepository(apiService).restoreSession();

      expect(user, isNotNull);
      expect(user!.id, 'live-student-1');
      expect(meCalls, 2);
      expect(await storage.read(key: AppConstants.accessTokenKey),
          'fresh-access-token');
      expect(await storage.read(key: AppConstants.refreshTokenKey),
          'fresh-refresh-token');
    });

    test('clears the session when token refresh is rejected', () async {
      const storage = FlutterSecureStorage();
      await storage.write(
        key: AppConstants.accessTokenKey,
        value: 'expired-access-token',
      );
      await storage.write(
        key: AppConstants.refreshTokenKey,
        value: 'expired-refresh-token',
      );
      await storage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(_studentJson()),
      );

      final adapter = _SessionAdapter((options) async {
        if (options.path == '/auth/me') {
          return _jsonBody({'status': 'unauthorized'}, 401);
        }
        if (options.path == '/auth/refresh') {
          return _jsonBody({'status': 'unauthorized'}, 401);
        }
        fail('Unexpected request: ${options.method} ${options.path}');
      });
      apiService.dio.httpClientAdapter = adapter;

      final user = await AuthRepository(apiService).restoreSession();

      expect(user, isNull);
      expect(await storage.read(key: AppConstants.accessTokenKey), isNull);
      expect(await storage.read(key: AppConstants.refreshTokenKey), isNull);
      expect(apiService.dio.options.headers['Authorization'], isNull);
    });
  });
}
