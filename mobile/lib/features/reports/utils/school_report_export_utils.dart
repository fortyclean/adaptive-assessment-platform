import 'dart:convert';

enum SchoolReportExportFormat { json, csv }

class SchoolReportExportLabels {
  const SchoolReportExportLabels({
    required this.section,
    required this.metric,
    required this.value,
    required this.report,
    required this.generatedAt,
    required this.filterScope,
    required this.summary,
    required this.classroomComparison,
    required this.weakSkills,
    required this.comparisonValueBuilder,
  });

  final String section;
  final String metric;
  final String value;
  final String report;
  final String generatedAt;
  final String filterScope;
  final String summary;
  final String classroomComparison;
  final String weakSkills;
  final String Function(
    Object averageScore,
    Object completionRate,
    Object topSkill,
  ) comparisonValueBuilder;

  static const arabic = SchoolReportExportLabels(
    section: 'القسم',
    metric: 'المؤشر',
    value: 'القيمة',
    report: 'التقرير',
    generatedAt: 'تاريخ الإنشاء',
    filterScope: 'نطاق الفلاتر',
    summary: 'الملخص',
    classroomComparison: 'مقارنة الفصول',
    weakSkills: 'مهارات تحتاج دعماً',
    comparisonValueBuilder: _arabicComparisonValue,
  );

  static String _arabicComparisonValue(
    Object averageScore,
    Object completionRate,
    Object topSkill,
  ) =>
      'متوسط: $averageScore | إكمال: $completionRate | مهارة: $topSkill';
}

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
    SchoolReportExportLabels labels = SchoolReportExportLabels.arabic,
  }) {
    if (format == SchoolReportExportFormat.json) {
      return const JsonEncoder.withIndent('  ').convert(report);
    }
    return buildCsv(
      report: report,
      filterSummary: filterSummary,
      labels: labels,
    );
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
    SchoolReportExportLabels labels = SchoolReportExportLabels.arabic,
  }) {
    final buffer = StringBuffer();
    void row(List<Object?> values) {
      buffer.writeln(values.map(csvCell).join(','));
    }

    row([labels.section, labels.metric, labels.value]);
    row([labels.report, labels.generatedAt, report['generatedAt'] ?? '']);
    row([labels.report, labels.filterScope, filterSummary]);

    final summary = report['summary'] as Map<String, dynamic>? ?? {};
    for (final entry in summary.entries) {
      row([labels.summary, entry.key, entry.value]);
    }

    final comparisons = report['classroomComparison'] as List? ?? const [];
    for (final item in comparisons.whereType<Map<String, dynamic>>()) {
      row([
        labels.classroomComparison,
        item['name'] ?? item['classroomName'] ?? '',
        labels.comparisonValueBuilder(
          (item['averageScore'] ?? '').toString(),
          (item['completionRate'] ?? '').toString(),
          (item['topSkill'] ?? '').toString(),
        ),
      ]);
    }

    final weaknesses = report['weakestSkills'] as List? ?? const [];
    for (final item in weaknesses.whereType<Map<String, dynamic>>()) {
      row([
        labels.weakSkills,
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
