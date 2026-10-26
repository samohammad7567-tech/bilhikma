/// Safe app startup: a four-layer error net, isolated initialization steps with
/// per-step timeouts, and image-cache limits sized to the device.
///
/// Drop-in and self-contained: pure Flutter, no packages and no
/// project-relative imports, so this file can be copied into any app as-is.
/// Logging and crash reporting are injected rather than imported, so the file
/// stays independent of whichever logger or monitoring SDK an app uses. Pairs
/// with the other widgets in this folder.
///
/// The principle is a **degraded start**: an app that opens missing one feature
/// beats an app that never opens. No step here rethrows — it records the
/// failure and carries on.
///
/// ## Minimal setup
///
/// ```dart
/// void main() => Bootstart.run(_startApp);
///
/// Future<void> _startApp() async {
///   // Bootstart.run has already installed the error handlers by this point.
///   Bloc.observer = const AppBlocObserver();
///
///   await Bootstart.runStep('preferences', CacheUtil.init);
///   await Bootstart.runStep('localization', EasyLocalization.ensureInitialized);
///   await Bootstart.runStep('service_locator', setupServiceLocator);
///
///   Bootstart.tuneImageCache(isLowEndDevice: DeviceInfoService.isLowEndDevice);
///
///   runApp(const MyApp());
///
///   // After the first frame, never blocking it.
///   unawaited(Bootstart.runStep(
///     'push_notifications',
///     PushNotificationService.ensureInitialized,
///     timeout: const Duration(seconds: 90),
///   ));
/// }
/// ```
///
/// ## Wiring crash reporting and localization
///
/// Call [Bootstart.configure] before [Bootstart.run]. Everything is optional;
/// what you leave out keeps a sensible default.
///
/// ```dart
/// void main() {
///   Bootstart.configure(
///     BootstartConfig(
///       // Your own logger — defaults to dart:developer.
///       logger: (BootstartLogRecord r) => AppLogger.error(
///         r.message,
///         name: r.source,
///         error: r.error,
///         stackTrace: r.stackTrace,
///       ),
///       // Where errors actually leave the device. Without this, every error
///       // this file catches dies in the user's phone.
///       reporter: (BootstartLogRecord r) => FirebaseCrashlytics.instance
///           .recordError(r.error ?? r.message, r.stackTrace, fatal: r.isFatal),
///       // Shown in release when a widget fails to build. Translate it here —
///       // this file never touches LangKeys itself.
///       brokenWidgetMessage: LangKeys.somethingWentWrong.tr(),
///     ),
///   );
///   Bootstart.run(_startApp);
/// }
/// ```
///
/// ## Reading what failed
///
/// Every failure is named, so the UI can react instead of guessing:
///
/// ```dart
/// if (Bootstart.didStepFail('push_notifications')) {
///   // Hide the notifications toggle rather than letting it lie.
/// }
///
/// debugPrint(Bootstart.startupReport()); // timings + failures, one block
/// ```
///
/// ## The four layers of the error net
///
/// | Layer | Catches | Behaviour |
/// |---|---|---|
/// | `FlutterError.onError` | build, layout, paint | logs; red screen in debug only |
/// | `PlatformDispatcher.onError` | async gaps, platform channels | logs; app keeps running |
/// | `ErrorWidget.builder` | a widget that failed to build | logs; calm placeholder in release |
/// | `runZonedGuarded` → [Bootstart.reportFatal] | anything that escaped the three above | logs as fatal |
///
/// ## Notes
///
/// * **Order is designed in, not left to the caller.** [Bootstart.run]
///   installs the handlers *before* your startup body runs, so an error during
///   the very first initialization step is still caught. Installing them late
///   is the classic bootstrap bug, and this closes it.
/// * **The release placeholder is never a blank hole.** A broken widget is
///   replaced by [BootstartConfig.brokenWidgetMessage] in a quiet,
///   theme-coloured box — and it carries its own [Directionality] and text
///   style, because a widget that fails *above* `MaterialApp` has neither, and
///   a placeholder that throws would loop forever. In tight space it shrinks to
///   an icon, then to nothing, so it can never blow up a `Row` or a list tile.
/// * **The reporter can never break startup.** It is called inside its own
///   guard; if your monitoring SDK throws or hangs, the app still opens.
/// * **Timeouts are policy, not trivia.** [BootstartConfig.stepTimeout] is a
///   deliberate 12s default, and slow steps should say so at the call site
///   (`timeout:`) — tune them per app instead of copying numbers around.
/// * **Synchronous steps get no timeout.** Dart cannot interrupt synchronous
///   code, so a timeout there would be theatre; [Bootstart.runSyncStep] only
///   isolates.
/// * **State is resettable.** [Bootstart.resetForTesting] clears the recorded
///   failures, timings, and handlers — static state otherwise leaks between
///   tests in the same process.
/// * **No hardware dependency.** [Bootstart.tuneImageCache] takes
///   `isLowEndDevice` as an argument, so this file never depends on a
///   particular device-info service.
library;

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// How bad a [BootstartLogRecord] is.
enum BootstartSeverity {
  /// Normal progress — applied cache limits, finished steps.
  info,

