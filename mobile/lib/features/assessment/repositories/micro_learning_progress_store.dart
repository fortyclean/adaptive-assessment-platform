import 'package:hive_flutter/hive_flutter.dart';

class MicroLearningProgressStore {
  const MicroLearningProgressStore(this._box);

  final Box<dynamic> _box;

  static String keyForUser(String? userId) =>
      'micro_learning_completed_lessons_${userId ?? 'guest'}';

  static String flashcardSessionsKeyForUser(String? userId) =>
      'micro_learning_flashcard_sessions_${userId ?? 'guest'}';

  Set<String> loadCompletedLessonIds(String? userId) {
    final saved = _box.get(keyForUser(userId));
    if (saved is List) {
      return saved.map((id) => id.toString()).toSet();
    }
    return {};
  }

  Future<Set<String>> markCompleted(String? userId, String lessonId) async {
    final completed = {...loadCompletedLessonIds(userId), lessonId};
    await _box.put(keyForUser(userId), completed.toList(growable: false));
    return completed;
  }

  List<Map<String, dynamic>> loadFlashcardSessions(String? userId) {
    final saved = _box.get(flashcardSessionsKeyForUser(userId));
    if (saved is! List) return const [];
    return saved
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> recordFlashcardSession({
    required String? userId,
    required int correctCount,
    required int totalCount,
    required String focusSkill,
    DateTime? completedAt,
  }) async {
    final sessions = loadFlashcardSessions(userId).toList();
    sessions.add({
      'correctCount': correctCount,
      'totalCount': totalCount,
      'focusSkill': focusSkill,
      'completedAt': (completedAt ?? DateTime.now()).toIso8601String(),
    });
    await _box.put(
      flashcardSessionsKeyForUser(userId),
      sessions.take(20).toList(growable: false),
    );
    return sessions;
  }
}
