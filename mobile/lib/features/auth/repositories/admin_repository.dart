import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';

/// Repository for admin-specific API calls.
class AdminRepository {
  AdminRepository(this._apiService);
  final ApiService _apiService;

  /// GET /api/v1/reports/school
  Future<Map<String, dynamic>> getSchoolReport() async {
    final response =
        await _apiService.dio.get<Map<String, dynamic>>('/reports/school');
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/v1/reports/school/export
  Future<Map<String, dynamic>> exportSchoolReport({
    String? subject,
    String? gradeLevel,
  }) async {
    final response = await _apiService.dio.get<Map<String, dynamic>>(
      '/reports/school/export',
      queryParameters: {
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (gradeLevel != null && gradeLevel.isNotEmpty)
          'gradeLevel': gradeLevel,
      },
    );
    return response.data ?? <String, dynamic>{};
  }

  /// GET /api/v1/institution-settings
  Future<Map<String, dynamic>> getInstitutionSettings() async {
    final response = await _apiService.dio
        .get<Map<String, dynamic>>('/institution-settings');
    final body = response.data ?? <String, dynamic>{};
    return (body['settings'] as Map<String, dynamic>?) ?? body;
  }

  /// PATCH /api/v1/institution-settings
  Future<Map<String, dynamic>> updateInstitutionSettings(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.dio.patch<Map<String, dynamic>>(
      '/institution-settings',
      data: data,
    );
    final body = response.data ?? <String, dynamic>{};
    return (body['settings'] as Map<String, dynamic>?) ?? body;
  }

  /// GET /api/v1/users
  Future<List<Map<String, dynamic>>> getUsers(
      {String? search, String? role, bool? isActive}) async {
    final response = await _apiService.dio
        .get<Map<String, dynamic>>('/users', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (role != null) 'role': role,
      if (isActive != null) 'isActive': isActive.toString(),
    });
    final body = response.data ?? <String, dynamic>{};
    return List<Map<String, dynamic>>.from(
        (body['users'] ?? <dynamic>[]) as List);
  }

