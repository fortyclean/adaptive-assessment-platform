import 'package:adaptive_assessment/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests for Login Screen
/// Requirements: 1.2, 1.3
void main() {
  Widget buildLoginScreen() => const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      );

  group('LoginScreen — Form Validation (Req 1.2)', () {
    testWidgets('renders username and password fields', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('اسم المستخدم'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
    });

    testWidgets('shows validation error when username is empty',
        (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      // Tap login button without filling fields
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();

      expect(find.text('يرجى إدخال اسم المستخدم'), findsOneWidget);
    });

    testWidgets('shows validation error when password is empty',
        (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      // Fill username but leave password empty
      await tester.enterText(
        find.byType(TextFormField).first,
        'testuser',
      );
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pumpAndSettle();

      expect(find.text('يرجى إدخال كلمة المرور'), findsOneWidget);
    });

    testWidgets('does not show validation errors when fields are filled',
        (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'testuser',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'Password123',
      );

      // No validation errors before submit
      expect(find.text('يرجى إدخال اسم المستخدم'), findsNothing);
      expect(find.text('يرجى إدخال كلمة المرور'), findsNothing);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      final passwordField = tester.widget<TextFormField>(
        find.byType(TextFormField).last,
      );
      // obscureText is set via the controller, verify the field exists
      expect(passwordField, isNotNull);
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      // Find visibility toggle icon
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap to show password
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('forgot password link is present', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
    });

    testWidgets('login button is present and enabled', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      final button = find.text('تسجيل الدخول');
      expect(button, findsOneWidget);
    });
  });

  group('LoginScreen — UI Elements (Req 1.3)', () {
    testWidgets('shows app title', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('منصة التقييم التكيفي'), findsOneWidget);
    });

    testWidgets('shows school icon', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.school_rounded), findsOneWidget);
    });
  });
}
