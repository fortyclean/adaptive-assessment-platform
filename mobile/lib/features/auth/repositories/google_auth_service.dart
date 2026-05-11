import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/providers/auth_provider.dart';

/// Google Sign-In service — authenticates with Google then exchanges
/// the ID token with the backend for a JWT session.
class GoogleAuthService {
  GoogleAuthService(this._apiService);

  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web Client ID — required for backend token verification
    serverClientId: '444318033747-bsfncs58b51o9bda3491lnphnt1qh94c.apps.googleusercontent.com',
  );

  /// Signs in with Google and exchanges the token with the backend.
  /// Returns the authenticated user and access token.
  Future<({AuthUser user, String accessToken})> signInWithGoogle() async {
    // Trigger Google sign-in flow
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('تم إلغاء تسجيل الدخول بـ Google');
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception('فشل الحصول على رمز Google');
    }

    // Exchange Google ID token with backend
    final response = await _apiService.dio.post(
      '/auth/google',
      data: {'idToken': idToken},
    );

    final data = response.data as Map<String, dynamic>;
    if (response.statusCode == 202 || data['status'] == 'pending_approval') {
      throw Exception('pending_approval');
    }
    final accessToken = data['accessToken'] as String;
    final user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);

    // Persist session
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

  /// Signs out from Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

final googleAuthServiceProvider = Provider<GoogleAuthService>(
  (ref) => GoogleAuthService(ref.watch(apiServiceProvider)),
);
