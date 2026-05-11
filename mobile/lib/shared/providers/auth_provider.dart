import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User roles matching the backend RBAC system.
enum UserRole { admin, teacher, student }

/// Represents the authenticated user's data.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    this.classroomIds = const [],
  });

  final String id;
  final String username;
  final String fullName;
  final String email;
  final UserRole role;
  final List<String> classroomIds;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['_id'] as String,
        username: json['username'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        role: UserRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => UserRole.student,
        ),
        classroomIds: (json['classroomIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'username': username,
        'fullName': fullName,
        'email': email,
        'role': role.name,
        'classroomIds': classroomIds,
      };
}

/// Authentication state for the app.
class AuthState {
  const AuthState({
    this.user,
    this.accessToken,
    this.isLoading = false,
    this.error,
  });

  final AuthUser? user;
  final String? accessToken;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null && accessToken != null;

  AuthState copyWith({
    AuthUser? user,
    String? accessToken,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        accessToken: clearUser ? null : (accessToken ?? this.accessToken),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

/// Riverpod notifier for authentication state management.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void setUser(AuthUser user, String accessToken) {
    state = state.copyWith(
      user: user,
      accessToken: accessToken,
      isLoading: false,
      clearError: true,
    );
  }

  void setLoading({bool loading = true}) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void logout() {
    state = const AuthState();
  }

  void updateName(String name) {
    if (state.user == null) return;
    final updatedUser = AuthUser(
      id: state.user!.id,
      username: state.user!.username,
      fullName: name,
      email: state.user!.email,
      role: state.user!.role,
      classroomIds: state.user!.classroomIds,
    );
    state = state.copyWith(user: updatedUser);
  }
}

/// Global auth state provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// Convenience provider to get the current user.
final currentUserProvider = Provider<AuthUser?>(
  (ref) => ref.watch(authProvider).user,
);

/// Convenience provider to check if user is authenticated.
final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).isAuthenticated,
);
