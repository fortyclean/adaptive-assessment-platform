import 'package:adaptive_assessment/l10n/app_localizations_ar.dart';
import 'package:adaptive_assessment/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('report schedule labels are localized', () {
    final en = AppLocalizationsEn();
    final ar = AppLocalizationsAr();

    expect(en.reportScheduling, 'Report scheduling');
    expect(en.studentPerformanceReportType, 'Student performance');
    expect(en.reportsCount(3), '3 reports');
    expect(
        en.scheduleSaveFailed('network'), 'Could not save schedule: network');

    expect(ar.reportScheduling, 'جدولة التقارير');
    expect(ar.studentPerformanceReportType, 'أداء الطلاب العام');
    expect(ar.reportsCount(3), '3 تقارير');
    expect(ar.scheduleSaveFailed('network'), 'تعذر حفظ الجدول الزمني: network');
  });
}
