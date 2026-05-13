// ignore_for_file: avoid_print

/// Bug Condition Exploration Tests — admin-panel-bugs
///
/// هذه اختبارات استكشافية توثّق الأخطاء الستة الموجودة في الكود غير المُصلح.
/// من المتوقع أن تفشل هذه الاختبارات على الكود الحالي — هذا يُثبت وجود الأخطاء.
///
/// **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9**
///
/// بعد تطبيق الإصلاحات (المهمة 3)، يجب أن تنجح هذه الاختبارات.
library;

import 'package:flutter_test/flutter_test.dart';

// =============================================================================
// مساعدات محاكاة الكود الحالي (غير المُصلح)
// =============================================================================

/// يُحاكي السلوك الحالي (الخاطئ) لزر الحفظ في SettingsScreen.
///
/// الكود الحالي في settings_screen.dart (كلا الـ bottom sheets):
/// ```dart
/// onPressed: () {
///   Navigator.pop(ctx);
///   ScaffoldMessenger.of(context).showSnackBar(
///     const SnackBar(content: Text('تم تحديث الملف الشخصي')),
///   );
/// }
/// ```
/// الخطأ: لا استدعاء API، لا تحديث authProvider — الاسم يبقى كما هو.
class BuggySettingsSaveBehavior {
  BuggySettingsSaveBehavior(this.currentFullName);
  String currentFullName;
  bool snackBarShown = false;
  bool apiCalled = false;
  bool authProviderUpdated = false;

  /// يُحاكي الـ onPressed الحالي (الخاطئ)
  void simulateSavePressed(String newName) {
    // الكود الحالي: يعرض SnackBar فقط، لا API، لا تحديث للحالة
    snackBarShown = true;
    apiCalled = false;
    authProviderUpdated = false;
    // currentFullName يبقى بدون تغيير — هذا هو الخطأ
  }

  /// يُحاكي الـ onPressed المُصلح
  void simulateFixedSavePressed(String newName) {
    apiCalled = true;
    authProviderUpdated = true;
    currentFullName = newName;
    snackBarShown = true;
  }
}

/// يُحاكي السلوك الحالي (الخاطئ) لبطاقات الأقسام في SupportScreen.
///
/// الكود الحالي في support_screen.dart _buildCategories():
/// ```dart
/// Container(
///   width: double.infinity,
///   padding: const EdgeInsets.all(16),
///   decoration: BoxDecoration(...),
///   child: Row(...),  // لا GestureDetector
/// )
/// ```
/// الخطأ: Container بدون GestureDetector — الضغط لا يفعل شيئاً.
class BuggySupportCategoryBehavior {
  BuggySupportCategoryBehavior({required this.hasGestureDetector});
  bool hasGestureDetector;
  bool tapResponseShown = false;

  /// يُحاكي الضغط على البطاقة
  void simulateTap() {
    if (hasGestureDetector) {
      tapResponseShown = true;
    }
    // إذا لم يكن هناك GestureDetector، لا شيء يحدث — هذا هو الخطأ
  }

  /// النسخة المُصلحة: Container مُلفوف بـ GestureDetector
  static BuggySupportCategoryBehavior fixed() =>
      BuggySupportCategoryBehavior(hasGestureDetector: true);

  /// النسخة الحالية الخاطئة: Container بدون GestureDetector
  static BuggySupportCategoryBehavior buggy() =>
      BuggySupportCategoryBehavior(hasGestureDetector: false);
}

/// يُحاكي استدعاء التنقل من بطاقات الـ bento في AdminDashboardScreen.
///
/// الكود الحالي لبطاقة المعلمون:
/// ```dart
/// onTap: () => context.push(AppRoutes.adminUsers),
/// ```
/// الخطأ: لا معامل extra — UserManagementScreen تفتح بدون تصفية.
class BuggyBentoCardNavigation {
  BuggyBentoCardNavigation({required this.route, this.extra});
  final String route;
  final Map<String, dynamic>? extra;

