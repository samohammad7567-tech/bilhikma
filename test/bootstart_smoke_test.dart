import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bilhikma/core/app/bootstart_custom.dart';

void main() {
  setUp(Bootstart.resetForTesting);
  tearDown(Bootstart.resetForTesting);

  test('successful step reports true and records a timing', () async {
    final bool ok = await Bootstart.runStep('a', () async {});
    expect(ok, isTrue);
    expect(Bootstart.didStepFail('a'), isFalse);
    expect(Bootstart.isHealthy, isTrue);
    expect(Bootstart.stepTimings.containsKey('a'), isTrue);
  });

  test('throwing step is isolated and recorded as threw', () async {
    final bool ok = await Bootstart.runStep('b', () async => throw 'boom');
    expect(ok, isFalse);
    expect(Bootstart.didStepFail('b'), isTrue);
    expect(Bootstart.failureKind('b'), BootstartFailureKind.threw);
  });

  test('hanging step times out instead of blocking forever', () async {
    final bool ok = await Bootstart.runStep(
      'c',
      () => Completer<void>().future,
      timeout: const Duration(milliseconds: 50),
    );
    expect(ok, isFalse);
    expect(Bootstart.failureKind('c'), BootstartFailureKind.timedOut);
  });

  test(
    'a step that legitimately returns null is not read as failure',
    () async {
      final String? value = await Bootstart.runStepValue<String?>(
        'd',
        () async => null,
        fallback: 'fallback',
      );
      expect(value, isNull, reason: 'null is a real result, not a failure');
      expect(Bootstart.isHealthy, isTrue);
    },
  );

  test(
    'runStepValue falls back on failure and keeps the value on success',
    () async {
      final int bad = await Bootstart.runStepValue<int>(
        'e',
        () async => throw StateError('nope'),
        fallback: -1,
      );
      final int good = await Bootstart.runStepValue<int>(
        'f',
        () async => 7,
        fallback: -1,
      );
      expect(bad, -1);
      expect(good, 7);
    },
  );

  test('sync step is isolated', () {
    expect(Bootstart.runSyncStep('g', () => throw 'sync boom'), isFalse);
    expect(Bootstart.runSyncStep('h', () {}), isTrue);
    expect(Bootstart.failedSteps, <String>['g']);
  });

  test(
    'reporter only sees problems, and a throwing reporter is harmless',
    () async {
      final List<String> seen = <String>[];
      Bootstart.configure(
        BootstartConfig(
          logger: (BootstartLogRecord r) {},
          reportInDebug: true,
          reporter: (BootstartLogRecord r) {
            seen.add(r.message);
            throw 'reporter exploded';
          },
        ),
      );

      await Bootstart.runStep('ok', () async {});
      await Bootstart.runStep('bad', () async => throw 'x');

      expect(seen.length, 1, reason: 'only the failure is reported');
      expect(seen.single, contains('bad'));
    },
  );

  test('failedSteps is unmodifiable', () {
    expect(() => Bootstart.failedSteps.add('x'), throwsUnsupportedError);
  });

  test('tuneImageCache applies the configured ceilings', () {
    Bootstart.tuneImageCache(isLowEndDevice: true);
    expect(PaintingBinding.instance.imageCache.maximumSize, 40);
    expect(PaintingBinding.instance.imageCache.maximumSizeBytes, 24 << 20);

    Bootstart.tuneImageCache(isLowEndDevice: false);
    expect(PaintingBinding.instance.imageCache.maximumSize, 120);
    expect(PaintingBinding.instance.imageCache.maximumSizeBytes, 56 << 20);
  });

  testWidgets('placeholder renders with no Directionality or Theme ancestor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const Center(child: BootstartBrokenWidget(message: 'حدث خطأ ما')),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('حدث خطأ ما'), findsOneWidget);
  });

  testWidgets('placeholder shrinks instead of overflowing a tight slot', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: BootstartBrokenWidget(message: 'حدث خطأ ما'),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('a broken widget is replaced, not left to crash the screen', (
    WidgetTester tester,
  ) async {
    // Exercise the release path directly: in debug the default box is kept.
    final ErrorWidgetBuilder original = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) =>
        const BootstartBrokenWidget(message: 'حدث خطأ ما');

    await tester.pumpWidget(
      MaterialApp(home: Builder(builder: (_) => throw 'widget boom')),
    );

    expect(tester.takeException(), 'widget boom');
    expect(find.text('حدث خطأ ما'), findsOneWidget);

    // flutter_test asserts the builder is restored before the body ends.
    ErrorWidget.builder = original;
  });
}
