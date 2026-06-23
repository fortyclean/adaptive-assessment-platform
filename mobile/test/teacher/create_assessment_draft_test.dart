import 'package:adaptive_assessment/features/assessment/models/create_assessment_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreateAssessmentDraft', () {
    test('builds API payload with trimmed values and optional dates', () {
      final from = DateTime(2026, 5, 23, 9);
      final until = DateTime(2026, 5, 24, 10, 30);
      final draft = CreateAssessmentDraft(
        title: ' اختبار الوحدة ',
        assessmentType: 'adaptive',
        subject: 'الرياضيات',
        gradeLevel: 'الصف العاشر',
        unit: ' الوحدة الأولى ',
        questionCount: 12,
        timeLimitMinutes: 35,
        classroomIds: const ['class-1', 'class-2'],
        availableFrom: from,
        availableUntil: until,
      );

      expect(draft.toPayload(), {
        'title': 'اختبار الوحدة',
        'assessmentType': 'adaptive',
        'subject': 'الرياضيات',
        'gradeLevel': 'الصف العاشر',
        'units': ['الوحدة الأولى'],
        'questionCount': 12,
        'timeLimitMinutes': 35,
        'classroomIds': ['class-1', 'class-2'],
        'availableFrom': from.toIso8601String(),
        'availableUntil': until.toIso8601String(),
      });
    });

    test('requires at least one classroom before immediate publish', () {
      const draft = CreateAssessmentDraft(
        title: 'اختبار',
        assessmentType: 'adaptive',
        subject: 'الرياضيات',
        gradeLevel: 'الصف العاشر',
        unit: 'الوحدة الأولى',
        questionCount: 10,
        timeLimitMinutes: 30,
        classroomIds: [],
      );

      expect(
        draft.validateForPublish(
          classroomRequiredMessage: 'Select one class first',
        ),
        'Select one class first',
      );
    });

    test('rejects invalid availability window', () {
      final now = DateTime(2026, 5, 23, 10);
      final draft = CreateAssessmentDraft(
        title: 'اختبار',
        assessmentType: 'adaptive',
        subject: 'الرياضيات',
        gradeLevel: 'الصف العاشر',
        unit: 'الوحدة الأولى',
        questionCount: 10,
        timeLimitMinutes: 30,
        classroomIds: const ['class-1'],
        availableFrom: now,
        availableUntil: now.subtract(const Duration(hours: 1)),
      );

      expect(
        draft.validateAvailabilityWindow(
          invalidAvailabilityWindowMessage: 'End date must be after start',
        ),
        'End date must be after start',
      );
    });

    test('extracts created assessment id from backend response variants', () {
      expect(extractCreatedAssessmentId({'_id': 'mongo-id'}), 'mongo-id');
      expect(extractCreatedAssessmentId({'id': 'public-id'}), 'public-id');
      expect(extractCreatedAssessmentId({'id': '   '}), isNull);
      expect(extractCreatedAssessmentId({}), isNull);
    });
  });
}
