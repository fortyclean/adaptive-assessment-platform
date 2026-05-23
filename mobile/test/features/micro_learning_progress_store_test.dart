import 'dart:io';

import 'package:adaptive_assessment/features/assessment/repositories/micro_learning_progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> box;
  late MicroLearningProgressStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('micro_learning_store_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('session_state');
    store = MicroLearningProgressStore(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('persists completed lesson ids per user', () async {
    final completed = await store.markCompleted('student-1', 'lesson-a');

    expect(completed, {'lesson-a'});
    expect(store.loadCompletedLessonIds('student-1'), {'lesson-a'});
    expect(store.loadCompletedLessonIds('student-2'), isEmpty);
  });

  test('does not duplicate completed lesson ids', () async {
    await store.markCompleted('student-1', 'lesson-a');
    final completed = await store.markCompleted('student-1', 'lesson-a');

    expect(completed, {'lesson-a'});
    expect(store.loadCompletedLessonIds('student-1'), {'lesson-a'});
  });

  test('records flashcard practice sessions per user', () async {
    await store.recordFlashcardSession(
      userId: 'student-1',
      correctCount: 3,
      totalCount: 4,
      focusSkill: 'الجبر',
      completedAt: DateTime.utc(2026),
    );

    final sessions = store.loadFlashcardSessions('student-1');
    expect(sessions, hasLength(1));
    expect(sessions.single['correctCount'], 3);
    expect(sessions.single['totalCount'], 4);
    expect(sessions.single['focusSkill'], 'الجبر');
    expect(store.loadFlashcardSessions('student-2'), isEmpty);
  });
}
