import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';

/// Repository for teacher-specific API calls.
class TeacherRepository {
  TeacherRepository(this._apiService);
  final ApiService _apiService;

  /// GET /api/v1/assessments — teacher's assessments
  Future<List<Map<String, dynamic>>> getAssessments({String? status}) async {
    final response = await _apiService.dio.get<Map<String, dynamic>>(
        '/assessments',
        queryParameters: status != null ? {'status': status} : null);
    return List<Map<String, dynamic>>.from(
        (response.data?['assessments'] as List?) ?? const []);
  }

  /// POST /api/v1/assessments
  Future<Map<String, dynamic>> createAssessment(
      Map<String, dynamic> data) async {
    final response = await _apiService.dio
        .post<Map<String, dynamic>>('/assessments', data: data);
    return (response.data?['assessment'] as Map<String, dynamic>?) ?? {};
  }

  /// POST /api/v1/assessments/:id/publish
  Future<void> publishAssessment(String id) async {
    await _apiService.dio
        .post<Map<String, dynamic>>('/assessments/$id/publish');
  }

  /// GET /api/v1/questions
  Future<Map<String, dynamic>> getQuestions(
      {Map<String, dynamic>? filters, int page = 1}) async {
    final response = await _apiService.dio
        .get<Map<String, dynamic>>('/questions', queryParameters: {
      ...?filters,
      'page': page,
      'limit': 20,
    });
    return response.data ?? {};
  }

  /// POST /api/v1/questions
  Future<Map<String, dynamic>> createQuestion(Map<String, dynamic> data) async {
    final response = await _apiService.dio
        .post<Map<String, dynamic>>('/questions', data: data);
    return (response.data?['question'] as Map<String, dynamic>?) ?? {};
  }

  /// GET /api/v1/questions/quality-check
  Future<Map<String, dynamic>> getQualityCheck(
      {required String subject,
      required String gradeLevel,
      required String unit}) async {
    final response = await _apiService.dio.get<Map<String, dynamic>>(
        '/questions/quality-check',
        queryParameters: {
          'subject': subject,
          'gradeLevel': gradeLevel,
          'unit': unit,
        });
    return response.data ?? {};
  }

  /// GET /api/v1/reports/assessment/:id
  Future<Map<String, dynamic>> getAssessmentReport(String id) async {
    final response = await _apiService.dio
        .get<Map<String, dynamic>>('/reports/assessment/$id');
    return response.data ?? {};
  }

  /// GET /api/v1/reports/student/:id
  Future<Map<String, dynamic>> getStudentReport(String studentId,
      {String? assessmentId}) async {
    final response = await _apiService.dio.get<Map<String, dynamic>>(
        '/reports/student/$studentId',
        queryParameters:
            assessmentId != null ? {'assessmentId': assessmentId} : null);
    return response.data ?? {};
  }

  /// GET /api/v1/classrooms
  Future<List<Map<String, dynamic>>> getClassrooms() async {
    final response =
        await _apiService.dio.get<Map<String, dynamic>>('/classrooms');
    return List<Map<String, dynamic>>.from(
        (response.data?['classrooms'] as List?) ?? const []);
  }

  /// POST /api/v1/classrooms
  Future<Map<String, dynamic>> createClassroom(
      Map<String, dynamic> data) async {
    final response = await _apiService.dio
        .post<Map<String, dynamic>>('/classrooms', data: data);
    return (response.data?['classroom'] as Map<String, dynamic>?) ?? {};
  }

  /// GET /api/v1/reports/classroom/:id/certificates
  Future<Map<String, dynamic>> getClassroomCertificates(
      String classroomId) async {
    final response = await _apiService.dio.get<Map<String, dynamic>>(
        '/reports/classroom/$classroomId/certificates');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getAttemptForGrading(String attemptId) async {
    final response =
        await _apiService.dio.get<Map<String, dynamic>>('/attempts/$attemptId');
    return response.data ?? {};
  }

  /// POST /api/v1/attempts/:id/grade — submit essay grades
  Future<void> submitEssayGrades(
      String attemptId, Map<String, int> scores) async {
    await _apiService.dio
        .post<Map<String, dynamic>>('/attempts/$attemptId/grade', data: {
      'scores': scores.map(MapEntry.new),
    });
  }

  /// GET /api/v1/attempts?status=pending_review — pending essay attempts
  Future<List<Map<String, dynamic>>> getPendingEssayAttempts() async {
    final response = await _apiService.dio.get<Map<String, dynamic>>(
        '/attempts',
        queryParameters: {'status': 'pending_review'});
    return List<Map<String, dynamic>>.from(
        (response.data?['attempts'] as List?) ?? const []);
  }
}

final teacherRepositoryProvider = Provider<TeacherRepository>(
  (ref) => TeacherRepository(ref.watch(apiServiceProvider)),
);
