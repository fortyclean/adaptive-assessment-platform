import 'package:adaptive_assessment/l10n/app_localizations_ar.dart';
import 'package:adaptive_assessment/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('teacher dashboard labels are localized', () {
    final en = AppLocalizationsEn();
    final ar = AppLocalizationsAr();

    expect(en.teacherWelcome('Hassan'), 'Welcome, Hassan');
    expect(en.createNewAssessment, 'Create new assessment');
    expect(en.noAssessmentsCreatedYet, contains('not created'));

    expect(ar.teacherWelcome('حسن'), 'مرحبًا، حسن');
    expect(ar.createNewAssessment, 'إنشاء اختبار جديد');
    expect(ar.myClasses, 'فصولي');
  });
}
