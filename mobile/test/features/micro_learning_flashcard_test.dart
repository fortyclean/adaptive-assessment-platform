import 'package:adaptive_assessment/features/assessment/models/micro_learning_flashcard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MicroLearningFlashcardSource', () {
    test('builds a diagnostic deck when there is no attempt history', () {
      final deck = const MicroLearningFlashcardSource().fromAttemptHistory([]);

      expect(deck.cards, hasLength(2));
      expect(deck.title, contains('تشخيصي'));
      expect(deck.cards.first.skill, 'تشخيص');
    });

    test('builds cards from weakest skills first', () {
      final deck = const MicroLearningFlashcardSource().fromAttemptHistory([
        {
          'status': 'completed',
          'scorePercentage': 70,
          'skillBreakdown': [
            {
              'mainSkill': 'الجبر',
              'correctAnswers': 1,
              'totalQuestions': 5,
            },
            {
              'mainSkill': 'الهندسة',
              'correctAnswers': 4,
              'totalQuestions': 5,
            },
          ],
        },
      ]);

      expect(deck.title, contains('الجبر'));
      expect(deck.cards.first.skill, 'الجبر');
      expect(deck.cards.first.prompt, contains('الجبر'));
      expect(deck.cards, hasLength(4));
    });

    test('ignores incomplete attempts and malformed skills', () {
      final deck = const MicroLearningFlashcardSource().fromAttemptHistory([
        {
          'status': 'in_progress',
          'skillBreakdown': [
            {
              'mainSkill': 'القراءة',
              'correctAnswers': 1,
              'totalQuestions': 5,
            },
          ],
        },
        {
          'status': 'completed',
          'skillBreakdown': [
            {'mainSkill': '', 'correctAnswers': 1, 'totalQuestions': 5},
            {'mainSkill': 'النحو', 'correctAnswers': 0, 'totalQuestions': 0},
          ],
        },
      ]);

      expect(deck.title, contains('تشخيصي'));
      expect(deck.cards.first.skill, 'تشخيص');
    });
  });
}
