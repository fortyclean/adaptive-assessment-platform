import 'package:adaptive_assessment/features/reports/utils/school_report_export_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SchoolReportExportUtils', () {
    test('detects whether a report has exportable data', () {
      expect(SchoolReportExportUtils.hasExportableData({}), isFalse);
      expect(
        SchoolReportExportUtils.hasExportableData({
          'summary': {'schoolAverage': 84},
        }),
        isTrue,
      );
      expect(
        SchoolReportExportUtils.hasExportableData({
          'classroomComparison': [
            {'classroomName': 'الأول المتوسط'}
          ],
        }),
        isTrue,
      );
    });

    test('escapes csv cells with commas, quotes, and new lines', () {
      expect(SchoolReportExportUtils.csvCell('أولى, متوسط'), '"أولى, متوسط"');
      expect(SchoolReportExportUtils.csvCell('قال "ممتاز"'), '"قال ""ممتاز"""');
      expect(SchoolReportExportUtils.csvCell('سطر\nثاني'), '"سطر\nثاني"');
    });

    test('builds csv content with filter summary and report sections', () {
      final csv = SchoolReportExportUtils.buildCsv(
        filterSummary: 'النطاق الحالي: الرياضيات • المرحلة 10',
        report: {
          'generatedAt': '2026-05-24T00:00:00Z',
          'summary': {'schoolAverage': 84},
          'classroomComparison': [
            {
              'classroomName': 'أولى, متوسط',
              'averageScore': 92,
              'completionRate': 100,
              'topSkill': 'الجبر',
            },
          ],
          'weakestSkills': [
            {'mainSkill': 'الكسور', 'averagePercentage': 58},
          ],
        },
      );

      expect(csv, contains('النطاق الحالي: الرياضيات • المرحلة 10'));
      expect(csv, contains('"أولى, متوسط"'));
      expect(csv, contains('الكسور'));
    });

    test('builds deterministic file names by format', () {
      final timestamp = DateTime.utc(2026, 5, 24, 3, 4, 5);

      expect(
        SchoolReportExportUtils.buildFileName(
          timestamp: timestamp,
          format: SchoolReportExportFormat.json,
        ),
        'school-report-2026-05-24T03-04-05-000Z.json',
      );
      expect(
        SchoolReportExportUtils.buildFileName(
          timestamp: timestamp,
          format: SchoolReportExportFormat.csv,
        ),
        'school-report-2026-05-24T03-04-05-000Z.csv',
      );
    });
  });
}
