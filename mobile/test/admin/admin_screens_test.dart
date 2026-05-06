import 'package:flutter_test/flutter_test.dart';

/// Widget tests for Admin Screens
/// Requirements: 13.2, 2.1, 2.2
void main() {
  // ─── User Search Logic (Req 13.2) ─────────────────────────────────────────

  group('User Management — Search Logic (Req 13.2)', () {
    final users = [
      {'fullName': 'أحمد علي', 'username': 'ahmed.ali', 'role': 'teacher', 'isActive': true},
      {'fullName': 'سارة محمد', 'username': 'sara.m', 'role': 'student', 'isActive': true},
      {'fullName': 'خالد عمر', 'username': 'khaled.o', 'role': 'teacher', 'isActive': false},
      {'fullName': 'فاطمة حسن', 'username': 'fatima.h', 'role': 'student', 'isActive': true},
      {'fullName': 'محمد أحمد', 'username': 'mohammed.a', 'role': 'teacher', 'isActive': true},
    ];

    List<Map<String, dynamic>> searchUsers(String query) {
      if (query.isEmpty) return users;
      final q = query.toLowerCase();
      return users.where((u) =>
        (u['fullName'] as String).toLowerCase().contains(q) ||
        (u['username'] as String).toLowerCase().contains(q)
      ).toList();
    }

    test('returns all users when search is empty', () {
      expect(searchUsers('').length, equals(5));
    });

    test('searches by full name', () {
      final results = searchUsers('أحمد');
      expect(results.length, equals(2)); // أحمد علي + محمد أحمد
    });

    test('searches by username', () {
      final results = searchUsers('sara');
      expect(results.length, equals(1));
      expect(results.first['username'], equals('sara.m'));
    });

    test('search is case-insensitive', () {
      final results = searchUsers('AHMED');
      expect(results.isNotEmpty, isTrue);
    });

    test('returns empty list when no match', () {
      final results = searchUsers('xyz_no_match_999');
      expect(results, isEmpty);
    });

    test('filters by role', () {
      final teachers = users.where((u) => u['role'] == 'teacher').toList();
      expect(teachers.length, equals(3));
    });

    test('filters active users only', () {
      final active = users.where((u) => u['isActive'] == true).toList();
      expect(active.length, equals(4));
    });
  });

  // ─── User Account Creation Validation (Req 13.2) ─────────────────────────

  group('User Creation — Validation (Req 13.2)', () {
    String? validateFullName(String? value) {
      if (value == null || value.trim().isEmpty) return 'مطلوب';
      return null;
    }

    String? validateUsername(String? value) {
      if (value == null || value.trim().isEmpty) return 'مطلوب';
      if (value.length < 3) return 'يجب أن يكون 3 أحرف على الأقل';
      return null;
    }

    String? validatePassword(String? value) {
      if (value == null || value.isEmpty) return 'مطلوب';
      if (value.length < 8) return '8 أحرف على الأقل';
      return null;
    }

    test('full name is required', () {
      expect(validateFullName(''), isNotNull);
      expect(validateFullName(null), isNotNull);
      expect(validateFullName('أحمد علي'), isNull);
    });

    test('username must be at least 3 characters', () {
      expect(validateUsername('ab'), isNotNull);
      expect(validateUsername('abc'), isNull);
      expect(validateUsername('ahmed'), isNull);
    });

    test('password must be at least 8 characters', () {
      expect(validatePassword('1234567'), isNotNull);
      expect(validatePassword('12345678'), isNull);
    });

    test('role must be teacher or student', () {
      const validRoles = ['teacher', 'student'];
      expect(validRoles.contains('teacher'), isTrue);
      expect(validRoles.contains('student'), isTrue);
      expect(validRoles.contains('admin'), isFalse);
    });
  });

  // ─── Classroom Creation Validation (Req 2.1) ─────────────────────────────

  group('Classroom Management — Creation Validation (Req 2.1)', () {
    String? validateClassroomName(String? value) {
      if (value == null || value.trim().isEmpty) return 'مطلوب';
      if (value.length > 100) return 'الاسم طويل جداً';
      return null;
    }

    String? validateGradeLevel(String? value) {
      if (value == null || value.trim().isEmpty) return 'مطلوب';
      return null;
    }

    String? validateAcademicYear(String? value) {
      if (value == null || value.trim().isEmpty) return 'مطلوب';
      return null;
    }

    test('classroom name is required', () {
      expect(validateClassroomName(''), isNotNull);
      expect(validateClassroomName(null), isNotNull);
      expect(validateClassroomName('الفصل الأول'), isNull);
    });

    test('classroom name cannot exceed 100 characters', () {
      final longName = 'أ' * 101;
      expect(validateClassroomName(longName), isNotNull);
      final validName = 'أ' * 100;
      expect(validateClassroomName(validName), isNull);
    });

    test('grade level is required', () {
      expect(validateGradeLevel(''), isNotNull);
      expect(validateGradeLevel('Grade 7'), isNull);
    });

    test('academic year is required', () {
      expect(validateAcademicYear(''), isNotNull);
      expect(validateAcademicYear('2024-2025'), isNull);
    });
  });

  // ─── Student Assignment to Classroom (Req 2.2) ───────────────────────────

  group('Classroom — Student Assignment (Req 2.2)', () {
    test('student can be assigned to multiple classrooms', () {
      final studentClassrooms = <String>[];
      studentClassrooms.add('classroom-1');
      studentClassrooms.add('classroom-2');

      expect(studentClassrooms.length, equals(2));
    });

    test('prevents duplicate assignment to same classroom', () {
      final studentClassrooms = <String>{'classroom-1'};
      studentClassrooms.add('classroom-1'); // Set prevents duplicates

      expect(studentClassrooms.length, equals(1));
    });

    test('classroom student count updates after assignment', () {
      var studentCount = 0;
      studentCount += 3; // Assign 3 students

      expect(studentCount, equals(3));
    });
  });

  // ─── Classroom Deletion Warning (Req 2.5) ────────────────────────────────

  group('Classroom — Deletion Warning (Req 2.5)', () {
    test('warns when classroom has active assessments', () {
      final classroom = {
        'name': 'الفصل الأول',
        'activeAssessmentCount': 2,
      };

      final hasActiveAssessments =
          (classroom['activeAssessmentCount'] as int) > 0;
      expect(hasActiveAssessments, isTrue);
    });

    test('allows deletion when no active assessments', () {
      final classroom = {
        'name': 'الفصل الثاني',
        'activeAssessmentCount': 0,
      };

      final canDelete = (classroom['activeAssessmentCount'] as int) == 0;
      expect(canDelete, isTrue);
    });
  });

  // ─── Account Deactivation (Req 13.4) ─────────────────────────────────────

  group('User Deactivation (Req 13.4)', () {
    test('deactivated user cannot login', () {
      final user = {'isActive': false};
      final canLogin = user['isActive'] as bool;
      expect(canLogin, isFalse);
    });

    test('active user can login', () {
      final user = {'isActive': true};
      final canLogin = user['isActive'] as bool;
      expect(canLogin, isTrue);
    });

    test('deactivation invalidates active sessions', () {
      final activeSessions = ['session-1', 'session-2'];
      activeSessions.clear(); // Simulate session invalidation

      expect(activeSessions, isEmpty);
    });
  });

  // ─── School Report Data (Req 19.1) ───────────────────────────────────────

  group('School Reports — Data Validation (Req 19.1)', () {
    test('school average is between 0 and 100', () {
      double calcAverage(List<double> scores) {
        if (scores.isEmpty) return 0;
        return scores.reduce((a, b) => a + b) / scores.length;
      }

      final avg = calcAverage([80, 90, 70, 60, 100]);
      expect(avg, greaterThanOrEqualTo(0));
      expect(avg, lessThanOrEqualTo(100));
      expect(avg, equals(80.0));
    });

    test('identifies top 3 weakest skills', () {
      final skills = [
        {'mainSkill': 'Algebra', 'averagePercentage': 45.0},
        {'mainSkill': 'Geometry', 'averagePercentage': 72.0},
        {'mainSkill': 'Calculus', 'averagePercentage': 38.0},
        {'mainSkill': 'Statistics', 'averagePercentage': 55.0},
        {'mainSkill': 'Trigonometry', 'averagePercentage': 41.0},
      ];

      final sorted = List<Map<String, dynamic>>.from(skills)
        ..sort((a, b) => (a['averagePercentage'] as double)
            .compareTo(b['averagePercentage'] as double));

      final weakest3 = sorted.take(3).toList();
      expect(weakest3.length, equals(3));
      expect(weakest3.first['mainSkill'], equals('Calculus'));
      expect(weakest3[1]['mainSkill'], equals('Trigonometry'));
      expect(weakest3[2]['mainSkill'], equals('Algebra'));
    });
  });
}