  /// Something worth knowing that did not break anything.
  warning,

  /// A startup step failed, or the framework reported an error.
  error,

  /// An error that escaped every handler and reached the startup zone.
  fatal,
}

/// Why a startup step did not finish.
enum BootstartFailureKind {
  /// The step threw. It is broken.
  threw,

  /// The step exceeded its timeout. It may still be working, only too slowly.
  timedOut,
}

/// One line of startup diagnostics, handed to [BootstartConfig.logger] and
/// [BootstartConfig.reporter].
@immutable
class BootstartLogRecord {
  /// Creates a record. Built internally; exposed so logger and reporter
  /// callbacks can be unit-tested directly.
  const BootstartLogRecord({
    required this.message,
    required this.severity,
    this.source = Bootstart.logName,
    this.error,
    this.stackTrace,
    this.step,
  });

  /// Human-readable description of what happened.
  final String message;

  /// How bad it is.
  final BootstartSeverity severity;

  /// Log tag — `'bootstart'` unless overridden, so startup lines can be
  /// filtered on their own in DevTools.
  final String source;

  /// The thrown object, when there was one.
  final Object? error;

  /// Where it was thrown.
  final StackTrace? stackTrace;

  /// Name of the startup step this belongs to, when it belongs to one.
  final String? step;

  /// Whether this should be reported as a fatal crash.
  bool get isFatal => severity == BootstartSeverity.fatal;

  /// Whether a monitoring service should see this at all.
  bool get isProblem =>
      severity == BootstartSeverity.error ||
      severity == BootstartSeverity.fatal;

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('[$source] $message');
    if (error != null) buffer.write(' — $error');
    return buffer.toString();
  }
}

/// Writes a startup line to wherever this app keeps its logs.
typedef BootstartLogger = void Function(BootstartLogRecord record);

/// Sends a startup problem off the device — Crashlytics, Sentry, your own
/// endpoint. Called only for [BootstartLogRecord.isProblem] records, and only
/// when [BootstartConfig.reportInDebug] allows it for the current build.
typedef BootstartReporter = FutureOr<void> Function(BootstartLogRecord record);

/// Builds the widget shown in place of one that failed to build, in release.
typedef BootstartBrokenWidgetBuilder =
    Widget Function(BuildContext context, FlutterErrorDetails details);

/// Everything [Bootstart] lets an app decide. All fields have defaults, so
/// `const BootstartConfig()` is a valid starting point.
@immutable
class BootstartConfig {
  /// Creates a configuration. Pass it to [Bootstart.configure].
  const BootstartConfig({
    this.logger,
    this.reporter,
    this.reportInDebug = false,
    this.stepTimeout = const Duration(seconds: 12),
    this.brokenWidgetMessage,
    this.brokenWidgetBuilder,
    this.hideBrokenWidgetsInRelease = true,
    this.lowEndImageCacheMegabytes = 24,
    this.imageCacheMegabytes = 56,
    this.lowEndImageCacheCount = 40,
    this.imageCacheCount = 120,
    this.logStepTimings = kDebugMode,
  });

