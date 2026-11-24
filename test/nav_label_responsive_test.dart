import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bilhikma/core/enums/app_tab_enum.dart';
import 'package:bilhikma/core/themes/app_theme.dart';
import 'package:bilhikma/core/widgets/app_nav_rail.dart';

void main() {
  const Map<String, Size> sizes = <String, Size>{
    'ipad portrait': Size(820, 1180),
    'ipad landscape': Size(1180, 820),
  };

  for (final MapEntry<String, Size> entry in sizes.entries) {
    testWidgets('nav rail labels keep their design size on ${entry.key}', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = entry.value;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: AppNavRail(
              selectedTab: AppTab.home,
              onTabSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(tester.getRect(find.byType(AppNavRail)).width, AppNavRail.width);

      final Iterable<RenderParagraph> labels = find
          .byType(RichText)
          .evaluate()
          .map((Element element) => element.renderObject! as RenderParagraph)
          .where(
            (RenderParagraph paragraph) => AppTab.values.any(
              (AppTab tab) => paragraph.text.toPlainText() == tab.label,
            ),
          );

      expect(labels, hasLength(AppTab.values.length));
      for (final RenderParagraph label in labels) {
        expect(label.text.style?.fontSize, 12);
        expect(label.size.height, lessThanOrEqualTo(28));
      }
    });
  }

  testWidgets('the subjects tab uses the short nav label', (
    WidgetTester tester,
  ) async {
    expect(AppTab.subjects.label, 'study_subjects');
  });
}
