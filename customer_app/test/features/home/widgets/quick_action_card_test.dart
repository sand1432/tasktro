import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixly_ai/features/home/widgets/quick_action_card.dart';

void main() {
  group('QuickActionCard', () {
    testWidgets('renders icon and label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionCard(
              icon: Icons.flash_on,
              label: 'Instant\nBooking',
              color: Colors.orange,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.flash_on), findsOneWidget);
      expect(find.text('Instant\nBooking'), findsOneWidget);
    });

    testWidgets('calls onTap when pressed', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionCard(
              icon: Icons.flash_on,
              label: 'Instant',
              color: Colors.orange,
              onTap: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Instant'));
      expect(pressed, isTrue);
    });
  });
}
