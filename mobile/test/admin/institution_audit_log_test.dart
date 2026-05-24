import 'package:adaptive_assessment/core/network/api_service.dart';
import 'package:adaptive_assessment/features/auth/repositories/admin_repository.dart';
import 'package:adaptive_assessment/features/auth/screens/institution_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstitutionAuditFakeRepository extends AdminRepository {
  InstitutionAuditFakeRepository({
    this.logs = const [],
    this.throwOnAudit = false,
  }) : super(ApiService.instance);

  final List<Map<String, dynamic>> logs;
  final bool throwOnAudit;
  int getAuditLogsCalls = 0;
  int? lastLimit;

  @override
  Future<Map<String, dynamic>> getInstitutionSettings() async => {
        'schoolName': 'مدرسة التدقيق',
        'schoolPhone': '+966 555 000 000',
        'schoolEmail': 'audit@school.edu',
      };

  @override
  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 25}) async {
    getAuditLogsCalls++;
    lastLimit = limit;
    if (throwOnAudit) throw StateError('audit unavailable');
    return logs.map(Map<String, dynamic>.from).toList();
  }
}

Future<void> _pumpScreen(
  WidgetTester tester,
  InstitutionAuditFakeRepository repository,
) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        adminRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: InstitutionSettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openAuditSheet(WidgetTester tester) async {
  await tester.tap(find.text('سجلات الأنشطة'));
  await tester.pumpAndSettle();
}

void main() {
  group('InstitutionSettingsScreen audit log visibility', () {
    testWidgets('loads and displays sensitive audit log rows', (tester) async {
      final repository = InstitutionAuditFakeRepository(
        logs: [
          {
            'action': 'تعطيل حساب مستخدم',
            'actorName': 'مدير النظام',
            'targetName': 'حساب طالب',
            'severity': 'high',
            'createdAt': '2026-05-24T05:00:00.000Z',
          },
          {
            'action': 'ربط معلم بفصل',
            'actorName': 'مشرف المدرسة',
            'targetName': 'الأول المتوسط (أ)',
            'severity': 'medium',
            'createdAt': '2026-05-24T04:00:00.000Z',
          },
        ],
      );

      await _pumpScreen(tester, repository);
      await _openAuditSheet(tester);

      expect(repository.getAuditLogsCalls, 1);
      expect(repository.lastLimit, 25);
      expect(find.text('سجل التدقيق'), findsOneWidget);
      expect(find.text('تعطيل حساب مستخدم'), findsOneWidget);
      expect(find.text('ربط معلم بفصل'), findsOneWidget);
      expect(find.textContaining('مدير النظام'), findsOneWidget);
    });

    testWidgets('shows an explicit empty state when there are no audit logs',
        (tester) async {
      final repository = InstitutionAuditFakeRepository();

      await _pumpScreen(tester, repository);
      await _openAuditSheet(tester);

      expect(repository.getAuditLogsCalls, 1);
      expect(find.text('لا توجد أحداث تدقيق بعد'), findsOneWidget);
      expect(find.textContaining('تعطيل الحسابات'), findsOneWidget);
    });

    testWidgets(
        'does not hide production audit loading errors behind mock data',
        (tester) async {
      final repository = InstitutionAuditFakeRepository(throwOnAudit: true);

      await _pumpScreen(tester, repository);
      await _openAuditSheet(tester);

      expect(repository.getAuditLogsCalls, 1);
      expect(find.text('تعذر تحميل سجل التدقيق'), findsOneWidget);
      expect(find.textContaining('لا يتم عرض بيانات وهمية'), findsOneWidget);
    });
  });
}
