import 'package:hive_flutter/hive_flutter.dart';

class StudentPointsState {
  const StudentPointsState({
    required this.balance,
    required this.ownedItemIds,
    required this.activeItemIds,
    required this.transactions,
  });

  final int balance;
  final Set<String> ownedItemIds;
  final Set<String> activeItemIds;
  final List<Map<String, dynamic>> transactions;
}

class StudentPointsStore {
  const StudentPointsStore(this._box);

  final Box<dynamic> _box;

  static String _prefix(String? userId) =>
      'student_points_${userId ?? 'guest'}';

  StudentPointsState load(
    String? userId, {
    int defaultBalance = 2450,
    Set<String> defaultOwned = const {'extra-time'},
    Set<String> defaultActive = const {'extra-time'},
  }) {
    final prefix = _prefix(userId);
    return StudentPointsState(
      balance:
          (_box.get('${prefix}_balance') as num?)?.toInt() ?? defaultBalance,
      ownedItemIds: _readSet('${prefix}_owned', defaultOwned),
      activeItemIds: _readSet('${prefix}_active', defaultActive),
      transactions: _readTransactions('${prefix}_transactions'),
    );
  }

  Future<StudentPointsState> purchase({
    required String? userId,
    required String itemId,
    required int price,
    required String title,
  }) async {
    final state = load(userId);
    if (state.ownedItemIds.contains(itemId)) return state;
    if (state.balance < price) {
      throw StateError('insufficient-points');
    }

    final next = StudentPointsState(
      balance: state.balance - price,
      ownedItemIds: {...state.ownedItemIds, itemId},
      activeItemIds: state.activeItemIds,
      transactions: [
        ...state.transactions,
        _transaction(
          type: 'purchase',
          itemId: itemId,
          title: title,
          points: -price,
        ),
      ],
    );
    await _save(userId, next);
    return next;
  }

  Future<StudentPointsState> activate({
    required String? userId,
    required String itemId,
    required String title,
  }) async {
    final state = load(userId);
    if (!state.ownedItemIds.contains(itemId)) return state;
    final next = StudentPointsState(
      balance: state.balance,
      ownedItemIds: state.ownedItemIds,
      activeItemIds: {...state.activeItemIds, itemId},
      transactions: [
        ...state.transactions,
        _transaction(
          type: 'activate',
          itemId: itemId,
          title: title,
          points: 0,
        ),
      ],
    );
    await _save(userId, next);
    return next;
  }

  Future<void> _save(String? userId, StudentPointsState state) async {
    final prefix = _prefix(userId);
    await _box.put('${prefix}_balance', state.balance);
    await _box.put('${prefix}_owned', state.ownedItemIds.toList());
    await _box.put('${prefix}_active', state.activeItemIds.toList());
    await _box.put(
      '${prefix}_transactions',
      state.transactions.take(30).toList(growable: false),
    );
  }

  Set<String> _readSet(String key, Set<String> defaults) {
    final saved = _box.get(key);
    if (saved is List) return saved.map((item) => item.toString()).toSet();
    return defaults;
  }

  List<Map<String, dynamic>> _readTransactions(String key) {
    final saved = _box.get(key);
    if (saved is! List) return const [];
    return saved
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Map<String, dynamic> _transaction({
    required String type,
    required String itemId,
    required String title,
    required int points,
  }) =>
      {
        'type': type,
        'itemId': itemId,
        'title': title,
        'points': points,
        'createdAt': DateTime.now().toIso8601String(),
      };
}
