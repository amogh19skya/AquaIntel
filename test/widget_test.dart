import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquaintel/widgets/compatibility_header.dart';

void main() {
  testWidgets('CompatibilityHeader renders title and subtitle correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CompatibilityHeader(),
        ),
      ),
    );

    expect(find.text('Check Fish\nCompatibility'), findsOneWidget);
    expect(
      find.text('Find out if two fish can live together in the same aquarium.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.set_meal_rounded), findsOneWidget);
  });
}
