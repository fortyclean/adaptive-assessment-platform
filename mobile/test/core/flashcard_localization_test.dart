import 'package:adaptive_assessment/l10n/app_localizations_ar.dart';
import 'package:adaptive_assessment/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('micro learning flashcard labels are localized', () {
    final en = AppLocalizationsEn();
    final ar = AppLocalizationsAr();

    expect(en.flashcardPracticeTitle, 'Flashcard practice');
    expect(en.flashcardSummaryMessage(3, 5), contains('3 of 5'));
    expect(en.flashcardSemanticsTapToReveal('Algebra'), contains('Algebra'));

    expect(ar.flashcardPracticeTitle, 'تدريب البطاقات');
    expect(ar.flashcardSummaryMessage(3, 5), contains('3'));
    expect(ar.flashcardSemanticsAnswerVisible('الجبر'), contains('الجبر'));
  });
}
