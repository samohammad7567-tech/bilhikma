import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bilhikma/core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/app_screen_util.dart';
import 'package:bilhikma/core/widgets/app_section_scaffold.dart';
import 'package:bilhikma/features/gallery/data/models/gallery_image_model.dart';
import 'package:bilhikma/features/gallery/presentation/widgets/gallery_grid.dart';

void main() {
  final List<GalleryImageModel> images = List<GalleryImageModel>.generate(
    6,
    (int index) => GalleryImageModel(id: '$index'),
  );

  Future<void> pumpAt(WidgetTester tester, Size size, Widget child) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: AppScreenUtil.designSize,
        splitScreenMode: AppScreenUtil.splitScreenMode,
        minTextAdapt: AppScreenUtil.minTextAdapt,
        builder: (_, _) => MaterialApp(theme: AppTheme.light(), home: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  int galleryColumns(WidgetTester tester) {
    final GridView grid = tester.widget<GridView>(find.byType(GridView));
    final SliverGridDelegateWithFixedCrossAxisCount delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    return delegate.crossAxisCount;
  }

  testWidgets('gallery uses 2 columns on phones', (WidgetTester tester) async {
    await pumpAt(
      tester,
      const Size(390, 844),
      Scaffold(body: GalleryGrid(images: images)),
    );

    expect(tester.takeException(), isNull);
    expect(galleryColumns(tester), 2);
  });

  testWidgets('gallery uses 3 columns on iPad portrait', (
    WidgetTester tester,
  ) async {
    await pumpAt(
      tester,
      const Size(820, 1180),
      Scaffold(body: GalleryGrid(images: images)),
    );

    expect(tester.takeException(), isNull);
    expect(galleryColumns(tester), 3);
  });

  testWidgets('gallery uses 4 columns on iPad landscape', (
    WidgetTester tester,
  ) async {
    await pumpAt(
      tester,
      const Size(1180, 820),
      Scaffold(body: GalleryGrid(images: images)),
    );

    expect(tester.takeException(), isNull);
    expect(galleryColumns(tester), 4);
  });

  testWidgets('section screens cap content width on iPad landscape', (
    WidgetTester tester,
  ) async {
    await pumpAt(
      tester,
      const Size(1180, 820),
      const AppSectionScaffold(
        title: 'title',
        showBack: false,
        showMenu: false,
        child: SizedBox.expand(),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byType(Column)).width, 900);
  });

  testWidgets('section screens keep full width on iPad portrait', (
    WidgetTester tester,
  ) async {
    await pumpAt(
      tester,
      const Size(820, 1180),
      const AppSectionScaffold(
        title: 'title',
        showBack: false,
        showMenu: false,
        child: SizedBox.expand(),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byType(Column)).width, 820);
  });

  testWidgets('media screens opt out of the content width cap', (
    WidgetTester tester,
  ) async {
    await pumpAt(
      tester,
      const Size(1180, 820),
      const AppSectionScaffold(
        title: 'title',
        showBack: false,
        showMenu: false,
        maxContentWidth: double.infinity,
        child: SizedBox.expand(),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byType(Column)).width, 1180);
  });
}
