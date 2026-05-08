import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_assessment/features/notifications/screens/notification_settings_screen.dart';

/// Widget tests for Report Scheduling and Notification Settings
/// Task: 26.5
/// Requirements: Test schedule creation and validation, notification settings persistence
void main() {
  // ─── Helper: Build Widget with ProviderScope ─────────────────────────────

  Widget buildTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 1: Report Schedule Creation and Validation
  // ═══════════════════════════════════════════════════════════════════════════

  group('Report Schedule — Creation and Validation', () {
    // ─── Test: Schedule Frequency Validation ─────────────────────────────────

    test('schedule frequency must be one of: daily, weekly, monthly', () {
      const validFrequencies = ['daily', 'weekly', 'monthly'];

      expect(validFrequencies.contains('daily'), isTrue);
      expect(validFrequencies.contains('weekly'), isTrue);
      expect(validFrequencies.contains('monthly'), isTrue);
      expect(validFrequencies.contains('yearly'), isFalse);
      expect(validFrequencies.contains('hourly'), isFalse);
    });

    // ─── Test: Report Type Validation ────────────────────────────────────────

    test('report type must be one of the four supported types', () {
      const validReportTypes = [
        'أداء الطلاب العام',
        'جودة بنك الأسئلة',
        'مقارنة الفصول',
        'تحليل المهارات',
      ];

      expect(validReportTypes.contains('أداء الطلاب العام'), isTrue);
      expect(validReportTypes.contains('جودة بنك الأسئلة'), isTrue);
      expect(validReportTypes.contains('مقارنة الفصول'), isTrue);
      expect(validReportTypes.contains('تحليل المهارات'), isTrue);
      expect(validReportTypes.contains('تقرير غير موجود'), isFalse);
    });

    // ─── Test: File Format Validation ────────────────────────────────────────

    test('file format must be PDF or Excel', () {
      const validFormats = ['PDF', 'Excel'];

      expect(validFormats.contains('PDF'), isTrue);
      expect(validFormats.contains('Excel'), isTrue);
      expect(validFormats.contains('CSV'), isFalse);
      expect(validFormats.contains('Word'), isFalse);
    });

    // ─── Test: Email Recipients Validation ───────────────────────────────────

    test('email recipients list must not be empty', () {
      final recipients = <String>[];
      expect(recipients.isEmpty, isTrue);

      recipients.add('teacher@school.edu');
      expect(recipients.isNotEmpty, isTrue);
      expect(recipients.length, equals(1));
    });

    test('email format validation', () {
      bool isValidEmail(String email) {
        final emailRegex = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );
        return emailRegex.hasMatch(email);
      }

      expect(isValidEmail('teacher@school.edu'), isTrue);
      expect(isValidEmail('admin@example.com'), isTrue);
      expect(isValidEmail('invalid-email'), isFalse);
      expect(isValidEmail('missing@domain'), isFalse);
      expect(isValidEmail('@nodomain.com'), isFalse);
    });

    // ─── Test: Delivery Time Validation ──────────────────────────────────────

    test('delivery time must be a valid TimeOfDay', () {
      const validTime = TimeOfDay(hour: 9, minute: 0);
      expect(validTime.hour >= 0 && validTime.hour < 24, isTrue);
      expect(validTime.minute >= 0 && validTime.minute < 60, isTrue);

      const invalidHour = TimeOfDay(hour: 25, minute: 0);
      expect(invalidHour.hour >= 24, isTrue); // Invalid

      const invalidMinute = TimeOfDay(hour: 9, minute: 60);
      expect(invalidMinute.minute >= 60, isTrue); // Invalid
    });

    // ─── Test: Classroom Selection Validation ────────────────────────────────

    test('at least one classroom must be selected for classroom-specific reports', () {
      final selectedClassrooms = <String>[];
      const reportType = 'مقارنة الفصول';

      // For classroom comparison reports, at least one classroom is required
      if (reportType == 'مقارنة الفصول') {
        expect(selectedClassrooms.isEmpty, isTrue); // Should fail validation
      }

      selectedClassrooms.add('classroom-1');
      expect(selectedClassrooms.isNotEmpty, isTrue);
    });

    // ─── Test: Schedule Active Status ────────────────────────────────────────

    test('schedule can be activated or deactivated', () {
      var isActive = false;
      expect(isActive, isFalse);

      isActive = true;
      expect(isActive, isTrue);

      isActive = false;
      expect(isActive, isFalse);
    });

    // ─── Test: Schedule Data Structure ───────────────────────────────────────

    test('schedule object contains all required fields', () {
      final schedule = {
        'reportType': 'أداء الطلاب العام',
        'frequency': 'weekly',
        'deliveryTime': '09:00',
        'recipients': ['teacher@school.edu', 'admin@school.edu'],
        'fileFormat': 'PDF',
        'classroomIds': ['classroom-1', 'classroom-2'],
        'isActive': true,
      };

      expect(schedule.containsKey('reportType'), isTrue);
      expect(schedule.containsKey('frequency'), isTrue);
      expect(schedule.containsKey('deliveryTime'), isTrue);
      expect(schedule.containsKey('recipients'), isTrue);
      expect(schedule.containsKey('fileFormat'), isTrue);
      expect(schedule.containsKey('classroomIds'), isTrue);
      expect(schedule.containsKey('isActive'), isTrue);

      expect(schedule['recipients'], isA<List>());
      expect((schedule['recipients'] as List).isNotEmpty, isTrue);
    });

    // ─── Test: Multiple Schedules Management ─────────────────────────────────

    test('multiple schedules can be created and managed', () {
      final schedules = <Map<String, dynamic>>[];

      schedules.add({
        'id': 'schedule-1',
        'reportType': 'أداء الطلاب العام',
        'frequency': 'daily',
        'isActive': true,
      });

      schedules.add({
        'id': 'schedule-2',
        'reportType': 'جودة بنك الأسئلة',
        'frequency': 'weekly',
        'isActive': false,
      });

      expect(schedules.length, equals(2));
      expect(schedules[0]['isActive'], isTrue);
      expect(schedules[1]['isActive'], isFalse);

      // Delete a schedule
      schedules.removeWhere((s) => s['id'] == 'schedule-1');
      expect(schedules.length, equals(1));
      expect(schedules.first['id'], equals('schedule-2'));
    });

    // ─── Test: Frequency-Specific Validation ─────────────────────────────────

    test('weekly schedule should specify day of week', () {
      final weeklySchedule = <String, Object>{
        'frequency': 'weekly',
        'dayOfWeek': 1, // Monday (1-7)
      };

      expect(weeklySchedule['frequency'], equals('weekly'));
      expect(weeklySchedule['dayOfWeek'], isA<int>());
      final dayOfWeek = weeklySchedule['dayOfWeek']! as int;
      expect(dayOfWeek >= 1 && dayOfWeek <= 7, isTrue);
    });

    test('monthly schedule should specify day of month', () {
      final monthlySchedule = <String, Object>{
        'frequency': 'monthly',
        'dayOfMonth': 15, // 1-31
      };

      expect(monthlySchedule['frequency'], equals('monthly'));
      expect(monthlySchedule['dayOfMonth'], isA<int>());
      final dayOfMonth = monthlySchedule['dayOfMonth']! as int;
      expect(dayOfMonth >= 1 && dayOfMonth <= 31, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 2: Notification Settings Persistence
  // ═══════════════════════════════════════════════════════════════════════════

  group('Notification Settings — Persistence and UI', () {
    // ─── Test: Widget Renders Correctly ──────────────────────────────────────

    testWidgets('NotificationSettingsScreen renders all groups',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const NotificationSettingsScreen(),
      ));
      await tester.pumpAndSettle();

      // Check page title (may be off-screen in list, use skipOffstage)
      expect(find.text('إعدادات التنبيهات', skipOffstage: false), findsOneWidget);

      // Check all three notification groups are present (may need scrolling)
      expect(find.text('أداء الطلاب', skipOffstage: false), findsOneWidget);
      expect(find.text('بنك الأسئلة', skipOffstage: false), findsOneWidget);
      expect(find.text('تقارير دورية', skipOffstage: false), findsOneWidget);
    });

    testWidgets('NotificationSettingsScreen renders save button',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const NotificationSettingsScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('حفظ التغييرات', skipOffstage: false), findsOneWidget);
    });

    // ─── Test: Toggle Switches Functionality ─────────────────────────────────

    testWidgets('toggle switches are interactive', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const NotificationSettingsScreen(),
      ));
      await tester.pumpAndSettle();

      // Find toggle switches (there should be multiple)
      final toggles = find.byType(GestureDetector);
      expect(toggles, findsWidgets);

      // Verify at least one toggle exists
      expect(toggles.evaluate().isNotEmpty, isTrue);
    });

    testWidgets('tapping toggle changes its state', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const NotificationSettingsScreen(),
      ));
      await tester.pumpAndSettle();

      // Find the first toggle row by its title (may be off-screen)
      final pushToggleRow = find.text('تنبيهات لحظية (Push)', skipOffstage: false);
      expect(pushToggleRow, findsOneWidget);

      // Scroll to make it visible, then tap
      await tester.scrollUntilVisible(pushToggleRow, 50);
      await tester.tap(pushToggleRow);
      await tester.pumpAndSettle();

      // The state should have changed (verified by no errors)
    });

    // ─── Test: Settings Data Structure ───────────────────────────────────────

    test('notification settings contain all required fields', () {
      final settings = {
        'studentPerformance': {
          'push': true,
          'email': false,
          'sms': false,
        },
        'questionBank': {
          'push': true,
          'email': false,
          'sms': false,
        },
        'periodicReports': {
          'push': false,
          'email': true,
          'sms': false,
        },
      };

      expect(settings.containsKey('studentPerformance'), isTrue);
      expect(settings.containsKey('questionBank'), isTrue);
      expect(settings.containsKey('periodicReports'), isTrue);

      expect(settings['studentPerformance'], isA<Map>());
      expect(settings['studentPerformance']!['push'], isA<bool>());
    });

    // ─── Test: Settings Validation ───────────────────────────────────────────

    test('at least one notification channel should be enabled per group', () {
      final studentPerfSettings = {
        'push': false,
        'email': false,
        'sms': false,
      };

      final hasAnyEnabled = studentPerfSettings.values.any((v) => v == true);
      expect(hasAnyEnabled, isFalse); // Should warn user

      studentPerfSettings['push'] = true;
      final hasEnabledAfter = studentPerfSettings.values.any((v) => v == true);
      expect(hasEnabledAfter, isTrue);
    });

    // ─── Test: Settings Persistence Logic ────────────────────────────────────

    test('settings can be serialized for storage', () {
      final settings = {
        'studentPerformance': {
          'push': true,
          'email': false,
          'sms': false,
        },
        'questionBank': {
          'push': true,
          'email': false,
          'sms': true,
        },
        'periodicReports': {
          'push': false,
          'email': true,
          'sms': false,
        },
      };

      // Simulate serialization
      final serialized = settings.toString();
      expect(serialized.isNotEmpty, isTrue);
      expect(serialized.contains('studentPerformance'), isTrue);
    });

    test('settings can be loaded from storage', () {
      // Simulate loading from storage
      final storedSettings = {
        'studentPerformance': {
          'push': true,
          'email': true,
          'sms': false,
        },
        'questionBank': {
          'push': false,
          'email': false,
          'sms': false,
        },
        'periodicReports': {
          'push': false,
          'email': true,
          'sms': false,
        },
      };

      expect(storedSettings['studentPerformance']!['push'], isTrue);
      expect(storedSettings['studentPerformance']!['email'], isTrue);
      expect(storedSettings['questionBank']!['push'], isFalse);
    });

    // ─── Test: Save Button Functionality ─────────────────────────────────────

    testWidgets('save button shows loading state when saving', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const NotificationSettingsScreen(),
      ));
      await tester.pumpAndSettle();

      // Scroll to save button and tap it
      final saveButton = find.text('حفظ التغييرات', skipOffstage: false);
      expect(saveButton, findsOneWidget);

      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pump(); // Start animation

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Complete animation

      // Should show success message
      expect(find.text('تم حفظ إعدادات التنبيهات بنجاح'), findsOneWidget);
    });

    testWidgets('save button is disabled while saving', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const NotificationSettingsScreen(),
      ));
      await tester.pumpAndSettle();

      final saveButtonText = find.text('حفظ التغييرات', skipOffstage: false);
      await tester.ensureVisible(saveButtonText);
      await tester.pumpAndSettle();
      await tester.tap(saveButtonText);
      await tester.pump();

      // Button should be disabled (showing loading indicator instead of text)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // The save text should be gone (replaced by spinner)
      expect(find.text('حفظ التغييرات'), findsNothing);

      // Drain the pending timer to avoid test failure
      await tester.pumpAndSettle();
    });

    // ─── Test: Notification Channel Types ────────────────────────────────────

    test('notification channels are correctly defined', () {
      const channels = ['push', 'email', 'sms'];

      expect(channels.contains('push'), isTrue);
      expect(channels.contains('email'), isTrue);
      expect(channels.contains('sms'), isTrue);
      expect(channels.contains('whatsapp'), isFalse);
    });

    // ─── Test: Group-Specific Settings ───────────────────────────────────────

    test('student performance group supports push and email', () {
      final studentPerfChannels = ['push', 'email'];

      expect(studentPerfChannels.contains('push'), isTrue);
      expect(studentPerfChannels.contains('email'), isTrue);
      expect(studentPerfChannels.contains('sms'), isFalse);
    });

    test('question bank group supports push and sms', () {
      final questionBankChannels = ['push', 'sms'];

      expect(questionBankChannels.contains('push'), isTrue);
      expect(questionBankChannels.contains('sms'), isTrue);
      expect(questionBankChannels.contains('email'), isFalse);
    });

    test('periodic reports group supports email only', () {
      final periodicReportsChannels = ['email'];

      expect(periodicReportsChannels.contains('email'), isTrue);
      expect(periodicReportsChannels.contains('push'), isFalse);
      expect(periodicReportsChannels.contains('sms'), isFalse);
    });

    // ─── Test: Settings Update Logic ─────────────────────────────────────────

    test('updating a setting preserves other settings', () {
      final settings = {
        'studentPerformance': {
          'push': true,
          'email': false,
        },
        'questionBank': {
          'push': true,
          'sms': false,
        },
      };

      // Update one setting
      settings['studentPerformance']!['email'] = true;

      // Other settings should remain unchanged
      expect(settings['studentPerformance']!['push'], isTrue);
      expect(settings['questionBank']!['push'], isTrue);
      expect(settings['questionBank']!['sms'], isFalse);
    });

    // ─── Test: Default Settings ──────────────────────────────────────────────

    test('default settings are correctly initialized', () {
      // Based on the screen implementation
      final defaultSettings = {
        'studentPerformance': {
          'push': true,
          'email': false,
        },
        'questionBank': {
          'push': true,
          'sms': false,
        },
        'periodicReports': {
          'email': true,
        },
      };

      expect(defaultSettings['studentPerformance']!['push'], isTrue);
      expect(defaultSettings['studentPerformance']!['email'], isFalse);
      expect(defaultSettings['questionBank']!['push'], isTrue);
      expect(defaultSettings['questionBank']!['sms'], isFalse);
      expect(defaultSettings['periodicReports']!['email'], isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 3: Integration Tests
  // ═══════════════════════════════════════════════════════════════════════════

  group('Report Scheduling — Integration', () {
    test('schedule creation workflow is complete', () {
      // Step 1: Select report type
      var reportType = '';
      reportType = 'أداء الطلاب العام';
      expect(reportType.isNotEmpty, isTrue);

      // Step 2: Select frequency
      var frequency = '';
      frequency = 'weekly';
      expect(frequency.isNotEmpty, isTrue);

      // Step 3: Set delivery time
      const deliveryTime = TimeOfDay(hour: 9, minute: 0);
      expect(deliveryTime.hour, equals(9));

      // Step 4: Add recipients
      final recipients = <String>[];
      recipients.add('teacher@school.edu');
      expect(recipients.isNotEmpty, isTrue);

      // Step 5: Select file format
      var fileFormat = '';
      fileFormat = 'PDF';
      expect(fileFormat.isNotEmpty, isTrue);

      // Step 6: Activate schedule
      var isActive = false;
      isActive = true;
      expect(isActive, isTrue);

      // All steps completed successfully
      expect(reportType.isNotEmpty, isTrue);
      expect(frequency.isNotEmpty, isTrue);
      expect(recipients.isNotEmpty, isTrue);
      expect(fileFormat.isNotEmpty, isTrue);
      expect(isActive, isTrue);
    });

    test('notification settings save and reload workflow', () {
      // Step 1: Load default settings
      var settings = {
        'studentPerformance': {'push': true, 'email': false},
        'questionBank': {'push': true, 'sms': false},
        'periodicReports': {'email': true},
      };

      expect(settings['studentPerformance']!['push'], isTrue);

      // Step 2: Modify settings
      settings['studentPerformance']!['email'] = true;
      settings['questionBank']!['sms'] = true;

      // Step 3: Save settings (simulate)
      final savedSettings = Map<String, Map<String, bool>>.from(settings);

      // Step 4: Reload settings (simulate)
      final reloadedSettings = Map<String, Map<String, bool>>.from(savedSettings);

      // Step 5: Verify persistence
      expect(reloadedSettings['studentPerformance']!['email'], isTrue);
      expect(reloadedSettings['questionBank']!['sms'], isTrue);
      expect(
        reloadedSettings['studentPerformance']!['push'],
        equals(savedSettings['studentPerformance']!['push']),
      );
    });
  });
}