  /// Where startup lines go. Defaults to `dart:developer`'s `log`, which shows
  /// up in DevTools under [BootstartLogRecord.source].
  final BootstartLogger? logger;

  /// Where problems leave the device. **Set this.** Without a reporter, every
  /// error caught here is written to a log nobody will ever read: the user is
  /// protected from the crash, but the team never learns the crash happened.
  final BootstartReporter? reporter;

  /// Whether [reporter] also fires in debug and profile builds. Off by default,
  /// so local experiments do not pollute production dashboards.
  final bool reportInDebug;

  /// Default ceiling for one [Bootstart.runStep]. Override per call for steps
  /// that are legitimately slow (device identity, push registration).
  final Duration stepTimeout;

  /// Localized text for the release placeholder — pass it already translated,
  /// e.g. `LangKeys.somethingWentWrong.tr()`. When null, the placeholder shows
  /// only its icon, so no untranslated English reaches a user.
  final String? brokenWidgetMessage;

  /// Full control over the release placeholder. When set, it replaces the
  /// built-in one and [brokenWidgetMessage] is ignored.
  ///
  /// Keep whatever you return defensive: it renders in a tree that has just
  /// failed, possibly without [Directionality], [MediaQuery], or a theme, and
  /// an exception thrown here loops.
  final BootstartBrokenWidgetBuilder? brokenWidgetBuilder;

  /// Whether to replace a failed widget at all in release. Leave it `true` —
  /// `false` keeps Flutter's grey-on-red error box in front of users.
  final bool hideBrokenWidgetsInRelease;

  /// Image-cache size ceiling, in MB, on a low-end device.
  final int lowEndImageCacheMegabytes;

  /// Image-cache size ceiling, in MB, on a normal device.
  final int imageCacheMegabytes;

  /// Image-cache entry ceiling on a low-end device.
  final int lowEndImageCacheCount;

  /// Image-cache entry ceiling on a normal device.
  final int imageCacheCount;

  /// Whether each step logs how long it took. Debug-only by default.
  final bool logStepTimings;
}

/// Safe startup: installs the error net, runs initialization steps in isolation,
/// and keeps a record of what failed.
///
/// All members are static and the constructor is private — this is a namespace,
/// not an object with instances. See the library doc for the full guide.
class Bootstart {
  const Bootstart._();

  /// Log tag for every line this file emits.
  static const String logName = 'bootstart';

  static BootstartConfig _config = const BootstartConfig();
  static bool _handlersInstalled = false;
  static final List<String> _failedSteps = <String>[];
  static final Map<String, BootstartFailureKind> _failureKinds =
      <String, BootstartFailureKind>{};
  static final Map<String, Duration> _stepTimings = <String, Duration>{};

  /// The active configuration.
  static BootstartConfig get config => _config;

  /// Replaces the configuration. Call once, before [run].
  static void configure(BootstartConfig config) => _config = config;

  /// Names of the steps that failed this session, in the order they failed.
  static List<String> get failedSteps =>
      List<String>.unmodifiable(_failedSteps);

  /// How long each step took, successes and failures alike.
  static Map<String, Duration> get stepTimings =>
      Map<String, Duration>.unmodifiable(_stepTimings);

  /// Whether the step called [name] failed.
  ///
  /// Use it to tell the truth in the UI — hide a toggle whose service never
  /// initialized instead of showing a control that silently does nothing.
  static bool didStepFail(String name) => _failedSteps.contains(name);

  /// Whether every step so far succeeded.
  static bool get isHealthy => _failedSteps.isEmpty;

  /// Why [name] failed, or null if it did not.
  static BootstartFailureKind? failureKind(String name) => _failureKinds[name];

  /// Wraps [startup] in a guarded zone **and installs the error handlers before
  /// it runs**, which is the whole point: an error in the first initialization
  /// step is already covered.
  ///
  /// ```dart
  /// void main() => Bootstart.run(_startApp);
  /// ```
  ///
  /// Call [WidgetsFlutterBinding.ensureInitialized] inside [startup] as usual —
  /// it is left to the caller, since some apps need a custom binding.
  static void run(Future<void> Function() startup) {
    runZonedGuarded<Future<void>>(() async {
      installErrorHandlers();
      await startup();
    }, reportFatal);
  }

