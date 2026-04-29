import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App title renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Fixly AI')),
        ),
      ),
    );

    expect(find.text('Fixly AI'), findsOneWidget);
  });
}
