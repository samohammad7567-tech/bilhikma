import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bilhikma/core/themes/app_theme.dart';
import 'package:bilhikma/core/widgets/loading/app_inline_loader.dart';
import 'package:bilhikma/core/widgets/loading/app_shimmer.dart';
import 'package:bilhikma/core/widgets/loading/app_skeleton_list.dart';
import 'package:bilhikma/core/widgets/loading/skeleton_box.dart';
import 'package:bilhikma/core/widgets/loading/skeletons/media_tabs_skeleton.dart';
import 'package:bilhikma/core/widgets/loading/skeletons/notification_card_skeleton.dart';

Widget _host(Widget child, {ThemeData? theme, TextDirection? direction}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (BuildContext context, Widget? _) => MaterialApp(
      theme: theme ?? AppTheme.light(),
      locale: const Locale('en'),
      home: Directionality(
        textDirection: direction ?? TextDirection.ltr,
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  testWidgets('shimmer masks a bare skeleton block', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const AppShimmer(child: SkeletonBox())));
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byType(ShaderMask), findsOneWidget);
  });

  testWidgets('notification card skeleton lays out in both directions', (
    WidgetTester tester,
  ) async {
    for (final TextDirection direction in TextDirection.values) {
      await tester.pumpWidget(
        _host(const NotificationCardSkeleton(), direction: direction),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull, reason: '$direction');
    }
  });

  testWidgets('skeleton list runs one ticker for many masks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        AppSkeletonList(
          itemCount: 4,
          itemBuilder: (BuildContext context) =>
              const NotificationCardSkeleton(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byType(ShaderMask), findsNWidgets(4));
  });

  testWidgets('reduced motion holds the sweep still', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (BuildContext context, Widget? _) => MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(body: const MediaTabsSkeleton()),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    // A live controller would leave the frame scheduler busy for ever.
    expect(tester.takeException(), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('dark theme still paints opaque skeleton tones', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(const NotificationCardSkeleton(), theme: AppTheme.dark()),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
  });

  testWidgets('inline loader is scoped to its own box', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const Center(child: AppInlineLoader())));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
