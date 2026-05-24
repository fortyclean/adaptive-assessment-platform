import 'dart:convert';

enum SchoolReportExportFormat { json, csv }

class SchoolReportExportUtils {
  const SchoolReportExportUtils._();

  static bool hasExportableData(Map<String, dynamic> report) {
    final summary = report['summary'];
    final comparisons = report['classroomComparison'];
    final weaknesses = report['weakestSkills'];
    return (summary is Map && summary.isNotEmpty) ||
        (comparisons is List && comparisons.isNotEmpty) ||
        (weaknesses is List && weaknesses.isNotEmpty);
  }

  static String buildContent({
    required Map<String, dynamic> report,
    required SchoolReportExportFormat format,
    required String filterSummary,
  }) {
    if (format == SchoolReportExportFormat.json) {
      return const JsonEncoder.withIndent('  ').convert(report);
    }
    return buildCsv(report: report, filterSummary: filterSummary);
  }

  static String buildFileName({
    required DateTime timestamp,
    required SchoolReportExportFormat format,
  }) {
    final safeTimestamp =
        timestamp.toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    return 'school-report-$safeTimestamp.${format.name}';
  }

  static String buildCsv({
    required Map<String, dynamic> report,
    required String filterSummary,
  }) {
    final buffer = StringBuffer();
    void row(List<Object?> values) {
      buffer.writeln(values.map(csvCell).join(','));
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
      row([
        'مقارنة الفصول',
        item['name'] ?? item['classroomName'] ?? '',
        'متوسط: ${item['averageScore'] ?? ''} | إكمال: ${item['completionRate'] ?? ''} | مهارة: ${item['topSkill'] ?? ''}',
      ]);
    }

    final weaknesses = report['weakestSkills'] as List? ?? const [];
    for (final item in weaknesses.whereType<Map<String, dynamic>>()) {
      row([
        'مهارات تحتاج دعماً',
        item['mainSkill'] ?? '',
        item['averagePercentage'] ?? '',
      ]);
    }
    return buffer.toString();
  }

  static String csvCell(Object? value) {
    final text = (value ?? '').toString().replaceAll('"', '""');
    final needsQuotes =
        text.contains(',') || text.contains('\n') || text.contains('"');
    return needsQuotes ? '"$text"' : text;
  }
}
