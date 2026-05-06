import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';

/// Repository for admin-specific API calls.
class AdminRepository {
  AdminRepository(this._apiService);
  final ApiService _apiService;

  /// GET /api/v1/reports/school
  Future<Map<String, dynamic>> getSchoolReport() async {
    final response = await _apiService.dio.get('/reports/school');
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/v1/users
  Future<List<Map<String, dynamic>>> getUsers(
      {String? search, String? role}) async {
    final response = await _apiService.dio.get('/users',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (role != null) 'role': role,
        });
    return List<Map<String, dynamic>>.from(response.data['users'] as List);
  }

  /// POST /api/v1/users
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final response = await _apiService.dio.post('/users', data: data);
    return response.data['user'] as Map<String, dynamic>;
  }

  /// PATCH /api/v1/users/:id/deactivate
  Future<void> deactivateUser(String id) async {
    await _apiService.dio.patch('/users/$id/deactivate');
  }

  /// POST /api/v1/auth/reset-password
  Future<void> resetUserPassword(String userId) async {
    await _apiService.dio
        .post('/auth/reset-password', data: {'userId': userId});
  }

  /// GET /api/v1/classrooms
  Future<List<Map<String, dynamic>>> getClassrooms() async {
    final response = await _apiService.dio.get('/classrooms');
    return List<Map<String, dynamic>>.from(
        response.data['classrooms'] as List);
  }

  /// POST /api/v1/classrooms
  Future<Map<String, dynamic>> createClassroom(
      Map<String, dynamic> data) async {
    final response = await _apiService.dio.post('/classrooms', data: data);
    return response.data['classroom'] as Map<String, dynamic>;
  }

  /// DELETE /api/v1/classrooms/:id
  Future<void> deleteClassroom(String id) async {
    await _apiService.dio.delete('/classrooms/$id');
  }

  /// POST /api/v1/classrooms/:id/students
  Future<void> assignStudents(String classroomId, List<String> studentIds) async {
    await _apiService.dio.post('/classrooms/$classroomId/students',
        data: {'studentIds': studentIds});
  }

  // ─── Advanced School Reports (Req 19.2–19.4) ──────────────────────────────

  /// GET /api/v1/reports/school/comparison
  /// Returns classroom comparison data: averageScore, completionRate, topSkill.
  Future<List<Map<String, dynamic>>> getClassroomComparison({
    String? term,
    String? subject,
    String? gradeLevel,
  }) async {
    final response = await _apiService.dio.get(
      '/reports/school/comparison',
      queryParameters: {
        if (term != null && term.isNotEmpty) 'term': term,
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (gradeLevel != null && gradeLevel.isNotEmpty) 'gradeLevel': gradeLevel,
      },
    );
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return List<Map<String, dynamic>>.from(
        (data['classrooms'] ?? data['data'] ?? []) as List);
  }

  /// GET /api/v1/reports/school/longitudinal
  /// Returns monthly trend data: classroomId, classroomName, month, averageScore.
  Future<List<Map<String, dynamic>>> getLongitudinalReport({
    String? classroomId,
    String? subject,
  }) async {
    final response = await _apiService.dio.get(
      '/reports/school/longitudinal',
      queryParameters: {
        if (classroomId != null && classroomId.isNotEmpty) 'classroomId': classroomId,
        if (subject != null && subject.isNotEmpty) 'subject': subject,
      },
    );
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return List<Map<String, dynamic>>.from(
        (data['trends'] ?? data['data'] ?? []) as List);
  }

  /// GET /api/v1/reports/school/weaknesses
  /// Returns top 5 weakest skills school-wide: mainSkill, averagePercentage.
  Future<List<Map<String, dynamic>>> getWeakestSkills({
    String? subject,
    String? gradeLevel,
  }) async {
    final response = await _apiService.dio.get(
      '/reports/school/weaknesses',
      queryParameters: {
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (gradeLevel != null && gradeLevel.isNotEmpty) 'gradeLevel': gradeLevel,
      },
    );
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return List<Map<String, dynamic>>.from(
        (data['skills'] ?? data['weakestSkills'] ?? data['data'] ?? []) as List);
  }
}

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiServiceProvider)),
);
