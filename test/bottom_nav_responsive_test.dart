import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bilhikma/core/enums/app_tab_enum.dart';
import 'package:bilhikma/core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/app_screen_util.dart';
import 'package:bilhikma/core/widgets/app_bottom_nav_bar.dart';
import 'package:bilhikma/core/widgets/bottom_nav_tab_icon.dart';

void main() {
  const Map<String, Size> sizes = <String, Size>{
    'iphone': Size(390, 844),
    'ipad portrait': Size(820, 1180),
    'ipad landscape': Size(1180, 820),
    'ipad split view': Size(507, 744),
  };

  for (final MapEntry<String, Size> entry in sizes.entries) {
    testWidgets('bottom nav stays usable on ${entry.key}', (
      WidgetTester tester,
    ) async {
      final Size screen = entry.value;
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = screen;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: AppScreenUtil.designSize,
          splitScreenMode: AppScreenUtil.splitScreenMode,
          minTextAdapt: AppScreenUtil.minTextAdapt,
          builder: (_, _) => MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              extendBody: true,
              body: const SizedBox.expand(),
              bottomNavigationBar: AppBottomNavBar(
                selectedTab: AppTab.home,
                onTabSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      final Rect bar = tester.getRect(find.byType(AppBottomNavBar));
      expect(bar.top, greaterThanOrEqualTo(0));
      expect(bar.bottom, lessThanOrEqualTo(screen.height + 0.5));
      expect(bar.height, inInclusiveRange(64, 76));

      Rect? floatingSelectedIcon;
      for (final Element element
          in find.byType(BottomNavTabIcon).evaluate().toList()) {
        final BottomNavTabIcon icon = element.widget as BottomNavTabIcon;
        final Rect rect = tester.getRect(
          find.byElementPredicate((Element candidate) => candidate == element),
        );

        if (!icon.isSelected) {
          expect(rect.width, closeTo(BottomNavTabIcon.iconSize, 0.5));
          expect(rect.height, closeTo(BottomNavTabIcon.iconSize, 0.5));
        } else if (rect.top < bar.top) {
          floatingSelectedIcon = rect;
        }
      }

      expect(floatingSelectedIcon, isNotNull);
      expect(
        floatingSelectedIcon!.width,
        closeTo(BottomNavTabIcon.haloDiameter, 0.5),
      );
      expect(
        floatingSelectedIcon.height,
        closeTo(BottomNavTabIcon.haloDiameter, 0.5),
      );
      expect(bar.top - floatingSelectedIcon.top, lessThanOrEqualTo(28));
    });
  }
}
