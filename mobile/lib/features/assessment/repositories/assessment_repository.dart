import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';

/// Repository for assessment and attempt API calls.
class AssessmentRepository {
  AssessmentRepository(this._apiService);
  final ApiService _apiService;

  /// GET /api/v1/assessments — list assessments for current user
  Future<List<Map<String, dynamic>>> getAssessments() async {
    final response = await _apiService.dio.get<Map<String, dynamic>>('/assessments');
    return List<Map<String, dynamic>>.from(
        (response.data?['assessments'] as List?) ?? const []);
  }

  /// GET /api/v1/assessments/:id
  Future<Map<String, dynamic>> getAssessment(String id) async {
    final response = await _apiService.dio.get<Map<String, dynamic>>('/assessments/$id');
    return (response.data?['assessment'] as Map<String, dynamic>?) ?? {};
  }

  /// POST /api/v1/attempts — start a session
  Future<Map<String, dynamic>> startAttempt({
    required String assessmentId,
    required String classroomId,
  }) async {
    final response = await _apiService.dio.post<Map<String, dynamic>>('/attempts', data: {
      'assessmentId': assessmentId,
      'classroomId': classroomId,
    });
    return response.data ?? {};
  }

  /// GET /api/v1/attempts/:id/next-question
  Future<Map<String, dynamic>> getNextQuestion(String attemptId) async {
    final response =
        await _apiService.dio.get<Map<String, dynamic>>('/attempts/$attemptId/next-question');
    return response.data ?? {};
  }

  /// POST /api/v1/attempts/:id/answer
  Future<Map<String, dynamic>> submitAnswer({
    required String attemptId,
    required String questionId,
    required String selectedAnswer,
  }) async {
    final response = await _apiService.dio.post<Map<String, dynamic>>(
      '/attempts/$attemptId/answer',
      data: {'questionId': questionId, 'selectedAnswer': selectedAnswer},
    );
    return response.data ?? {};
  }

  /// POST /api/v1/attempts/:id/submit
  Future<void> submitAttempt(String attemptId) async {
    await _apiService.dio.post<Map<String, dynamic>>('/attempts/$attemptId/submit');
  }

  /// POST /api/v1/attempts/:id/anti-cheat
  Future<void> logAntiCheatEvent(String attemptId, String event) async {
    await _apiService.dio.post<Map<String, dynamic>>(
      '/attempts/$attemptId/anti-cheat',
      data: {'event': event},
    );
  }

  /// GET /api/v1/attempts/:id/result
  Future<Map<String, dynamic>> getResult(String attemptId) async {
    final response =
        await _apiService.dio.get<Map<String, dynamic>>('/attempts/$attemptId/result');
    return response.data ?? {};
  }

  /// GET /api/v1/attempts — student session history
  Future<List<Map<String, dynamic>>> getAttemptHistory() async {
    final response = await _apiService.dio.get<Map<String, dynamic>>('/attempts');
    return List<Map<String, dynamic>>.from((response.data?['attempts'] as List?) ?? const []);
  }

  /// GET /api/v1/notifications/points
  Future<Map<String, dynamic>> getPointsSummary() async {
    final response = await _apiService.dio.get<Map<String, dynamic>>('/notifications/points');
    return response.data ?? {};
  }
}

final assessmentRepositoryProvider = Provider<AssessmentRepository>(
  (ref) => AssessmentRepository(ref.watch(apiServiceProvider)),
);
