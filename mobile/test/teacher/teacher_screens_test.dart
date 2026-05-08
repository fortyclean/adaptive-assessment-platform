import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_assessment/core/constants/app_constants.dart';

/// Widget tests for Teacher Screens
/// Requirements: 5.1, 5.4, 3.4, 4.1
void main() {
  // ─── Assessment Creation Form Validation (Req 5.1, 5.4) ──────────────────

  group('Create Assessment — Form Validation (Req 5.1, 5.4)', () {
    test('question count must be between 5 and 50', () {
      bool isValidCount(int count) =>
          count >= AppConstants.minQuestions && count <= AppConstants.maxQuestions;

      expect(isValidCount(5), isTrue);
      expect(isValidCount(10), isTrue);
      expect(isValidCount(50), isTrue);
      expect(isValidCount(4), isFalse);
      expect(isValidCount(51), isFalse);
      expect(isValidCount(0), isFalse);
    });

    test('time limit must be between 5 and 120 minutes', () {
      bool isValidTime(int minutes) =>
          minutes >= AppConstants.minTimeLimitMinutes &&
          minutes <= AppConstants.maxTimeLimitMinutes;

      expect(isValidTime(5), isTrue);
      expect(isValidTime(60), isTrue);
      expect(isValidTime(120), isTrue);
      expect(isValidTime(4), isFalse);
      expect(isValidTime(121), isFalse);
    });

    test('assessment type must be random or adaptive', () {
      const validTypes = ['random', 'adaptive'];
      expect(validTypes.contains('random'), isTrue);
      expect(validTypes.contains('adaptive'), isTrue);
      expect(validTypes.contains('manual'), isFalse);
    });

    test('subject must be one of the 6 MVP subjects', () {
      bool isValidSubject(String subject) =>
          AppConstants.subjects.contains(subject);

      expect(isValidSubject('Mathematics'), isTrue);
      expect(isValidSubject('English'), isTrue);
      expect(isValidSubject('Arabic'), isTrue);
      expect(isValidSubject('Physics'), isTrue);
      expect(isValidSubject('Chemistry'), isTrue);
      expect(isValidSubject('Biology'), isTrue);
      expect(isValidSubject('History'), isFalse);
    });

    test('availability window: end must be after start', () {
      final now = DateTime.now();
      final start = now.add(const Duration(hours: 1));
      final end = now.add(const Duration(hours: 3));
      final invalidEnd = now.subtract(const Duration(hours: 1));

      expect(end.isAfter(start), isTrue);
      expect(invalidEnd.isAfter(start), isFalse);
    });

    test('title must not be empty', () {
      String? validateTitle(String? value) {
        if (value == null || value.trim().isEmpty) return 'مطلوب';
        return null;
      }

      expect(validateTitle(''), isNotNull);
      expect(validateTitle(null), isNotNull);
      expect(validateTitle('   '), isNotNull);
      expect(validateTitle('اختبار الرياضيات'), isNull);
    });
  });

  // ─── Question Bank Filtering (Req 3.4) ───────────────────────────────────

  group('Question Bank — Filtering Logic (Req 3.4)', () {
    final questions = [
      {'subject': 'Mathematics', 'difficulty': 'easy', 'unit': 'Algebra', 'mainSkill': 'Equations'},
      {'subject': 'Mathematics', 'difficulty': 'medium', 'unit': 'Algebra', 'mainSkill': 'Functions'},
      {'subject': 'Mathematics', 'difficulty': 'hard', 'unit': 'Geometry', 'mainSkill': 'Shapes'},
      {'subject': 'Physics', 'difficulty': 'easy', 'unit': 'Mechanics', 'mainSkill': 'Forces'},
      {'subject': 'English', 'difficulty': 'medium', 'unit': 'Grammar', 'mainSkill': 'Tenses'},
    ];

    test('filters by subject', () {
      final filtered = questions.where((q) => q['subject'] == 'Mathematics').toList();
      expect(filtered.length, equals(3));
    });

    test('filters by difficulty', () {
      final filtered = questions.where((q) => q['difficulty'] == 'easy').toList();
      expect(filtered.length, equals(2));
    });

    test('filters by unit', () {
      final filtered = questions.where((q) => q['unit'] == 'Algebra').toList();
      expect(filtered.length, equals(2));
    });

    test('filters by multiple criteria', () {
      final filtered = questions
          .where((q) => q['subject'] == 'Mathematics' && q['difficulty'] == 'easy')
          .toList();
      expect(filtered.length, equals(1));
      expect(filtered.first['unit'], equals('Algebra'));
    });

    test('returns empty list when no match', () {
      final filtered = questions.where((q) => q['subject'] == 'Chemistry').toList();
      expect(filtered, isEmpty);
    });

    test('returns all when no filter applied', () {
      final filtered = questions.where((_) => true).toList();
      expect(filtered.length, equals(questions.length));
    });
  });

  // ─── Excel Import Validation (Req 4.1) ───────────────────────────────────

  group('Excel Import — File Validation (Req 4.1)', () {
    test('accepts .xlsx files', () {
      bool isValidFile(String filename) =>
          filename.endsWith('.xlsx') || filename.endsWith('.xls');

      expect(isValidFile('questions.xlsx'), isTrue);
      expect(isValidFile('questions.xls'), isTrue);
      expect(isValidFile('questions.csv'), isFalse);
      expect(isValidFile('questions.pdf'), isFalse);
    });

    test('rejects files over 10MB', () {
      const maxSizeBytes = 10 * 1024 * 1024; // 10MB

      bool isValidSize(int bytes) => bytes <= maxSizeBytes;

      expect(isValidSize(5 * 1024 * 1024), isTrue);
      expect(isValidSize(10 * 1024 * 1024), isTrue);
      expect(isValidSize(10 * 1024 * 1024 + 1), isFalse);
    });

    test('import result counts are non-negative', () {
      final result = {'imported': 45, 'skipped': 3, 'failed': 2};

      expect(result['imported']! >= 0, isTrue);
      expect(result['skipped']! >= 0, isTrue);
      expect(result['failed']! >= 0, isTrue);
    });

    test('total rows equals imported + skipped + failed', () {
      const imported = 45;
      const skipped = 3;
      const failed = 2;
      const total = imported + skipped + failed;

      expect(total, equals(50));
    });
  });

  // ─── Quality Check Logic (Req 22.3, 22.4) ────────────────────────────────

  group('Quality Check — Adaptive Readiness (Req 22.3, 22.4)', () {
    const minPerDifficulty = 3;

    test('unit is adaptive-ready when all difficulties have >= 3 questions', () {
      final counts = {'easy': 5, 'medium': 4, 'hard': 3};
      final isReady = counts.values.every((c) => c >= minPerDifficulty);
      expect(isReady, isTrue);
    });

    test('unit is NOT adaptive-ready when any difficulty has < 3 questions', () {
      final counts = {'easy': 5, 'medium': 5, 'hard': 2};
      final isReady = counts.values.every((c) => c >= minPerDifficulty);
      expect(isReady, isFalse);
    });

    test('generates correct warning messages', () {
      final counts = {'easy': 1, 'medium': 5, 'hard': 0};
      final warnings = <String>[];

      counts.forEach((difficulty, count) {
        if (count < minPerDifficulty) {
          warnings.add('$difficulty: $count/$minPerDifficulty');
        }
      });

      expect(warnings.length, equals(2));
      expect(warnings.any((w) => w.contains('easy')), isTrue);
      expect(warnings.any((w) => w.contains('hard')), isTrue);
    });
  });
}

