import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixly_ai/features/home/widgets/service_category_card.dart';

void main() {
  group('ServiceCategoryCard', () {
    testWidgets('renders title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceCategoryCard(
              icon: Icons.plumbing,
              title: 'Plumbing',
              subtitle: 'From \$50',
              color: Colors.blue,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Plumbing'), findsOneWidget);
      expect(find.text('From \$50'), findsOneWidget);
      expect(find.byIcon(Icons.plumbing), findsOneWidget);
    });

    testWidgets('onTap is called when tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceCategoryCard(
              icon: Icons.plumbing,
              title: 'Plumbing',
              subtitle: 'From \$50',
              color: Colors.blue,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Plumbing'));
      expect(tapped, isTrue);
    });
  });
}
