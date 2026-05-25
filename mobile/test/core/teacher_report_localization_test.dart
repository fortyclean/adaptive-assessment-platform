import 'package:adaptive_assessment/l10n/app_localizations_ar.dart';
import 'package:adaptive_assessment/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('teacher report labels are localized', () {
    final en = AppLocalizationsEn();
    final ar = AppLocalizationsAr();

    expect(en.assessmentReport, 'Assessment report');
    expect(en.targetPercent(80), 'Target: 80%');
    expect(en.minutesSeconds(12, 5), '12 min 5 sec');

    expect(ar.assessmentReport, 'تقرير الاختبار');
    expect(ar.targetPercent(80), 'الهدف: 80%');
    expect(ar.minutesSeconds(12, 5), '12 دقيقة 5 ثانية');
  });
}
