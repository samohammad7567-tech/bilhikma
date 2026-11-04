import 'package:bilhikma/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the error widget for an unusable image url', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppNetworkImage(
          url: 'qa-quiz-fields/card-a.png',
          errorWidget: Icon(Icons.broken_image_outlined),
        ),
      ),
    );

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });
}
