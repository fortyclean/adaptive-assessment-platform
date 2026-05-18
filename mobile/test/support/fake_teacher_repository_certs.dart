import 'package:adaptive_assessment/core/network/api_service.dart';
import 'package:adaptive_assessment/features/assessment/repositories/teacher_repository.dart';

/// Stubbed teacher API for widget tests (no network).
class FakeTeacherRepositoryCerts extends TeacherRepository {
  FakeTeacherRepositoryCerts() : super(ApiService.instance);

  @override
  Future<List<Map<String, dynamic>>> getClassrooms() async => [
        {
          '_id': 'cls-001',
          'name': 'أولى متوسط (أ)',
          'gradeLevel': 'الصف الأول المتوسط',
        },
      ];

  @override
  Future<Map<String, dynamic>> getClassroomCertificates(String id) async => {
        'students': [
          {
            '_id': 's1',
            'fullName': 'أحمد علي منصور',
            'score': 98.5,
            'grade': 'ممتاز',
            'passed': true,
          },
          {
            '_id': 's2',
            'fullName': 'سارة كمال السعدي',
            'score': 94.2,
            'grade': 'امتياز',
            'passed': true,
          },
          {
            '_id': 's3',
            'fullName': 'محمد خالد الحربي',
            'score': 87.0,
            'grade': 'جيد جداً',
            'passed': true,
          },
          {
            '_id': 's4',
            'fullName': 'ليلى سالم العتيبي',
            'score': 91.8,
            'grade': 'امتياز',
            'passed': true,
          },
        ],
      };
}