  /// Installs the three in-framework error handlers. Idempotent — calling it
  /// twice is harmless, so [run] and a manual call cannot conflict.
  ///
  /// Only needed directly when not using [run]; it must then be the first thing
  /// after `ensureInitialized`.
  static void installErrorHandlers() {
    if (_handlersInstalled) return;
    _handlersInstalled = true;

    // Layer 1 — Flutter's own errors: build, layout, paint, overflow.
    FlutterError.onError = (FlutterErrorDetails details) {
      _emit(
        BootstartLogRecord(
          message:
              'Flutter framework error in '
              '${details.library ?? 'unknown library'}',
          severity: BootstartSeverity.error,
          error: details.exception,
          stackTrace: details.stack,
        ),
      );
      // The red screen stays a developer tool, never a user-facing one.
      if (kDebugMode) FlutterError.presentError(details);
    };

    // Layer 2 — everything outside the framework: unawaited futures, platform
    // channels, timers, stream listeners.
    ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _emit(
        BootstartLogRecord(
          message: 'Unhandled error outside the framework',
          severity: BootstartSeverity.error,
          error: error,
          stackTrace: stack,
        ),
      );
      // true = handled; the engine keeps the app alive.
      return true;
    };

    // Layer 3 — a widget that failed to build. Release only: in debug the
    // default error box must stay visible so the bug is not hidden.
    if (kReleaseMode && _config.hideBrokenWidgetsInRelease) {
      ErrorWidget.builder = _buildBrokenWidget;
    }
  }

  /// Layer 4 — the last net, for anything that escaped the other three.
  ///
  /// Pass it straight to `runZonedGuarded` when wiring the zone by hand:
  ///
  /// ```dart
  /// void main() => runZonedGuarded(_startApp, Bootstart.reportFatal);
  /// ```
  static void reportFatal(Object error, StackTrace stackTrace) {
    _emit(
      BootstartLogRecord(
        message: 'Fatal error escaped the startup zone',
        severity: BootstartSeverity.fatal,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  /// Runs one asynchronous startup step in isolation, under a timeout.
  ///
  /// Never throws. Returns whether the step succeeded, so the caller can skip
  /// work that depended on it:
  ///
  /// ```dart
  /// final bool ready = await Bootstart.runStep('preferences', CacheUtil.init);
  /// if (ready) await Bootstart.runStep('migrations', runMigrations);
  /// ```
  static Future<bool> runStep(
    String name,
    Future<void> Function() step, {
    Duration? timeout,
  }) async {
    final Object? sentinel = await runStepValue<Object?>(
      name,
      () async {
        await step();
        return null;
      },
      timeout: timeout,
      fallback: _failureSentinel,
    );
    return sentinel != _failureSentinel;
  }

  /// Like [runStep], for a step that produces a value.
  ///
  /// Returns [fallback] when the step fails, so initialization can continue
  /// with a safe default:
  ///
  /// ```dart
  /// final RemoteConfig cfg = await Bootstart.runStepValue(
  ///   'remote_config',
  ///   RemoteConfigService.fetch,
  ///   fallback: RemoteConfig.defaults,
  /// );
  /// ```
  static Future<T> runStepValue<T>(
    String name,
    Future<T> Function() step, {
    required T fallback,
    Duration? timeout,
  }) async {
    final Duration limit = timeout ?? _config.stepTimeout;
    final Stopwatch watch = Stopwatch()..start();
    try {
      final T value = await step().timeout(limit);
      _recordSuccess(name, watch.elapsed);
      return value;
    } on TimeoutException {
      _recordFailure(
        name,
        BootstartFailureKind.timedOut,
        'timed out after ${limit.inSeconds}s',
        elapsed: watch.elapsed,
      );
      return fallback;
    } catch (error, stackTrace) {
      _recordFailure(
        name,
        BootstartFailureKind.threw,
        'threw',
        error: error,
        stackTrace: stackTrace,
        elapsed: watch.elapsed,
      );
      return fallback;
    }
  }

  /// Runs one synchronous startup step in isolation — attaching listeners,
  /// wiring one service to another.
  ///
  /// No timeout, deliberately: Dart cannot interrupt synchronous code.
  static bool runSyncStep(String name, void Function() step) {
    final Stopwatch watch = Stopwatch()..start();
    try {
      step();
      _recordSuccess(name, watch.elapsed);
      return true;
    } catch (error, stackTrace) {
      _recordFailure(
        name,
        BootstartFailureKind.threw,
        'threw',
        error: error,
        stackTrace: stackTrace,
        elapsed: watch.elapsed,
      );
      return false;
    }
  }

  /// Caps the image cache so a long scroll of photos cannot get the app killed
  /// for memory on a weak device.
  ///
  /// Flutter's defaults — about 100MB and 1000 entries — are generous for a
  /// flagship and fatal for a 2GB phone. Limits come from [config]; pass
  /// `isLowEndDevice` from whatever device-info service the app already has, so
  /// this file stays portable.
  static void tuneImageCache({required bool isLowEndDevice}) {
    final int megabytes = isLowEndDevice
        ? _config.lowEndImageCacheMegabytes
        : _config.imageCacheMegabytes;
    final int count = isLowEndDevice
        ? _config.lowEndImageCacheCount
        : _config.imageCacheCount;

    final ImageCache cache = PaintingBinding.instance.imageCache;
    cache
      ..maximumSizeBytes =
          megabytes <<
          20 // MB → bytes, free at runtime.
      ..maximumSize = count;

    _emit(
      BootstartLogRecord(
        message:
            'Image cache capped at ${cache.maximumSizeBytes >> 20}MB / '
            '${cache.maximumSize} entries (low-end: $isLowEndDevice)',
        severity: BootstartSeverity.info,
      ),
    );
  }

  /// A one-block summary of the startup: what failed, and what took how long.
  ///
  /// Worth logging once after `runApp`, and worth attaching to a bug report.
  static String startupReport() {
    final StringBuffer buffer = StringBuffer('Startup report:');

    if (_failedSteps.isEmpty) {
      buffer.write('\n  all steps succeeded');
    } else {
      for (final String name in _failedSteps) {
        final BootstartFailureKind? kind = _failureKinds[name];
        buffer.write('\n  FAILED $name (${kind?.name ?? 'unknown'})');
      }
    }

    _stepTimings.forEach((String name, Duration took) {
      buffer.write('\n  $name — ${took.inMilliseconds}ms');
    });

    return buffer.toString();
  }

  /// Clears every piece of static state and uninstalls the handlers.
  ///
  /// Static state survives between tests in one process, which turns a failure
  /// recorded by one test into a mystery in the next. Call this in `setUp`.
  @visibleForTesting
  static void resetForTesting() {
    _config = const BootstartConfig();
    _failedSteps.clear();
    _failureKinds.clear();
    _stepTimings.clear();
    _handlersInstalled = false;
    FlutterError.onError = FlutterError.presentError;
    ui.PlatformDispatcher.instance.onError = null;
    ErrorWidget.builder = (FlutterErrorDetails details) =>
        ErrorWidget(details.exception);
  }

  // --- internals -----------------------------------------------------------

  /// Marks a failed value-step without colliding with a legitimate `null`.
  static const Object _failureSentinel = Object();

  static void _recordSuccess(String name, Duration elapsed) {
    _stepTimings[name] = elapsed;
    if (!_config.logStepTimings) return;
    _emit(
      BootstartLogRecord(
        message: 'Startup step "$name" finished in ${elapsed.inMilliseconds}ms',
        severity: BootstartSeverity.info,
        step: name,
      ),
    );
  }

  static void _recordFailure(
    String name,
    BootstartFailureKind kind,
    String what, {
    required Duration elapsed,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _failedSteps.add(name);
    _failureKinds[name] = kind;
    _stepTimings[name] = elapsed;
    _emit(
      BootstartLogRecord(
        message: 'Startup step "$name" $what — starting without it',
        severity: BootstartSeverity.error,
        error: error,
        stackTrace: stackTrace,
        step: name,
      ),
    );
  }

  /// Logs a record, then hands it to the reporter — each inside its own guard,
  /// so neither a noisy logger nor a broken monitoring SDK can stop startup.
  static void _emit(BootstartLogRecord record) {
    try {
      (_config.logger ?? _defaultLogger)(record);
    } catch (_) {
      // A logger that throws must not take the app down with it.
    }

    final BootstartReporter? reporter = _config.reporter;
    if (reporter == null || !record.isProblem) return;
    if (kDebugMode && !_config.reportInDebug) return;

    try {
      final FutureOr<void> result = reporter(record);
      if (result is Future<void>) {
        // Fire-and-forget: reporting must never delay the first frame.
        result.catchError((Object _) {});
      }
    } catch (_) {
      // Same contract for the synchronous path.
    }
  }

  static void _defaultLogger(BootstartLogRecord record) {
    developer.log(
      record.message,
      name: record.source,
      error: record.error,
      stackTrace: record.stackTrace,
      level: switch (record.severity) {
        BootstartSeverity.info => 800,
        BootstartSeverity.warning => 900,
        BootstartSeverity.error => 1000,
        BootstartSeverity.fatal => 1200,
      },
    );
  }

  static Widget _buildBrokenWidget(FlutterErrorDetails details) {
    _emit(
      BootstartLogRecord(
        message: 'Widget build failed',
        severity: BootstartSeverity.error,
        error: details.exception,
        stackTrace: details.stack,
      ),
    );

    final BootstartBrokenWidgetBuilder? custom = _config.brokenWidgetBuilder;
    if (custom != null) {
      return Builder(
        builder: (BuildContext context) => custom(context, details),
      );
    }

    return BootstartBrokenWidget(message: _config.brokenWidgetMessage);
  }
}

/// The calm stand-in shown in release when a widget fails to build.
///
/// Three properties make it safe rather than pretty, and all three matter:
///
/// * It carries its own [Directionality] and [DefaultTextStyle]. A widget that
///   fails above `MaterialApp` has neither ancestor, and [Text] asserts without
///   a text direction — a placeholder that throws would be rebuilt, fail again,
///   and loop.
/// * It never asks for more space than it is given, and shrinks to an icon and
///   then to nothing, so it cannot break a `Row`, a list tile, or a toolbar.
/// * Colours come from the ambient [ColorScheme] when there is one, and fall
///   back to fixed neutral greys when there is not.
///
/// Exposed so an app can reuse it inside its own
/// [BootstartConfig.brokenWidgetBuilder].
class BootstartBrokenWidget extends StatelessWidget {
  /// Creates the placeholder. [message] should already be localized; when it is
  /// null only the icon shows, so no untranslated text reaches a user.
  const BootstartBrokenWidget({
    super.key,
    this.message,
    this.icon = Icons.error_outline_rounded,
  });

  /// Localized one-line explanation, or null for icon only.
  final String? message;

  /// The mark shown above the message.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // Theme.of falls back to ThemeData.fallback with no ancestor, and
    // Directionality.maybeOf tolerates having none — this builds in a tree that
    // has just failed, so nothing here may assert.
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color foreground = scheme.onSurfaceVariant;
    final Color background = scheme.surfaceContainerHighest;
    final TextDirection direction =
        Directionality.maybeOf(context) ?? TextDirection.ltr;

    return Directionality(
      textDirection: direction,
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 12, color: foreground),
        textAlign: TextAlign.center,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Too small for any mark at all — vanish rather than overflow.
            if (constraints.maxWidth < 24 || constraints.maxHeight < 24) {
              return const SizedBox.shrink();
            }

            final String? text = message;
            final bool roomForText =
                text != null &&
                text.isNotEmpty &&
                constraints.maxWidth >= 120 &&
                constraints.maxHeight >= 72;

            return Container(
              padding: EdgeInsets.all(roomForText ? 12 : 4),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: roomForText ? 22 : 18, color: foreground),
                  if (roomForText) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