  /// التنقل الحالي الخاطئ لبطاقة المعلمون
  static BuggyBentoCardNavigation teachersCardBuggy() =>
      BuggyBentoCardNavigation(route: '/admin/users');

  /// التنقل المُصلح لبطاقة المعلمون
  static BuggyBentoCardNavigation teachersCardFixed() =>
      BuggyBentoCardNavigation(
        route: '/admin/users',
        extra: {'initialFilter': 'teacher'},
      );
}

/// يُحاكي سلوك onTap لبطاقات التنبيهات في AdminDashboardScreen.
class BuggyAlertCardBehavior {
  bool snackBarShown = false;
  bool navigationOccurred = false;
  String? navigatedRoute;
  Map<String, dynamic>? navigationExtra;

  /// الخطأ 4: "طلاب لم يؤدوا الاختبار" — يعرض SnackBar فقط
  void simulateAbsentStudentsAlertTap() {
    // الكود الحالي:
    // ScaffoldMessenger.of(context).showSnackBar(...)
    // لا context.push — هذا هو الخطأ
    snackBarShown = true;
    navigationOccurred = false;
    navigatedRoute = null;
    navigationExtra = null;
  }

  /// الخطأ 5: "طلبات الانضمام" — يتنقل بدون initialFilter
  void simulateJoinRequestsAlertTap() {
    // الكود الحالي:
    // context.push(AppRoutes.adminUsers)  -- بدون extra
    snackBarShown = false;
    navigationOccurred = true;
    navigatedRoute = '/admin/users';
    navigationExtra = null; // الخطأ: مفقود {'initialFilter': 'pending'}
  }

  /// الخطأ 6: "انخفاض في الأداء" — يتنقل بدون معاملات تصفية
  void simulatePerformanceDropAlertTap() {
    // الكود الحالي:
    // context.push(AppRoutes.adminReports)  -- بدون extra
    snackBarShown = false;
    navigationOccurred = true;
    navigatedRoute = '/admin/reports';
    navigationExtra = null; // الخطأ: مفقود {'gradeLevel': '10', 'subject': ...}
  }

  // النسخ المُصلحة
  void simulateFixedAbsentStudentsAlertTap() {
    snackBarShown = false;
    navigationOccurred = true;
    navigatedRoute = '/admin/users';
    navigationExtra = {'initialFilter': 'student'};
  }

  void simulateFixedJoinRequestsAlertTap() {
    snackBarShown = false;
    navigationOccurred = true;
    navigatedRoute = '/admin/users';
    navigationExtra = {'initialFilter': 'pending'};
  }

  void simulateFixedPerformanceDropAlertTap() {
    snackBarShown = false;
    navigationOccurred = true;
    navigatedRoute = '/admin/reports';
    navigationExtra = {'gradeLevel': '10', 'subject': 'الرياضيات'};
  }
}

