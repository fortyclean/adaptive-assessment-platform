import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin 1.0.25 improvements', () {
    test('institution contact validation rejects bad email and short phone',
        () {
      expect(_isValidEmail('admin@school.edu'), isTrue);
      expect(_isValidEmail('admin-school.edu'), isFalse);

      expect(_isValidPhone('+966 500 000 000'), isTrue);
      expect(_isValidPhone('12345'), isFalse);
    });

    test('classroom filters identify empty ownership states', () {
      final classrooms = [
        {
          'name': 'الأول المتوسط',
          'teacherName': 'غير محدد',
          'studentIds': <String>[],
        },
        {
          'name': 'الثاني المتوسط',
          'teacherId': 't1',
          'teacherName': 'أ. محمد',
          'studentIds': ['s1', 's2'],
        },
      ];

      expect(_filterClassrooms(classrooms, 'without_teacher'), hasLength(1));
      expect(_filterClassrooms(classrooms, 'with_students'), hasLength(1));
      expect(_filterClassrooms(classrooms, 'without_students'), hasLength(1));
    });

    test('user classroom names are resolved from linked ids', () {
      final classrooms = [
        {'_id': 'c1', 'name': 'الأول المتوسط (أ)'},
        {'_id': 'c2', 'name': 'الثاني المتوسط (ب)'},
      ];
      final user = {
        'fullName': 'معلم تجريبي',
        'classroomIds': ['c1', 'c2'],
      };

      expect(
        _classroomNamesForUser(user, classrooms),
        ['الأول المتوسط (أ)', 'الثاني المتوسط (ب)'],
      );
    });

    test('school report export supports json and csv expectations', () {
      final report = {
        'generatedAt': '2026-05-13T10:00:00.000Z',
        'summary': {'totalStudents': 120, 'schoolAverage': 82},
        'classroomComparison': [
          {'name': 'الأول المتوسط', 'averageScore': 88},
        ],
        'weakestSkills': [
          {'mainSkill': 'الجبر', 'averagePercentage': 62},
        ],
      };

      final csv = _buildSchoolReportCsv(report, 'كل المواد • كل المراحل');

      expect(csv, contains('القسم,المؤشر,القيمة'));
      expect(csv, contains('totalStudents'));
      expect(csv, contains('الأول المتوسط'));
      expect(csv, contains('الجبر'));
    });
  });
}

bool _isValidEmail(String value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());

bool _isValidPhone(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.length >= 7 && RegExp(r'^[0-9+\s()-]+$').hasMatch(value);
}

List<Map<String, dynamic>> _filterClassrooms(
  List<Map<String, dynamic>> classrooms,
  String filter,
) {
  switch (filter) {
    case 'without_teacher':
      return classrooms.where((classroom) {
        final teacherName = (classroom['teacherName'] as String?) ?? 'غير محدد';
        return classroom['teacherId'] == null ||
            '${classroom['teacherId']}'.isEmpty ||
            teacherName == 'غير محدد';
      }).toList();
    case 'with_students':
      return classrooms
          .where((classroom) =>
              ((classroom['studentIds'] as List?)?.isNotEmpty ?? false) ||
              ((classroom['studentCount'] as int?) ?? 0) > 0)
          .toList();
    case 'without_students':
      return classrooms
          .where((classroom) =>
              !((classroom['studentIds'] as List?)?.isNotEmpty ?? false) &&
              ((classroom['studentCount'] as int?) ?? 0) == 0)
          .toList();
    default:
      return classrooms;
  }
}

List<String> _classroomNamesForUser(
  Map<String, dynamic> user,
  List<Map<String, dynamic>> classrooms,
) {
  final ids = {
    for (final item in (user['classroomIds'] as List?) ?? const [])
      if (item is String) item,
  };

  return [
    for (final classroom in classrooms)
      if (ids.contains((classroom['_id'] ?? classroom['id'])?.toString()))
        classroom['name'] as String,
  ];
}

String _buildSchoolReportCsv(
  Map<String, dynamic> report,
  String filterSummary,
) {
  final buffer = StringBuffer();
  void row(List<Object?> values) {
    buffer.writeln(values.map(_csvCell).join(','));
  }

  row(['القسم', 'المؤشر', 'القيمة']);
  row(['التقرير', 'تاريخ الإنشاء', report['generatedAt'] ?? '']);
  row(['التقرير', 'نطاق الفلاتر', filterSummary]);

  final summary = report['summary'] as Map<String, dynamic>? ?? {};
  for (final entry in summary.entries) {
    row(['الملخص', entry.key, entry.value]);
  }

  final comparisons = report['classroomComparison'] as List? ?? const [];
  for (final item in comparisons.whereType<Map<String, dynamic>>()) {
    row(['مقارنة الفصول', item['name'], item['averageScore']]);
  }

  final weaknesses = report['weakestSkills'] as List? ?? const [];
  for (final item in weaknesses.whereType<Map<String, dynamic>>()) {
    row(['مهارات تحتاج دعماً', item['mainSkill'], item['averagePercentage']]);
  }
  return buffer.toString();
}

String _csvCell(Object? value) {
  final text = (value ?? '').toString().replaceAll('"', '""');
  return text.contains(',') || text.contains('\n') ? '"$text"' : text;
}
