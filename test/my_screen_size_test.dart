import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bilhikma/core/utils/my_screen_size.dart';

class _Probe {
  late WindowSize windowSize;
  late bool tablet;
  late bool mobile;
  late bool landscape;
  late bool compactHeight;
  late double widthScale;
  late double heightScale;
  late double textScale;
  late double w100;
  late double h100;
  late double r100;
  late double sp16;
  late double widthFraction;
  late double cappedWidthFraction;
  late double heightFraction;
  late int valueFallback;
  late double contentMaxWidth;
  late int galleryColumns;
  late double bottomChromeHeight;
  late double navRailWidth;
  late double keyboardHeight;
  late bool keyboardOpen;
  late double topPadding;
  late double bottomPadding;
  late double dpr;
}

void main() {
  Future<_Probe> probe(
    WidgetTester tester,
    Size size, {
    FakeViewPadding insets = const FakeViewPadding(),
    FakeViewPadding padding = const FakeViewPadding(),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    tester.view.viewInsets = insets;
    tester.view.padding = padding;
    addTearDown(tester.view.reset);

    final _Probe result = _Probe();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            result.windowSize = MyScreenSize.windowSize(context);
            result.tablet = MyScreenSize.isTablet(context);
            result.mobile = MyScreenSize.isMobile(context);
            result.landscape = MyScreenSize.isLandscape(context);
            result.compactHeight = MyScreenSize.isCompactHeight(context);
            result.widthScale = MyScreenSize.widthScale(context);
            result.heightScale = MyScreenSize.heightScale(context);
            result.w100 = MyScreenSize.w(context, 100);
            result.h100 = MyScreenSize.h(context, 100);
            result.r100 = MyScreenSize.r(context, 100);
            result.sp16 = MyScreenSize.sp(context, 16);
            result.textScale = result.sp16 / 16;
            result.widthFraction = MyScreenSize.widthFraction(context, 0.5);
            result.cappedWidthFraction = MyScreenSize.widthFraction(
              context,
              0.8,
              max: 320,
            );
            result.heightFraction = MyScreenSize.heightFraction(context, 0.85);
            result.valueFallback = MyScreenSize.value<int>(
              context,
              compact: 1,
              medium: 2,
              expanded: 3,
            );
            result.contentMaxWidth = MyScreenSize.contentMaxWidth(context);
            result.galleryColumns = MyScreenSize.galleryColumns(context);
            result.bottomChromeHeight = MyScreenSize.bottomChromeHeight(
              context,
            );
            result.navRailWidth = MyScreenSize.navRailWidth(context);
            result.keyboardHeight = MyScreenSize.keyboardHeight(context);
            result.keyboardOpen = MyScreenSize.isKeyboardOpen(context);
            result.topPadding = MyScreenSize.topPadding(context);
            result.bottomPadding = MyScreenSize.bottomPadding(context);
            result.dpr = MyScreenSize.dpr(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return result;
  }

  testWidgets('design baseline keeps every design value unchanged', (
    WidgetTester tester,
  ) async {
    final _Probe result = await probe(tester, const Size(412, 917));

    expect(result.widthScale, closeTo(1, 0.001));
    expect(result.heightScale, closeTo(1, 0.001));
    expect(result.w100, closeTo(100, 0.001));
    expect(result.h100, closeTo(100, 0.001));
    expect(result.r100, closeTo(100, 0.001));
    expect(result.sp16, closeTo(16, 0.001));
  });

  testWidgets('small phone scaling stays bounded', (WidgetTester tester) async {
    final _Probe result = await probe(tester, const Size(360, 640));

    expect(result.windowSize, WindowSize.compact);
    expect(result.tablet, isFalse);
    expect(result.mobile, isTrue);
    expect(result.landscape, isFalse);
    expect(result.compactHeight, isFalse);
    expect(result.widthScale, closeTo(360 / 412, 0.001));
    expect(result.heightScale, 0.85);
    expect(result.textScale, 0.9);
    expect(result.w100, closeTo(100 * 360 / 412, 0.001));
    expect(result.h100, closeTo(85, 0.001));
    expect(result.r100, closeTo(100 * 360 / 412, 0.001));
    expect(result.sp16, closeTo(14.4, 0.001));
    expect(result.widthFraction, closeTo(180, 0.001));
    expect(result.cappedWidthFraction, closeTo(288, 0.001));
    expect(result.heightFraction, closeTo(544, 0.001));
    expect(result.valueFallback, 1);
    expect(result.contentMaxWidth, double.infinity);
    expect(result.galleryColumns, 2);
    expect(result.bottomChromeHeight, 70);
    expect(result.navRailWidth, 0);
    expect(result.dpr, 1);
  });

  testWidgets('phone landscape still uses compact chrome', (
    WidgetTester tester,
  ) async {
    final _Probe result = await probe(tester, const Size(844, 390));

    expect(result.windowSize, WindowSize.expanded);
    expect(result.tablet, isFalse);
    expect(result.mobile, isTrue);
    expect(result.landscape, isTrue);
    expect(result.compactHeight, isTrue);
    expect(result.widthScale, 1.35);
    expect(result.heightScale, 0.85);
    expect(result.textScale, 0.9);
    expect(result.w100, closeTo(135, 0.001));
    expect(result.valueFallback, 3);
    expect(result.galleryColumns, 4);
    expect(result.bottomChromeHeight, 70);
    expect(result.navRailWidth, 0);
  });

  testWidgets('iPad portrait clamps design scaling to a readable range', (
    WidgetTester tester,
  ) async {
    final _Probe result = await probe(tester, const Size(820, 1180));

    expect(result.windowSize, WindowSize.medium);
    expect(result.tablet, isTrue);
    expect(result.mobile, isFalse);
    expect(result.compactHeight, isFalse);
    expect(result.widthScale, 1.35);
    expect(result.heightScale, 1.25);
    expect(result.w100, closeTo(135, 0.001));
    expect(result.h100, closeTo(125, 0.001));
    expect(result.sp16, closeTo(20, 0.001));
    expect(result.valueFallback, 2);
    expect(result.cappedWidthFraction, 320);
    expect(result.contentMaxWidth, 900);
    expect(result.galleryColumns, 3);
    expect(result.bottomChromeHeight, 0);
    expect(result.navRailWidth, 96);
  });

  testWidgets('iPad landscape uses expanded policies', (
    WidgetTester tester,
  ) async {
    final _Probe result = await probe(tester, const Size(1180, 820));

    expect(result.windowSize, WindowSize.expanded);
    expect(result.tablet, isTrue);
    expect(result.landscape, isTrue);
    expect(result.compactHeight, isFalse);
    expect(result.widthScale, 1.35);
    expect(result.heightScale, closeTo(820 / 917, 0.001));
    expect(result.textScale, 0.9);
    expect(result.sp16, closeTo(14.4, 0.001));
    expect(result.contentMaxWidth, 1040);
    expect(result.galleryColumns, 4);
    expect(result.bottomChromeHeight, 0);
    expect(result.navRailWidth, 96);
  });

  testWidgets('split view uses compact policies', (WidgetTester tester) async {
    final _Probe result = await probe(tester, const Size(507, 744));

    expect(result.windowSize, WindowSize.compact);
    expect(result.tablet, isFalse);
    expect(result.contentMaxWidth, double.infinity);
    expect(result.galleryColumns, 2);
    expect(result.bottomChromeHeight, 70);
    expect(result.navRailWidth, 0);
  });

  testWidgets('keyboard and safe area come from the same source', (
    WidgetTester tester,
  ) async {
    final _Probe result = await probe(
      tester,
      const Size(390, 844),
      insets: const FakeViewPadding(bottom: 320),
      padding: const FakeViewPadding(top: 47, bottom: 34),
    );

    expect(result.keyboardHeight, 320);
    expect(result.keyboardOpen, isTrue);
    expect(result.topPadding, 47);
    expect(result.bottomPadding, 34);
  });
}