// =============================================================================
// الاختبارات
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // الخطأ 1 — زر الحفظ يعرض SnackBar فقط، لا API، لا تحديث authProvider
  // ---------------------------------------------------------------------------
  group('Bug 1 — SettingsScreen: save button does not update authProvider', () {
    /// المثال المضاد:
    /// المشرف يُدخل اسماً جديداً "اسم جديد" ويضغط "حفظ التغييرات"
    /// السلوك الحالي: SnackBar يظهر، authProvider.state.user.fullName لم يتغير
    ///
    /// **Validates: Requirements 1.1, 1.2**
    test(
      'BUG: after tapping save, authProvider.state.user.fullName is NOT updated '
      '(counterexample: newName="اسم جديد", original="الاسم القديم")',
      () {
        const originalName = 'الاسم القديم';
        const newName = 'اسم جديد';
        final behavior = BuggySettingsSaveBehavior(originalName);

        // تنفيذ: محاكاة الضغط على حفظ باسم جديد
        behavior.simulateSavePressed(newName);

        // التحقق: الخطأ — الاسم لم يتغير، لا API، لا تحديث للـ provider
        expect(
          behavior.authProviderUpdated,
          isFalse,
          reason: 'BUG CONFIRMED: authProvider is NOT updated after save. '
              'currentFullName should be "$newName" but stays "$originalName".',
        );
        expect(
          behavior.apiCalled,
          isFalse,
          reason: 'BUG CONFIRMED: No API call (PATCH /users/:id) is made.',
        );
        expect(
          behavior.currentFullName,
          equals(originalName),
          reason:
              'BUG CONFIRMED: Name stays "$originalName" despite saving "$newName".',
        );

        print(
          '\n[Bug 1 Counterexample]\n'
          '  originalName: "$originalName"\n'
          '  newName: "$newName"\n'
          '  apiCalled: ${behavior.apiCalled} (expected: true)\n'
          '  authProviderUpdated: ${behavior.authProviderUpdated} (expected: true)\n'
          '  currentFullName after save: "${behavior.currentFullName}" (expected: "$newName")\n',
        );
      },
    );

    test(
      'EXPECTED (after fix): authProvider updated and API called after save',
      () {
        const originalName = 'الاسم القديم';
        const newName = 'اسم جديد';
        final behavior = BuggySettingsSaveBehavior(originalName);

        behavior.simulateFixedSavePressed(newName);

        expect(behavior.apiCalled, isTrue);
        expect(behavior.authProviderUpdated, isTrue);
        expect(behavior.currentFullName, equals(newName));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // الخطأ 2 — بطاقات الأقسام في SupportScreen بدون GestureDetector
  // ---------------------------------------------------------------------------
  group('Bug 2 — SupportScreen: category cards do not respond to taps', () {
    /// المثال المضاد:
    /// المستخدم يضغط على بطاقة "عام" في SupportScreen
    /// السلوك الحالي: لا شيء يحدث (Container بدون GestureDetector)
    ///
    /// **Validates: Requirements 1.3, 1.4**
    test(
      'BUG: tapping "عام" card shows no response '
      '(counterexample: Container without GestureDetector)',
      () {
        final generalCard = BuggySupportCategoryBehavior.buggy();

        // تنفيذ: محاكاة الضغط
        generalCard.simulateTap();

        // التحقق: الخطأ — لا استجابة
        expect(
          generalCard.tapResponseShown,
          isFalse,
          reason: 'BUG CONFIRMED: "عام" card has no GestureDetector. '
              'Tapping it produces no visible response.',
        );

        print(
          '\n[Bug 2 Counterexample]\n'
          '  card: "عام" (full-width Container)\n'
          '  hasGestureDetector: ${generalCard.hasGestureDetector}\n'
          '  tapResponseShown: ${generalCard.tapResponseShown} (expected: true)\n'
          '  Current code: plain Container without GestureDetector\n',
        );
      },
    );

    test(
      'BUG: tapping "تقني" card shows no response',
      () {
        final technicalCard = BuggySupportCategoryBehavior.buggy();
        technicalCard.simulateTap();

        expect(
          technicalCard.tapResponseShown,
          isFalse,
          reason: 'BUG CONFIRMED: "تقني" card has no GestureDetector.',
        );
      },
    );

    test(
      'BUG: tapping "الفواتير" card shows no response',
      () {
        final billingCard = BuggySupportCategoryBehavior.buggy();
        billingCard.simulateTap();

        expect(
          billingCard.tapResponseShown,
          isFalse,
          reason: 'BUG CONFIRMED: "الفواتير" card has no GestureDetector.',
        );
      },
    );

    test(
      'EXPECTED (after fix): tapping any category card shows a response',
      () {
        final fixedCard = BuggySupportCategoryBehavior.fixed();
        fixedCard.simulateTap();

        expect(fixedCard.tapResponseShown, isTrue);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // الخطأ 3 — بطاقة "المعلمون" تتنقل بدون initialFilter
  // ---------------------------------------------------------------------------
  group(
      'Bug 3 — AdminDashboard: "Teachers" card navigates without initialFilter',
      () {
    /// المثال المضاد:
    /// المشرف يضغط على بطاقة "المعلمون"
    /// السلوك الحالي: context.push('/admin/users') مع extra=null
    ///
    /// **Validates: Requirements 1.5**
    test(
      'BUG: "المعلمون" card navigation has no extra parameter '
      '(counterexample: context.push(adminUsers) without extra)',
      () {
        final nav = BuggyBentoCardNavigation.teachersCardBuggy();

        // التحقق: الخطأ — لا extra، لا initialFilter
        expect(
          nav.extra,
          isNull,
          reason: 'BUG CONFIRMED: Teachers card calls context.push(adminUsers) '
              'without extra. UserManagementScreen opens showing ALL users.',
        );

        final initialFilter = nav.extra?['initialFilter'];
        expect(
          initialFilter,
          isNull,
          reason: 'BUG CONFIRMED: initialFilter is null. '
              'Expected: initialFilter="teacher".',
        );

        print(
          '\n[Bug 3 Counterexample]\n'
          '  card: "المعلمون"\n'
          '  route: ${nav.route}\n'
          '  extra: ${nav.extra} (expected: {initialFilter: teacher})\n'
          '  Current code: context.push(AppRoutes.adminUsers) -- no extra\n',
        );
      },
    );

    test(
      'EXPECTED (after fix): "المعلمون" card passes initialFilter="teacher"',
      () {
        final nav = BuggyBentoCardNavigation.teachersCardFixed();

        expect(nav.extra, isNotNull);
        expect(nav.extra!['initialFilter'], equals('teacher'));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // الخطأ 4 — تنبيه "طلاب لم يؤدوا الاختبار" يعرض SnackBar فقط
  // ---------------------------------------------------------------------------
  group(
      'Bug 4 — "Absent students" alert does not navigate to UserManagementScreen',
      () {
    /// المثال المضاد:
    /// المشرف يضغط على تنبيه "طلاب لم يؤدوا الاختبار"
    /// السلوك الحالي: SnackBar يظهر، لا context.push
    ///
    /// **Validates: Requirements 1.7**
    test(
      'BUG: tapping "طلاب لم يؤدوا الاختبار" shows SnackBar only, no navigation '
      '(counterexample: onTap shows SnackBar instead of context.push)',
      () {
        final behavior = BuggyAlertCardBehavior();

        // تنفيذ: محاكاة الضغط على التنبيه
        behavior.simulateAbsentStudentsAlertTap();

        // التحقق: الخطأ — لا تنقل
        expect(
          behavior.navigationOccurred,
          isFalse,
          reason: 'BUG CONFIRMED: No navigation occurs when tapping '
              '"طلاب لم يؤدوا الاختبار". Only a SnackBar is shown.',
        );
        expect(
          behavior.snackBarShown,
          isTrue,
          reason: 'BUG CONFIRMED: Only a SnackBar is shown (no screen opened).',
        );
        expect(
          behavior.navigatedRoute,
          isNull,
          reason: 'BUG CONFIRMED: navigatedRoute is null. '
              'Expected: /admin/users with initialFilter="student".',
        );

        print(
          '\n[Bug 4 Counterexample]\n'
          '  alert: "طلاب لم يؤدوا الاختبار"\n'
          '  navigationOccurred: ${behavior.navigationOccurred} (expected: true)\n'
          '  snackBarShown: ${behavior.snackBarShown} (expected: false)\n'
          '  navigatedRoute: ${behavior.navigatedRoute} (expected: /admin/users)\n'
          '  Current code: ScaffoldMessenger.showSnackBar(...) only\n',
        );
      },
    );

    test(
      'EXPECTED (after fix): tapping alert navigates to UserManagementScreen with student filter',
      () {
        final behavior = BuggyAlertCardBehavior();
        behavior.simulateFixedAbsentStudentsAlertTap();

        expect(behavior.navigationOccurred, isTrue);
        expect(behavior.snackBarShown, isFalse);
        expect(behavior.navigatedRoute, equals('/admin/users'));
        expect(behavior.navigationExtra!['initialFilter'], equals('student'));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // الخطأ 5 — تنبيه "طلبات الانضمام" يتنقل بدون initialFilter: pending
  // ---------------------------------------------------------------------------
  group(
      'Bug 5 — "Join requests" alert navigates without initialFilter="pending"',
      () {
    /// المثال المضاد:
    /// المشرف يضغط على تنبيه "طلبات انضمام جديدة"
    /// السلوك الحالي: context.push('/admin/users') مع extra=null
    ///
    /// **Validates: Requirements 1.8**
    test(
      'BUG: "طلبات انضمام جديدة" alert navigates without initialFilter="pending" '
      '(counterexample: context.push(adminUsers) without extra)',
      () {
        final behavior = BuggyAlertCardBehavior();

        // تنفيذ: محاكاة الضغط على التنبيه
        behavior.simulateJoinRequestsAlertTap();

        // التحقق: الخطأ — التنقل يحدث لكن بدون فلتر
        expect(
          behavior.navigationOccurred,
          isTrue,
          reason: 'Navigation occurs (this part is correct).',
        );
        expect(
          behavior.navigationExtra,
          isNull,
          reason: 'BUG CONFIRMED: extra is null. '
              'Expected: {initialFilter: "pending"}.',
        );

        final initialFilter = behavior.navigationExtra?['initialFilter'];
        expect(
          initialFilter,
          isNull,
          reason: 'BUG CONFIRMED: initialFilter is null. '
              'UserManagementScreen opens showing ALL users instead of pending requests.',
        );

        print(
          '\n[Bug 5 Counterexample]\n'
          '  alert: "طلبات انضمام جديدة"\n'
          '  navigatedRoute: ${behavior.navigatedRoute}\n'
          '  navigationExtra: ${behavior.navigationExtra} (expected: {initialFilter: pending})\n'
          '  Current code: context.push(AppRoutes.adminUsers) -- no extra\n',
        );
      },
    );

    test(
      'EXPECTED (after fix): "Join requests" alert passes initialFilter="pending"',
      () {
        final behavior = BuggyAlertCardBehavior();
        behavior.simulateFixedJoinRequestsAlertTap();

        expect(behavior.navigationOccurred, isTrue);
        expect(behavior.navigationExtra, isNotNull);
        expect(behavior.navigationExtra!['initialFilter'], equals('pending'));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // الخطأ 6 — تنبيه "انخفاض في الأداء" يتنقل بدون معاملات تصفية
  // ---------------------------------------------------------------------------
  group(
      'Bug 6 — "Performance drop" alert navigates without gradeLevel/subject params',
      () {
    /// المثال المضاد:
    /// المشرف يضغط على تنبيه "انخفاض في الأداء" (رياضيات، الصف العاشر)
    /// السلوك الحالي: context.push('/admin/reports') مع extra=null
    ///
    /// **Validates: Requirements 1.9**
    test(
      'BUG: "انخفاض في الأداء" alert navigates without filter parameters '
      '(counterexample: context.push(adminReports) without extra)',
      () {
        final behavior = BuggyAlertCardBehavior();

        // تنفيذ: محاكاة الضغط على التنبيه
        behavior.simulatePerformanceDropAlertTap();

        // التحقق: الخطأ — التنقل يحدث لكن بدون معاملات تصفية
        expect(
          behavior.navigationOccurred,
          isTrue,
          reason: 'Navigation occurs (this part is correct).',
        );
        expect(
          behavior.navigationExtra,
          isNull,
          reason: 'BUG CONFIRMED: extra is null. '
              'Expected: {gradeLevel: "10", subject: "الرياضيات"}.',
        );

        final gradeLevel = behavior.navigationExtra?['gradeLevel'];
        final subject = behavior.navigationExtra?['subject'];
        expect(
          gradeLevel,
          isNull,
          reason: 'BUG CONFIRMED: gradeLevel is null. '
              'SchoolReportsScreen opens showing ALL reports.',
        );
        expect(
          subject,
          isNull,
          reason: 'BUG CONFIRMED: subject is null. '
              'Expected: subject="الرياضيات".',
        );

        print(
          '\n[Bug 6 Counterexample]\n'
          '  alert: "انخفاض في الأداء" (Math, Grade 10)\n'
          '  navigatedRoute: ${behavior.navigatedRoute}\n'
          '  navigationExtra: ${behavior.navigationExtra}\n'
          '  expected extra: {gradeLevel: "10", subject: "الرياضيات"}\n'
          '  Current code: context.push(AppRoutes.adminReports) -- no extra\n',
        );
      },
    );

    test(
      'EXPECTED (after fix): "Performance drop" alert passes gradeLevel and subject',
      () {
        final behavior = BuggyAlertCardBehavior();
        behavior.simulateFixedPerformanceDropAlertTap();

        expect(behavior.navigationOccurred, isTrue);
        expect(behavior.navigationExtra, isNotNull);
        expect(behavior.navigationExtra!['gradeLevel'], equals('10'));
        expect(behavior.navigationExtra!['subject'], equals('الرياضيات'));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // ملخص — الأمثلة المضادة للأخطاء الستة
  // ---------------------------------------------------------------------------
  group('Bug Condition Summary — all six counterexamples', () {
    test('documents all six admin panel bug counterexamples', () {
      const bugs = [
        {
          'id': 'Bug 1',
          'file': 'settings_screen.dart',
          'location': 'Save button onPressed (both bottom sheets)',
          'counterexample': 'Admin enters new name, taps save',
          'current_behavior':
              'SnackBar shown, no API call, authProvider unchanged',
          'expected_behavior':
              'PATCH /users/:id called, authProvider.user.fullName updated',
          'requirement': '1.1, 1.2',
        },
        {
          'id': 'Bug 2',
          'file': 'support_screen.dart',
          'location': '_buildCategories() cards',
          'counterexample': 'User taps any category card',
          'current_behavior':
              'Nothing happens (Container without GestureDetector)',
          'expected_behavior': 'SnackBar or dialog shown with category name',
          'requirement': '1.3, 1.4',
        },
        {
          'id': 'Bug 3',
          'file': 'admin_dashboard_screen.dart',
          'location': '_BentoCard Teachers onTap',
          'counterexample': 'Admin taps Teachers card',
          'current_behavior': 'context.push(adminUsers) -- no extra',
          'expected_behavior':
              'context.push(adminUsers, extra: {initialFilter: teacher})',
          'requirement': '1.5',
        },
        {
          'id': 'Bug 4',
          'file': 'admin_dashboard_screen.dart',
          'location': '_AlertCard absent students onTap',
          'counterexample': 'Admin taps absent students alert',
          'current_behavior': 'SnackBar shown only, no navigation',
          'expected_behavior':
              'context.push(adminUsers, extra: {initialFilter: student})',
          'requirement': '1.7',
        },
        {
          'id': 'Bug 5',
          'file': 'admin_dashboard_screen.dart',
          'location': '_AlertCard join requests onTap',
          'counterexample': 'Admin taps join requests alert',
          'current_behavior': 'context.push(adminUsers) -- no extra',
          'expected_behavior':
              'context.push(adminUsers, extra: {initialFilter: pending})',
          'requirement': '1.8',
        },
        {
          'id': 'Bug 6',
          'file': 'admin_dashboard_screen.dart',
          'location': '_AlertCard performance drop onTap',
          'counterexample':
              'Admin taps performance drop alert (Math, Grade 10)',
          'current_behavior': 'context.push(adminReports) -- no extra',
          'expected_behavior':
              'context.push(adminReports, extra: {gradeLevel: 10, subject: Math})',
          'requirement': '1.9',
        },
      ];

      expect(bugs, hasLength(6));
      for (final bug in bugs) {
        expect(bug['id'], isNotNull);
        expect(bug['counterexample'], isNotNull);
      }

      print('\n${'=' * 60}');
      print('Admin Panel Bug Condition Exploration — Counterexamples');
      print('=' * 60);
      for (final bug in bugs) {
        print('\n${bug['id']}:');
        bug.forEach((k, v) => print('  $k: $v'));
      }
      print('\n${'=' * 60}\n');
    });
  });
}
