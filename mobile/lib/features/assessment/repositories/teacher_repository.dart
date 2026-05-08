import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';

/// Repository for teacher-specific API calls.
class TeacherRepository {
  TeacherRepository(this._apiService);
  final ApiService _apiService;

  /// GET /api/v1/assessments — teacher's assessments
  Future<List<Map<String, dynamic>>> getAssessments({String? status}) async {
    final response = await _apiService.dio.get('/assessments',
        queryParameters: status != null ? {'status': status} : null);
    return List<Map<String, dynamic>>.from(
        response.data['assessments'] as List);
  }

  /// POST /api/v1/assessments
  Future<Map<String, dynamic>> createAssessment(
      Map<String, dynamic> data) async {
    final response = await _apiService.dio.post('/assessments', data: data);
    return response.data['assessment'] as Map<String, dynamic>;
  }

  /// POST /api/v1/assessments/:id/publish
  Future<void> publishAssessment(String id) async {
    await _apiService.dio.post('/assessments/$id/publish');
  }

  /// GET /api/v1/questions
  Future<Map<String, dynamic>> getQuestions(
      {Map<String, dynamic>? filters, int page = 1}) async {
    final response = await _apiService.dio.get('/questions',
        queryParameters: {
          ...?filters,
          'page': page,
          'limit': 20,
        });
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/v1/questions
  Future<Map<String, dynamic>> createQuestion(
      Map<String, dynamic> data) async {
    final response = await _apiService.dio.post('/questions', data: data);
    return response.data['question'] as Map<String, dynamic>;
  }

  /// GET /api/v1/questions/quality-check
  Future<Map<String, dynamic>> getQualityCheck(
      {required String subject,
      required String gradeLevel,
      required String unit}) async {
    final response = await _apiService.dio.get('/questions/quality-check',
        queryParameters: {
          'subject': subject,
          'gradeLevel': gradeLevel,
          'unit': unit,
        });
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/v1/reports/assessment/:id
  Future<Map<String, dynamic>> getAssessmentReport(String id) async {
    final response =
        await _apiService.dio.get('/reports/assessment/$id');
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/v1/reports/student/:id
  Future<Map<String, dynamic>> getStudentReport(String studentId,
      {String? assessmentId}) async {
    final response = await _apiService.dio.get('/reports/student/$studentId',
        queryParameters:
            assessmentId != null ? {'assessmentId': assessmentId} : null);
    return response.data as Map<String, dynamic>;
  }

  /// GET /api/v1/classrooms
  Future<List<Map<String, dynamic>>> getClassrooms() async {
    final response = await _apiService.dio.get('/classrooms');
    return List<Map<String, dynamic>>.from(
        response.data['classrooms'] as List);
  }

  /// GET /api/v1/attempts/:id — for essay grading
  Future<Map<String, dynamic>> getAttemptForGrading(String attemptId) async {
    final response = await _apiService.dio.get('/attempts/$attemptId');
    return response.data as Map<String, dynamic>;
  }

  /// POST /api/v1/attempts/:id/grade — submit essay grades
  Future<void> submitEssayGrades(
      String attemptId, Map<String, int> scores) async {
    await _apiService.dio.post('/attempts/$attemptId/grade', data: {
      'scores': scores.map((k, v) => MapEntry(k, v)),
    });
  }

  /// GET /api/v1/attempts?status=pending_review — pending essay attempts
  Future<List<Map<String, dynamic>>> getPendingEssayAttempts() async {
    final response = await _apiService.dio.get('/attempts',
        queryParameters: {'status': 'pending_review'});
    return List<Map<String, dynamic>>.from(
        response.data['attempts'] as List? ?? []);
  }
}

final teacherRepositoryProvider = Provider<TeacherRepository>(
  (ref) => TeacherRepository(ref.watch(apiServiceProvider)),
);
