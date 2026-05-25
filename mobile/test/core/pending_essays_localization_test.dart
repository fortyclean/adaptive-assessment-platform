import 'package:adaptive_assessment/l10n/app_localizations_ar.dart';
import 'package:adaptive_assessment/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pending essay labels are localized', () {
    final en = AppLocalizationsEn();
    final ar = AppLocalizationsAr();

    expect(en.pendingEssaysTitle, 'Essay questions — pending grading');
    expect(en.noPendingEssaysTitle, 'No essay questions pending grading');
    expect(en.questionsCount(2), '2 questions');

    expect(ar.pendingEssaysTitle, 'الأسئلة المقالية — بانتظار التصحيح');
    expect(ar.noPendingEssaysTitle, 'لا توجد أسئلة مقالية بانتظار التصحيح');
    expect(ar.questionsCount(2), '2 سؤال');
  });
}
