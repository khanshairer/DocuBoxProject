import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docubox_project/screens/signup_page.dart';

void main() {
  testWidgets('Signup page shows email, password fields and signup buttons', (
    WidgetTester tester,
  ) async {
    // Build the SignupPage widget
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    // Check for the presence of the email and password fields
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);

    // Check for the main Sign Up button
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);

    // Check for the Google Sign Up option
    expect(find.text('Sign up with Google'), findsOneWidget);
    expect(
      find.byType(GestureDetector),
      findsWidgets,
    ); // multiple GestureDetectors including Google
  });

  testWidgets('Entering email and password and tapping Sign Up button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    // Enter fake email and password
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'newuser@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'securePassword',
    );

    // Tap the Sign Up button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    // Still on SignupPage unless navigation happens
    expect(find.byType(SignupPage), findsOneWidget);
  });

  testWidgets('Tapping Sign up with Google triggers Google flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    // Tap the "Sign up with Google" text area
    await tester.tap(find.text('Sign up with Google'));
    await tester.pump();

    // We can't test actual Firebase/Google interaction here,
    // but we make sure it didn't crash
    expect(find.byType(SignupPage), findsOneWidget);
  });
}
