import 'dart:io';

import 'package:adaptive_assessment/features/assessment/repositories/student_points_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> box;
  late StudentPointsStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('student_points_store_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('session_state');
    store = StudentPointsStore(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('deducts points and persists purchased items', () async {
    final state = await store.purchase(
      userId: 'student-1',
      itemId: 'guide',
      price: 200,
      title: 'دليل',
    );

    expect(state.balance, 2250);
    expect(state.ownedItemIds, contains('guide'));
    expect(store.load('student-1').ownedItemIds, contains('guide'));
    expect(store.load('student-2').ownedItemIds, isNot(contains('guide')));
  });

  test('rejects purchase when balance is insufficient', () async {
    expect(
      () => store.purchase(
        userId: 'student-1',
        itemId: 'expensive',
        price: 999999,
        title: 'غالي',
      ),
      throwsStateError,
    );
  });

  test('activates owned items and records transactions', () async {
    await store.purchase(
      userId: 'student-1',
      itemId: 'avatar',
      price: 100,
      title: 'أفاتار',
    );
    final state = await store.activate(
      userId: 'student-1',
      itemId: 'avatar',
      title: 'أفاتار',
    );

    expect(state.activeItemIds, contains('avatar'));
    expect(state.transactions, hasLength(2));
  });
}
