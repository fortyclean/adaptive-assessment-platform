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
}
