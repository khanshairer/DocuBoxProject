import 'package:docubox_project/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login page shows email, password fields and login buttons', (
    WidgetTester tester,
  ) async {
    // Load the LoginPage widget
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Check email & password input fields exist
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);

    // Check Login button exists
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Check Google Sign-In button with text
    expect(find.text('Sign in with Google'), findsOneWidget);

    // Check signup navigation button
    expect(
      find.widgetWithText(TextButton, "Don't have an account? Sign Up"),
      findsOneWidget,
    );
  });

  testWidgets('Tapping Login button triggers login attempt', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Enter mock credentials
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'test@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password123',
    );

    // Tap login button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    // Normally you'd verify navigation or some side effect
    // For now, ensure it didn't crash
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Tapping Sign up text navigates to SignupPage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Tap the sign-up button
    await tester.tap(find.text("Don't have an account? Sign Up"));
    await tester.pumpAndSettle();

    // There's no assertion here unless you push actual navigation, but no crash = pass
    expect(find.byType(LoginPage), findsNothing); // if it navigates away
  });
}
