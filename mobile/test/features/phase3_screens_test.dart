import 'package:adaptive_assessment/features/assessment/screens/marketplace_screen.dart';
import 'package:adaptive_assessment/features/assessment/screens/task_management_screen.dart';
import 'package:adaptive_assessment/features/auth/screens/institution_settings_screen.dart';
import 'package:adaptive_assessment/features/auth/screens/supervisor_dashboard_screen.dart';
import 'package:adaptive_assessment/features/auth/screens/support_screen.dart';
import 'package:adaptive_assessment/features/auth/screens/ui_feedback_screen.dart';
import 'package:adaptive_assessment/features/reports/screens/certificates_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper: wraps a widget with Directionality + ProviderScope + MaterialApp
Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );

void main() {
  // ─── Screen 66: Marketplace ───────────────────────────────────────────────
  group('MarketplaceScreen (Screen 66)', () {
    testWidgets('renders hero balance section', (tester) async {
      await tester.pumpWidget(_wrap(const MarketplaceScreen()));
      await tester.pump();

      expect(find.text('الرصيد الحالي'), findsOneWidget);
      expect(find.text('2,450'), findsOneWidget);
    });

    testWidgets('renders My Collection section', (tester) async {
      await tester.pumpWidget(_wrap(const MarketplaceScreen()));
      await tester.pump();

      expect(find.text('مجموعتي'), findsOneWidget);
      expect(find.text('وقت إضافي'), findsOneWidget);
    });

    testWidgets('renders marketplace tabs', (tester) async {
      await tester.pumpWidget(_wrap(const MarketplaceScreen()));
      await tester.pump();

      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('الأفاتار'), findsOneWidget);
      expect(find.text('القوالب'), findsOneWidget);
    });

    testWidgets('tab selection changes active tab', (tester) async {
      await tester.pumpWidget(_wrap(const MarketplaceScreen()));
      await tester.pump();

      await tester.tap(find.text('الأفاتار'));
      await tester.pump();
      // No crash — tab selection works
    });

    testWidgets('renders item cards with buy buttons', (tester) async {
      await tester.pumpWidget(_wrap(const MarketplaceScreen()));
      await tester.pump();

      expect(find.text('شراء'), findsWidgets);
    });

    testWidgets('renders bottom navigation bar', (tester) async {
      await tester.pumpWidget(_wrap(const MarketplaceScreen()));
      await tester.pump();

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الاختبارات'), findsOneWidget);
    });
  });

  // ─── Screen 67: Task Management ───────────────────────────────────────────
  group('TaskManagementScreen (Screen 67)', () {
    testWidgets('renders page title', (tester) async {
      await tester.pumpWidget(_wrap(const TaskManagementScreen()));
      await tester.pump();

      expect(find.text('إدارة المهام'), findsOneWidget);
    });

    testWidgets('renders filter chips', (tester) async {
      await tester.pumpWidget(_wrap(const TaskManagementScreen()));
      await tester.pump();

      expect(find.text('الكل'), findsOneWidget);
    });

    testWidgets('renders tab bar with three tabs', (tester) async {
      await tester.pumpWidget(_wrap(const TaskManagementScreen()));
      await tester.pump();

      expect(find.text('المهام النشطة'), findsOneWidget);
      expect(find.text('المسودات'), findsOneWidget);
      expect(find.text('المكتملة'), findsOneWidget);
    });

    testWidgets('renders assignment cards', (tester) async {
      await tester.pumpWidget(_wrap(const TaskManagementScreen()));
      await tester.pump();

      expect(find.text('الجبر المتطور: المعادلات التربيعية'), findsOneWidget);
      expect(find.text('مقدمة في قوانين نيوتن'), findsOneWidget);
    });

    testWidgets('renders completion rate progress bars', (tester) async {
      await tester.pumpWidget(_wrap(const TaskManagementScreen()));
      await tester.pump();

      expect(find.text('85%'), findsOneWidget);
      expect(find.text('42%'), findsOneWidget);
      expect(find.text('12%'), findsOneWidget);
    });

    testWidgets('renders FAB button', (tester) async {
      await tester.pumpWidget(_wrap(const TaskManagementScreen()));
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  // ─── Screen 68: Supervisor Dashboard ──────────────────────────────────────
  group('SupervisorDashboardScreen (Screen 68)', () {
    testWidgets('renders dashboard title', (tester) async {
      await tester.pumpWidget(_wrap(const SupervisorDashboardScreen()));
      await tester.pump();

      expect(find.text('لوحة تحكم المشرف'), findsOneWidget);
    });

    testWidgets('renders stats grid with 4 cards', (tester) async {
      await tester.pumpWidget(_wrap(const SupervisorDashboardScreen()));
      await tester.pump();

      expect(find.text('إجمالي الطلاب'), findsOneWidget);
      expect(find.text('المعلمون النشطون'), findsOneWidget);
      expect(find.text('متوسط الأداء العام'), findsOneWidget);
      expect(find.text('اختبارات جارية'), findsOneWidget);
    });

    testWidgets('renders subject performance chart', (tester) async {
      await tester.pumpWidget(_wrap(const SupervisorDashboardScreen()));
      await tester.pump();

      expect(find.text('أداء المواد الدراسية'), findsOneWidget);
    });

    testWidgets('renders top teachers section', (tester) async {
      await tester.pumpWidget(_wrap(const SupervisorDashboardScreen()));
      await tester.pump();

      expect(find.text('المعلمون المتميزون (هذا الشهر)'), findsOneWidget);
      expect(find.text('أ. محمد أحمد'), findsOneWidget);
    });

    testWidgets('renders admin alerts section', (tester) async {
      await tester.pumpWidget(_wrap(const SupervisorDashboardScreen()));
      await tester.pump();

      expect(find.text('تنبيهات الإدارة'), findsOneWidget);
      expect(find.text('مراجعة مطلوبة'), findsOneWidget);
    });

    testWidgets('renders quick access grid', (tester) async {
      await tester.pumpWidget(_wrap(const SupervisorDashboardScreen()));
      await tester.pump();

      expect(find.text('وصول سريع'), findsOneWidget);
      expect(find.text('الإعدادات'), findsOneWidget);
    });
  });

  // ─── Screen 69: Institution Settings ──────────────────────────────────────
  group('InstitutionSettingsScreen (Screen 69)', () {
    testWidgets('renders page title', (tester) async {
      await tester.pumpWidget(_wrap(const InstitutionSettingsScreen()));
      await tester.pump();

      expect(find.text('إعدادات المؤسسة'), findsOneWidget);
    });

    testWidgets('renders school profile card', (tester) async {
      await tester.pumpWidget(_wrap(const InstitutionSettingsScreen()));
      await tester.pump();

      expect(find.text('ملف المدرسة'), findsOneWidget);
      expect(find.text('أكاديمية المستقبل الدولية'), findsOneWidget);
    });

    testWidgets('renders settings groups', (tester) async {
      await tester.pumpWidget(_wrap(const InstitutionSettingsScreen()));
      await tester.pump();

      expect(find.text('الهيكل الأكاديمي'), findsOneWidget);
      expect(find.text('إدارة المستخدمين'), findsOneWidget);
      expect(find.text('تفضيلات النظام'), findsOneWidget);
    });

    testWidgets('renders settings items with chevrons', (tester) async {
      await tester.pumpWidget(_wrap(const InstitutionSettingsScreen()));
      await tester.pump();

      expect(find.text('الأعوام الدراسية'), findsOneWidget);
      expect(find.text('الأدوار والصلاحيات'), findsOneWidget);
      expect(find.text('اللغة والمنطقة'), findsOneWidget);
    });

    testWidgets('renders danger zone button', (tester) async {
      await tester.pumpWidget(_wrap(const InstitutionSettingsScreen()));
      await tester.pump();

      expect(find.text('أرشفة بيانات المؤسسة'), findsOneWidget);
    });
  });

  // ─── Screen 71: Certificates ──────────────────────────────────────────────
  group('CertificatesScreen (Screen 71)', () {
    testWidgets('renders page title', (tester) async {
      await tester.pumpWidget(_wrap(const CertificatesScreen()));
      await tester.pump();

      expect(find.text('الشهادات والنتائج النهائية'), findsOneWidget);
    });

    testWidgets('renders export button', (tester) async {
      await tester.pumpWidget(_wrap(const CertificatesScreen()));
      await tester.pump();

      expect(find.text('تصدير الكل'), findsOneWidget);
    });

    testWidgets('renders filter chips', (tester) async {
      await tester.pumpWidget(_wrap(const CertificatesScreen()));
      await tester.pump();

      expect(find.text('الصف التاسع - أ'), findsOneWidget);
      expect(find.text('2023 - 2024'), findsOneWidget);
    });

    testWidgets('renders certificate preview section', (tester) async {
      await tester.pumpWidget(_wrap(const CertificatesScreen()));
      await tester.pump();

      expect(find.text('تصميم الشهادة الحالية'), findsOneWidget);
      expect(find.text('نموذج معتمد'), findsOneWidget);
    });

    testWidgets('renders student list with 4 students', (tester) async {
      await tester.pumpWidget(_wrap(const CertificatesScreen()));
      await tester.pump();

      expect(find.text('أحمد علي منصور'), findsOneWidget);
      expect(find.text('سارة كمال السعدي'), findsOneWidget);
      expect(find.text('محمد خالد الحربي'), findsOneWidget);
      expect(find.text('ليلى سالم العتيبي'), findsOneWidget);
    });

    testWidgets('renders student scores', (tester) async {
      await tester.pumpWidget(_wrap(const CertificatesScreen()));
      await tester.pump();

      expect(find.text('98.5%'), findsOneWidget);
      expect(find.text('94.2%'), findsOneWidget);
    });
  });

  // ─── Screen 72: Support ───────────────────────────────────────────────────
  group('SupportScreen (Screen 72)', () {
    testWidgets('renders hero title', (tester) async {
      await tester.pumpWidget(_wrap(const SupportScreen()));
      await tester.pump();

      expect(find.text('الدعم الفني والمساعدة'), findsOneWidget);
    });

    testWidgets('renders search bar', (tester) async {
      await tester.pumpWidget(_wrap(const SupportScreen()));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders categories section', (tester) async {
      await tester.pumpWidget(_wrap(const SupportScreen()));
      await tester.pump();

      expect(find.text('الأقسام الرئيسية'), findsOneWidget);
      expect(find.text('عام'), findsOneWidget);
      expect(find.text('تقني'), findsOneWidget);
      expect(find.text('الفواتير'), findsOneWidget);
    });

    testWidgets('renders contact support section', (tester) async {
      await tester.pumpWidget(_wrap(const SupportScreen()));
      await tester.pump();

      expect(find.text('تواصل مع الدعم'), findsOneWidget);
      expect(find.text('بدء محادثة فورية'), findsOneWidget);
      expect(find.text('فتح تذكرة دعم'), findsOneWidget);
    });

    testWidgets('renders tutorials section', (tester) async {
      await tester.pumpWidget(_wrap(const SupportScreen()));
      await tester.pump();

      expect(find.text('شروحات تعليمية'), findsOneWidget);
      expect(find.text('كيفية بدء اختبارك الأول'), findsOneWidget);
      expect(find.text('فهم تقارير الأداء'), findsOneWidget);
    });
  });

  // ─── Screen 73: UI Feedback ───────────────────────────────────────────────
  group('UiFeedbackScreen (Screen 73)', () {
    testWidgets('renders page title', (tester) async {
      await tester.pumpWidget(_wrap(const UiFeedbackScreen()));
      await tester.pump();

      expect(find.text('UI Feedback Components'), findsOneWidget);
    });

    testWidgets('renders success alert', (tester) async {
      await tester.pumpWidget(_wrap(const UiFeedbackScreen()));
      await tester.pump();

      expect(find.text('Data Imported Successfully'), findsOneWidget);
    });

    testWidgets('renders error alert', (tester) async {
      await tester.pumpWidget(_wrap(const UiFeedbackScreen()));
      await tester.pump();

      expect(find.text('Failed to Save Question'), findsOneWidget);
    });

    testWidgets('renders delete modal', (tester) async {
      await tester.pumpWidget(_wrap(const UiFeedbackScreen()));
      await tester.pump();

      expect(find.text('Deleting an Exam'), findsOneWidget);
      expect(find.text('Permanently Delete'), findsOneWidget);
      expect(find.text('Cancel Action'), findsOneWidget);
    });

    testWidgets('success alert can be dismissed', (tester) async {
      await tester.pumpWidget(_wrap(const UiFeedbackScreen()));
      await tester.pump();

      // Find and tap the close button on success alert
      final closeButtons = find.byIcon(Icons.close);
      expect(closeButtons, findsWidgets);
      await tester.tap(closeButtons.first);
      await tester.pump();

      expect(find.text('Data Imported Successfully'), findsNothing);
    });

    testWidgets('renders status bento with sync percentage', (tester) async {
      await tester.pumpWidget(_wrap(const UiFeedbackScreen()));
      await tester.pump();

      expect(find.text('98.4%'), findsOneWidget);
      expect(find.text('CURRENT SYNC STATUS'), findsOneWidget);
    });

    testWidgets('renders bottom navigation', (tester) async {
      await tester.pumpWidget(_wrap(const UiFeedbackScreen()));
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