  /// POST /api/v1/users
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final response =
        await _apiService.dio.post<Map<String, dynamic>>('/users', data: data);
    final body = response.data ?? <String, dynamic>{};
    return (body['user'] as Map<String, dynamic>?) ?? body;
  }

  /// PATCH /api/v1/users/:id
  Future<Map<String, dynamic>> updateUser(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.dio
        .patch<Map<String, dynamic>>('/users/$id', data: data);
    final body = response.data ?? <String, dynamic>{};
    return (body['user'] as Map<String, dynamic>?) ?? body;
  }

  /// PATCH /api/v1/users/:id/deactivate
  Future<void> deactivateUser(String id) async {
    await _apiService.dio.patch<Map<String, dynamic>>('/users/$id/deactivate');
  }

  /// PATCH /api/v1/users/:id/reactivate
  Future<void> reactivateUser(String id) async {
    await _apiService.dio.patch<Map<String, dynamic>>('/users/$id/reactivate');
  }

  /// POST /api/v1/auth/reset-password
  Future<void> resetUserPassword(String userId) async {
    await _apiService.dio.post<Map<String, dynamic>>('/auth/reset-password',
        data: {'userId': userId});
  }

  /// GET /api/v1/classrooms
  Future<List<Map<String, dynamic>>> getClassrooms() async {
    try {
      final response =
          await _apiService.dio.get<Map<String, dynamic>>('/classrooms');
      return _parseClassroomsResponse(response.data);
    } on DioException {
      final response =
          await _apiService.dio.get<Map<String, dynamic>>('/admin/classrooms');
      return _parseClassroomsResponse(response.data);
    }
  }

  /// POST /api/v1/classrooms
  Future<Map<String, dynamic>> createClassroom(
      Map<String, dynamic> data) async {
    final response = await _apiService.dio
        .post<Map<String, dynamic>>('/classrooms', data: data);
    final body = response.data;
    if (body is Map<String, dynamic> &&
        body['classroom'] is Map<String, dynamic>) {
      return body['classroom'] as Map<String, dynamic>;
    }
    if (body is Map<String, dynamic>) {
      return body;
    }
    return data;
  }

  List<Map<String, dynamic>> _parseClassroomsResponse(dynamic data) {
    List<Map<String, dynamic>> normalizeList(List<dynamic> items) => items
        .whereType<Map<String, dynamic>>()
        .map(_normalizeClassroom)
        .toList();

    if (data is List) {
      return normalizeList(data);
    }
    if (data is Map<String, dynamic>) {
      final directClassrooms = data['classrooms'];
      if (directClassrooms is List) {
        return normalizeList(directClassrooms);
      }

      final nestedData = data['data'];
      if (nestedData is List) {
        return normalizeList(nestedData);
      }
      if (nestedData is Map<String, dynamic>) {
        final nestedClassrooms = nestedData['classrooms'];
        if (nestedClassrooms is List) {
          return normalizeList(nestedClassrooms);
        }
      }
    }
    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _normalizeClassroom(Map<String, dynamic> classroom) {
    final normalized = Map<String, dynamic>.from(classroom);
    normalized['activeAssessments'] =
        normalized['activeAssessments'] ?? normalized['activeAssessmentCount'];

    final teacherIds = normalized['teacherIds'];
    if (teacherIds is List && teacherIds.isNotEmpty) {
      final firstTeacher = teacherIds.first;
      if (firstTeacher is Map<String, dynamic>) {
        normalized['teacherId'] = firstTeacher['_id'] ?? firstTeacher['id'];
        normalized['teacherName'] =
            firstTeacher['fullName'] ?? firstTeacher['username'];
      }
    }

    normalized['studentIds'] = normalized['studentIds'] ?? <dynamic>[];
    return normalized;
  }

  /// DELETE /api/v1/classrooms/:id
  Future<void> deleteClassroom(String id) async {
    await _apiService.dio.delete<Map<String, dynamic>>('/classrooms/$id');
  }

  /// PATCH /api/v1/classrooms/:id
  Future<Map<String, dynamic>> updateClassroom(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.dio
        .patch<Map<String, dynamic>>('/classrooms/$id', data: data);
    final body = response.data;
    if (body is Map<String, dynamic> &&
        body['classroom'] is Map<String, dynamic>) {
      return body['classroom'] as Map<String, dynamic>;
    }
    return body is Map<String, dynamic> ? body : data;
  }

  /// POST /api/v1/classrooms/:id/students
  Future<void> assignStudents(
      String classroomId, List<String> studentIds) async {
    await _apiService.dio.post<Map<String, dynamic>>(
        '/classrooms/$classroomId/students',
        data: {'userIds': studentIds});
  }

  /// POST /api/v1/classrooms/:id/teachers
  Future<void> assignTeachers(
      String classroomId, List<String> teacherIds) async {
    await _apiService.dio.post<Map<String, dynamic>>(
        '/classrooms/$classroomId/teachers',
        data: {'userIds': teacherIds});
  }

  // ─── Advanced School Reports (Req 19.2–19.4) ──────────────────────────────

  /// GET /api/v1/reports/school/comparison
  /// Returns classroom comparison data: averageScore, completionRate, topSkill.
  Future<List<Map<String, dynamic>>> getClassroomComparison({
    String? term,
    String? subject,
    String? gradeLevel,
  }) async {
    final response = await _apiService.dio.get<dynamic>(
      '/reports/school/comparison',
      queryParameters: {
        if (term != null && term.isNotEmpty) 'term': term,
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (gradeLevel != null && gradeLevel.isNotEmpty)
          'gradeLevel': gradeLevel,
      },
    );
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    final mapData = data is Map<String, dynamic> ? data : <String, dynamic>{};
    return List<Map<String, dynamic>>.from(
      (mapData['classrooms'] ?? mapData['data'] ?? <dynamic>[]) as List,
    );
  }

  /// GET /api/v1/reports/school/longitudinal
  /// Returns monthly trend data: classroomId, classroomName, month, averageScore.
  Future<List<Map<String, dynamic>>> getLongitudinalReport({
    String? classroomId,
    String? subject,
  }) async {
    final response = await _apiService.dio.get<dynamic>(
      '/reports/school/longitudinal',
      queryParameters: {
        if (classroomId != null && classroomId.isNotEmpty)
          'classroomId': classroomId,
        if (subject != null && subject.isNotEmpty) 'subject': subject,
      },
    );
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    final mapData = data is Map<String, dynamic> ? data : <String, dynamic>{};
    return List<Map<String, dynamic>>.from(
      (mapData['trends'] ?? mapData['data'] ?? <dynamic>[]) as List,
    );
  }

  /// GET /api/v1/reports/school/weaknesses
  /// Returns top 5 weakest skills school-wide: mainSkill, averagePercentage.
  Future<List<Map<String, dynamic>>> getWeakestSkills({
    String? subject,
    String? gradeLevel,
  }) async {
    final response = await _apiService.dio.get<dynamic>(
      '/reports/school/weaknesses',
      queryParameters: {
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (gradeLevel != null && gradeLevel.isNotEmpty)
          'gradeLevel': gradeLevel,
      },
    );
    final data = response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    final mapData = data is Map<String, dynamic> ? data : <String, dynamic>{};
    return List<Map<String, dynamic>>.from(
      (mapData['skills'] ??
          mapData['weakestSkills'] ??
          mapData['data'] ??
          <dynamic>[]) as List,
    );
  }

  // ─── Report Schedules (Req 26.1) ──────────────────────────────────────────

  /// GET /api/v1/report-schedules
  Future<List<Map<String, dynamic>>> getReportSchedules() async {
    final response =
        await _apiService.dio.get<Map<String, dynamic>>('/report-schedules');
    final body = response.data ?? <String, dynamic>{};
    return List<Map<String, dynamic>>.from(
      (body['schedules'] ?? <dynamic>[]) as List,
    );
  }

  /// POST /api/v1/report-schedules
  Future<Map<String, dynamic>> createReportSchedule(
      Map<String, dynamic> data) async {
    final response = await _apiService.dio
        .post<Map<String, dynamic>>('/report-schedules', data: data);
    final body = response.data ?? <String, dynamic>{};
    return (body['schedule'] as Map<String, dynamic>?) ?? body;
  }

  /// DELETE /api/v1/report-schedules/:id
  Future<void> deleteReportSchedule(String id) async {
    await _apiService.dio.delete<Map<String, dynamic>>('/report-schedules/$id');
  }

  /// PATCH /api/v1/report-schedules/:id/toggle
  Future<void> toggleReportSchedule(String id) async {
    await _apiService.dio
        .patch<Map<String, dynamic>>('/report-schedules/$id/toggle');
  }
}

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiServiceProvider)),
);
