import 'package:adaptive_assessment/core/network/api_service.dart';
import 'package:adaptive_assessment/features/auth/repositories/admin_repository.dart';
import 'package:adaptive_assessment/features/auth/screens/user_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/localized_test_app.dart';

class UserManagementFakeRepository extends AdminRepository {
  UserManagementFakeRepository() : super(ApiService.instance);

  final users = <Map<String, dynamic>>[
    {
      '_id': 'teacher-1',
      'fullName': 'أحمد محمد',
      'email': 'ahmed@school.edu',
      'username': 'teacher_ahmed',
      'role': 'teacher',
      'isActive': true,
      'subject': 'الرياضيات',
      'classroomIds': ['class-a'],
    },
    {
      '_id': 'student-1',
      'fullName': 'سارة خالد',
      'username': 'STU-001',
      'role': 'student',
      'isActive': false,
      'grade': 'الأول المتوسط',
      'lastActive': 'لم يعتمد بعد',
      'classroomIds': ['class-a'],
    },
  ];

  int createUserCalls = 0;
  int updateUserCalls = 0;
  int deactivateUserCalls = 0;
  int reactivateUserCalls = 0;
  String? lastRoleFilter;
  bool? lastIsActiveFilter;
  Map<String, dynamic>? lastCreatePayload;
  Map<String, dynamic>? lastUpdatePayload;

  @override
  Future<List<Map<String, dynamic>>> getUsers({
    String? search,
    String? role,
    bool? isActive,
  }) async {
    lastRoleFilter = role;
    lastIsActiveFilter = isActive;
    var result = users;
    if (role != null) {
      result = result.where((user) => user['role'] == role).toList();
    }
    if (isActive != null) {
      result = result.where((user) => user['isActive'] == isActive).toList();
    }
    if (search != null && search.isNotEmpty) {
      result = result
          .where((user) =>
              '${user['fullName']} ${user['email']} ${user['username']}'
                  .toLowerCase()
                  .contains(search.toLowerCase()))
          .toList();
    }
    return result.map(Map<String, dynamic>.from).toList();
  }

  @override
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    createUserCalls++;
    lastCreatePayload = Map<String, dynamic>.from(data);
    final created = {
      '_id': 'created-$createUserCalls',
      ...data,
      'isActive': true,
      'classroomIds': <String>[],
    };
    users.add(created);
    return created;
  }

  @override
  Future<Map<String, dynamic>> updateUser(
    String id,
    Map<String, dynamic> data,
  ) async {
    updateUserCalls++;
    lastUpdatePayload = Map<String, dynamic>.from(data);
    final index = users.indexWhere((user) => user['_id'] == id);
    if (index == -1) return data;
    users[index] = {...users[index], ...data};
    return users[index];
  }

  @override
  Future<void> deactivateUser(String id) async {
    deactivateUserCalls++;
    final index = users.indexWhere((user) => user['_id'] == id);
    if (index != -1) {
      users[index] = {...users[index], 'isActive': false};
    }
  }

  @override
  Future<void> reactivateUser(String id) async {
    reactivateUserCalls++;
    final index = users.indexWhere((user) => user['_id'] == id);
    if (index != -1) {
      users[index] = {...users[index], 'isActive': true};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getClassrooms() async => [
        {
          '_id': 'class-a',
          'name': 'الأول المتوسط (أ)',
          'gradeLevel': '1',
        },
        {
          '_id': 'class-b',
          'name': 'الأول المتوسط (ب)',
          'gradeLevel': '1',
        },
      ];
}

Widget _wrap(
  UserManagementFakeRepository repository, {
  String? initialFilter,
}) =>
    pumpLocalizedApp(
      UserManagementScreen(initialFilter: initialFilter),
      overrides: [adminRepositoryProvider.overrideWithValue(repository)],
    );

Future<void> _pumpUserManagement(
  WidgetTester tester,
  UserManagementFakeRepository repository, {
  String? initialFilter,
}) async {
  await tester.binding.setSurfaceSize(const Size(900, 2400));
  addTearDown(() async => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_wrap(repository, initialFilter: initialFilter));
  await tester.pumpAndSettle();
}

void main() {
  group('UserManagementScreen admin flow', () {
    testWidgets('creates a user and refreshes the list', (tester) async {
      final repository = UserManagementFakeRepository();
      await _pumpUserManagement(tester, repository);

      await tester.tap(find.text('إضافة مستخدم'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'الاسم الكامل'),
        'ليلى صالح',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'اسم المستخدم'),
        'teacher_laila',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'البريد الإلكتروني'),
        'laila@school.edu',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'كلمة المرور'),
        'Strong123',
      );
      await tester.tap(find.text('إنشاء'));
      await tester.pumpAndSettle();

      expect(repository.createUserCalls, 1);
      expect(repository.lastCreatePayload?['fullName'], 'ليلى صالح');
      expect(repository.lastCreatePayload?['role'], 'teacher');
      expect(find.text('ليلى صالح'), findsOneWidget);
    });

    testWidgets('edits user profile and classroom assignments', (tester) async {
      final repository = UserManagementFakeRepository();
      await _pumpUserManagement(tester, repository);

      await tester.tap(find.text('تعديل').first);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'الاسم الكامل'),
        'أحمد محمد المحدث',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'البريد الإلكتروني'),
        'updated@school.edu',
      );
      await tester.tap(find.text('حفظ التغييرات'));
      await tester.pumpAndSettle();

      expect(repository.updateUserCalls, 1);
      expect(repository.lastUpdatePayload?['fullName'], 'أحمد محمد المحدث');
      expect(repository.lastUpdatePayload?['email'], 'updated@school.edu');
      expect(repository.lastUpdatePayload?['classroomIds'], ['class-a']);
      expect(find.text('أحمد محمد المحدث'), findsOneWidget);
    });

    testWidgets('deactivates active users with confirmation', (tester) async {
      final repository = UserManagementFakeRepository();
      await _pumpUserManagement(tester, repository);

      await tester.tap(find.text('إيقاف').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('تعطيل').last);
      await tester.pumpAndSettle();

      expect(repository.deactivateUserCalls, 1);
      expect(repository.users.first['isActive'], isFalse);
      expect(find.text('تم تعطيل الحساب'), findsOneWidget);
    });

    testWidgets('pending filter requests inactive users and approves them',
        (tester) async {
      final repository = UserManagementFakeRepository();
      await _pumpUserManagement(
        tester,
        repository,
        initialFilter: 'pending',
      );

      expect(repository.lastRoleFilter, isNull);
      expect(repository.lastIsActiveFilter, isFalse);
      expect(find.text('سارة خالد'), findsOneWidget);
      expect(find.text('أحمد محمد'), findsNothing);

      await tester.tap(find.text('اعتماد'));
      await tester.pumpAndSettle();

      expect(repository.reactivateUserCalls, 1);
      expect(
        repository.users
            .firstWhere((user) => user['_id'] == 'student-1')['isActive'],
        isTrue,
      );
    });
  });
}