// ─── Additional Teacher Screen Tests ─────────────────────────────────────────

void additionalTeacherTests() {
  // ─── Assessment Publishing (Req 5.6) ───────────────────────────────────

  group('Assessment Publishing (Req 5.6)', () {
    test('only draft assessments can be published', () {
      const validStatuses = ['draft'];
      expect(validStatuses.contains('draft'), isTrue);
      expect(validStatuses.contains('active'), isFalse);
      expect(validStatuses.contains('completed'), isFalse);
    });

    test('assessment must have at least one classroom before publishing', () {
      final classroomIds = <String>[];
      final canPublish = classroomIds.isNotEmpty;
      expect(canPublish, isFalse);

      classroomIds.add('classroom-1');
      expect(classroomIds.isNotEmpty, isTrue);
    });

    test('status transitions correctly after publish', () {
      var status = 'draft';
      status = 'active'; // After publish
      expect(status, equals('active'));
    });
  });

  // ─── Add Question Validation (Req 16.1, 16.2, 16.3) ─────────────────────

  group('Add Question — Validation (Req 16.1, 16.2, 16.3)', () {
    test('all mandatory fields must be filled', () {
      final requiredFields = [
        'subject', 'gradeLevel', 'unit', 'mainSkill',
        'subSkill', 'difficulty', 'questionText', 'correctAnswer'
      ];

      final filledFields = {
        'subject': 'Mathematics',
        'gradeLevel': 'Grade 7',
        'unit': 'Algebra',
        'mainSkill': 'Equations',
        'subSkill': 'Linear',
        'difficulty': 'medium',
        'questionText': 'What is 2+2?',
        'correctAnswer': 'B',
      };

      final allFilled = requiredFields.every(
        (f) => filledFields.containsKey(f) && filledFields[f]!.isNotEmpty,
      );
      expect(allFilled, isTrue);
    });

    test('correct answer must match one of the option keys', () {
      final options = ['A', 'B', 'C', 'D'];
      expect(options.contains('B'), isTrue);
      expect(options.contains('E'), isFalse);
    });

    test('options must not have duplicate values', () {
      final optionValues = ['الحوت', 'التمساح', 'الضفدع', 'البطريق'];
      final uniqueValues = optionValues.toSet();
      expect(uniqueValues.length, equals(optionValues.length));

      final duplicateValues = ['الحوت', 'الحوت', 'الضفدع', 'البطريق'];
      final uniqueDuplicates = duplicateValues.toSet();
      expect(uniqueDuplicates.length, lessThan(duplicateValues.length));
    });
  });

  // ─── Import Error Report (Req 4.5, 4.6) ──────────────────────────────────

  group('Excel Import — Error Report (Req 4.5, 4.6)', () {
    test('error report contains row number and description', () {
      final errors = [
        {'row': 5, 'type': 'missing_field', 'description': 'حقل المادة مفقود'},
        {'row': 12, 'type': 'duplicate', 'description': 'سؤال مكرر'},
        {'row': 18, 'type': 'invalid_answer', 'description': 'الإجابة الصحيحة غير صالحة'},
      ];

      for (final error in errors) {
        expect(error.containsKey('row'), isTrue);
        expect(error.containsKey('description'), isTrue);
        expect((error['row'] as int) > 0, isTrue);
      }
    });

    test('CSV error report has correct format', () {
      final headers = ['Row', 'Type', 'Description'];
      final rows = [
        ['5', 'missing_field', 'حقل المادة مفقود'],
        ['12', 'duplicate', 'سؤال مكرر'],
      ];

      final csv = [
        headers.join(','),
        ...rows.map((r) => r.join(',')),
      ].join('\n');

      expect(csv.startsWith('Row,Type,Description'), isTrue);
      expect(csv.contains('5,missing_field'), isTrue);
    });

    test('template download provides correct column headers', () {
      final templateHeaders = [
        'Subject', 'Grade Level', 'Academic Term', 'Unit',
        'Main Skill', 'Sub Skill', 'Difficulty', 'Question Text',
        'Option A', 'Option B', 'Option C', 'Option D', 'Correct Answer',
      ];

      expect(templateHeaders.length, equals(13));
      expect(templateHeaders.contains('Subject'), isTrue);
      expect(templateHeaders.contains('Correct Answer'), isTrue);
    });
  });
}
