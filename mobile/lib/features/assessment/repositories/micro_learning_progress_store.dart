import 'package:hive_flutter/hive_flutter.dart';

class MicroLearningProgressStore {
  const MicroLearningProgressStore(this._box);

  final Box<dynamic> _box;

  static String keyForUser(String? userId) =>
      'micro_learning_completed_lessons_${userId ?? 'guest'}';

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
}
