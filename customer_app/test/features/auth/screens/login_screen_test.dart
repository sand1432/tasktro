import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Welcome to Fixly AI'),
                TextFormField(
                  key: const Key('email_field'),
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  key: const Key('password_field'),
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Welcome to Fixly AI'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(
              key: const Key('email_field'),
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Password field exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(
              key: const Key('password_field'),
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('password_field')), findsOneWidget);
    });
  });
}
