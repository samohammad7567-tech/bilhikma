# Crash report — old / low-end Android devices

**Scope of this document:** why the app crashes when a video is opened, and why on some
devices it dies during (or before) the splash screen and never reaches the UI.

**Environment analysed**
- Flutter 3.47.4 · Dart 3.13.3 · engine `0e228ec8c8`
- `minSdk = 24` (Android 7.0), `targetSdk = 36`, `compileSdk = 36` — resolved from the `flutter.*` defaults in `android/app/build.gradle.kts`
- `flutter analyze` → **4 issues, 0 errors** (1 experimental-API warning, 2 unused imports, 1 `print`). None of these crashes are visible to the analyzer; they are all runtime, native, or Gradle/manifest configuration faults.

> ⚠️ Every item below is traced to code in this repository. Items marked **CONFIRMED IN CODE**
> are definite defects in the source. Items marked **PROBABLE** are the matching known
> platform failure for the reported symptom; each needs one logcat capture to be pinned to an
> exact stack trace (see §6).

---

## 1. Why the app never opens on some devices

### 1.1 Wrong-ABI APK installed — the app dies before any Flutter code runs
**Severity: blocker · CONFIRMED (already documented in `issue_install_relese.md`)**

`build/app/outputs/flutter-apk/` has previously contained **only split-per-ABI APKs**
(`app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, `app-x86_64-release.apk`) with no
universal APK. The repo already carries a write-up of a Redmi A7 Pro rejecting the wrong split.

Old phones are very often **32-bit (`armeabi-v7a`)**. Two distinct failures follow:

| What was handed to the phone | Symptom on an old phone |
|---|---|
| `app-arm64-v8a-release.apk` on a 32-bit device | Install refused: `INSTALL_FAILED_NO_MATCHING_ABIS` → "لم يتم تثبيت التطبيق لأن الحزمة تبدو غير صالحة" |
| An APK that installs but carries no `.so` the device can load | Process dies **before the Flutter splash**, with no Dart frames in the log |

Expected log lines:

```
java.lang.UnsatisfiedLinkError: dlopen failed: library "libflutter.so" not found
E/AndroidRuntime: FATAL EXCEPTION: main
    Process: tech.bilhikma.app
    java.lang.RuntimeException: Unable to instantiate application io.flutter.app.FlutterApplication
```

This matches "**some of them are not able to load the app and it crashes from the splash, and the
splash does not open at all**" exactly — the native splash never paints because the process is
killed at `Application` creation.

**Fix:** ship a universal APK (`flutter build apk --release` with **no** `--split-per-abi`) or an
AAB through Play, then verify:

```bash
unzip -l app-release.apk | grep "lib/"     # must contain armeabi-v7a AND arm64-v8a
adb shell getprop ro.product.cpu.abilist   # on the failing phone
```

---

### 1.2 `main()` has no error guard — one plugin failure means `runApp` is never reached
**Severity: blocker · CONFIRMED IN CODE**

`lib/main.dart:15-37`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();

  await CacheUtil.init();                             // :19
  await EasyLocalization.ensureInitialized();          // :20
  await DeviceService.ensureInitialized();             // :21  ← unguarded, see 1.3
  await setupServiceLocator();                         // :22
  await PushNotificationService.ensureInitialized();   // :23  ← unguarded, see 1.4
  ...
  await ScreenCapturePolicy.restore();                 // :28
  runApp(...);                                         // :29
}
```

Nine `await`s run **before** `runApp`. There is:

- no `try/catch` around any of them,
- no `runZonedGuarded`,
- no `FlutterError.onError`,
- no `PlatformDispatcher.instance.onError`,
- no `ErrorWidget.builder`.

Verified: `grep -rn "FlutterError.onError|PlatformDispatcher.instance.onError|runZonedGuarded|ErrorWidget.builder" lib/`
→ **no matches anywhere in the project.**

Consequence: any single plugin throwing on an old device means `runApp` is never called. The user
sees the native splash bitmap frozen, then the OS kills the process. No Flutter UI exists yet, so
nothing is caught and nothing is reported. **This is the structural reason a startup failure looks
like "crash from the splash".**

**Fix:** wrap each pre-`runApp` step so a failure degrades instead of killing startup, and install
global handlers:

```dart
void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (d) => FlutterError.presentError(d);
    PlatformDispatcher.instance.onError = (e, s) { debugPrint('$e\n$s'); return true; };

    await _safe('cache',  CacheUtil.init);
    await _safe('l10n',   EasyLocalization.ensureInitialized);
    await _safe('device', DeviceService.ensureInitialized);
    await _safe('di',     setupServiceLocator);
    runApp(...);                                                          // UI first
    unawaited(_safe('push', PushNotificationService.ensureInitialized));  // then push
  }, (e, s) => debugPrint('fatal: $e\n$s'));
}

Future<void> _safe(String tag, Future<void> Function() step) async {
  try { await step(); } catch (e, s) { debugPrint('startup step "$tag" failed: $e\n$s'); }
}
```

---

### 1.3 `flutter_secure_storage` read/write at startup is unguarded — a keystore failure is fatal
**Severity: blocker · CONFIRMED IN CODE**

`lib/core/services/device_service.dart:66-72`

```dart
static Future<String> _readOrCreate() async {
  final String? existing = await _storage.read(key: _key);   // :67  no try/catch
  if (existing != null && existing.isNotEmpty) return existing;

  final String id = const Uuid().v4();
  await _storage.write(key: _key, value: id);                // :71  no try/catch
  return id;
}
```

and it is constructed with **no `AndroidOptions`** (`device_service.dart:12`):

```dart
static const FlutterSecureStorage _storage = FlutterSecureStorage();
```

`flutter_secure_storage 10.3.1` keeps its master key in the Android Keystore. On old and
OEM-patched Android (7–9, and Huawei / Xiaomi / Samsung keystore implementations) this throws
regularly after an OS update, a backup restore, or a keystore reset:

```
PlatformException(Exception encountered, read,
  javax.crypto.BadPaddingException: pad block corrupted, null)

PlatformException(Exception encountered, read,
  java.security.UnrecoverableKeyException: Failed to obtain information about key)

java.security.KeyStoreException: the master key android_... exists but is unusable
android.security.KeyStoreException: Key user not authenticated
```

Because this is awaited at `main.dart:21` with no guard, the throw propagates out of `main` →
`runApp` is never reached → **frozen splash, then process death**.

Note the inconsistency: `lib/core/services/device_session_service.dart:52-57` **does** wrap its
secure-storage reads in `try/catch`. The one that runs during startup does not.

**Fix:**

```dart
static const FlutterSecureStorage _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(resetOnError: true),   // self-heal a broken keystore
);

static Future<String> _readOrCreate() async {
  try {
    final existing = await _storage.read(key: _key);
    if (existing != null && existing.isNotEmpty) return existing;
  } catch (e) {
    debugPrint('secure storage unreadable: $e');
    try { await _storage.delete(key: _key); } catch (_) {}
  }
  final id = const Uuid().v4();
  try {
    await _storage.write(key: _key, value: id);
  } catch (e) {
    debugPrint('secure storage unwritable, using in-memory id: $e');
  }
  return id;                                       // never throw out of startup
}
```

Also mirror the id into `SharedPreferences`, so a keystore wipe does not silently re-bind the
device session.

---

### 1.4 The FCM token fetch blocks startup and is only half-guarded
**Severity: blocker · CONFIRMED IN CODE**

`lib/core/services/push_notification_service.dart:33-70`

`Firebase.initializeApp()` **is** wrapped (`:34-39`). Everything after it is **not**:

```dart
await _localNotifications.initialize(...);                              // :40
final settings = await FirebaseMessaging.instance.requestPermission();  // :53
_token = await FirebaseMessaging.instance.getToken();                   // :58  ← network, unguarded
await _handleLaunchTap();                                               // :69
await registerToken();                                                  // :70  network
```

`getToken()` talks to Google Play services and then to Google's servers. On old phones this is the
classic failure point:

```
java.io.IOException: SERVICE_NOT_AVAILABLE
java.io.IOException: MISSING_INSTANCEID_SERVICE
java.io.IOException: AUTHENTICATION_FAILED
PlatformException(firebase_messaging, Failed to get FCM token, ...)
FirebaseInstallationsException: Firebase Installations Service is unavailable
```

Causes on an old device: outdated or missing **Google Play services**, Play services disabled by
the user, a de-Googled ROM, or simply a skewed system clock. `firebase_core 4.13.0` /
`firebase_messaging 16.5.0` require a reasonably current Play services.

Two separate symptoms result, and both are being reported:

1. **Crash** — an unguarded throw at `main.dart:23` → `runApp` never runs → frozen splash.
2. **"Doesn't open"** — `getToken()` and `registerToken()` *hang*. There is no timeout anywhere
   (see 1.6), so on 2G/3G or with a flaky DNS the splash sits for 30–60 s until Android's ANR
   killer takes the process. On an old phone that reads as "the app doesn't open".

**Fix:** push is not needed to render the first screen. Move it off the startup path entirely:

```dart
// in main(), after runApp:
unawaited(PushNotificationService.ensureInitialized());
```

and inside, guard and bound it:

```dart
try {
  _token = await FirebaseMessaging.instance
      .getToken()
      .timeout(const Duration(seconds: 10));
} catch (e) {
  debugPrint('FCM token unavailable: $e');     // app continues without push
}
```

---

### 1.5 The splash holds for a fixed 4.5 s on top of a network call
**Severity: medium · CONFIRMED IN CODE**

`lib/features/splash/presentation/cubit/splash_cubit.dart:10-24`

```dart
static const Duration splashDuration = Duration(milliseconds: 4500);   // :10
...
final status = await _resolveSession();                                // :14  secure storage + prefs
await Future.wait([
  ScreenCapturePolicy.refresh(),       // :18  HTTP GET /user/profile, no timeout
  Future.delayed(splashDuration),      // :18
]);
```

`_resolveSession()` runs **before** the `Future.wait`, so its cost is **added** to the 4.5 s rather
than overlapped. The real splash time on an old phone is
`secure-storage read + profile HTTP + 4500 ms`. With no HTTP timeout (1.6),
`ScreenCapturePolicy.refresh()` can hold the splash indefinitely — `refresh()` catches its own
errors (`screen_capture_policy.dart:57-62`) but cannot catch a hang.

Users on slow devices cannot distinguish a 40-second splash from a crash.

**Fix:** drop the artificial delay to ≤1500 ms, move `_resolveSession()` inside the `Future.wait`,
and give `refresh()` a hard `.timeout(...)`.

---

### 1.6 `Dio` has no timeouts at all — any request can hang forever
**Severity: high · CONFIRMED IN CODE**

`lib/core/services/dio_service.dart:17-26` — `BaseOptions` sets only `baseUrl` and `headers`.
There is no `connectTimeout`, `receiveTimeout`, or `sendTimeout`. Dio's default for all three is
`null`, which means **wait forever**.

On good Wi-Fi this is invisible. On an old phone on 3G, behind a captive portal, or with a stale
DNS cache, every blocking call (splash profile fetch, playback-URL fetch, FCM registration) hangs
until the OS intervenes. This is the mechanism behind most "the app opens and then just sits there
and dies" reports that are not hard crashes.

**Fix:**

```dart
BaseOptions(
  baseUrl: ApiEndpoints.baseUrl,
  connectTimeout: const Duration(seconds: 15),
  receiveTimeout: const Duration(seconds: 30),
  sendTimeout:    const Duration(seconds: 30),
  headers: {...},
)
```

---

### 1.7 `google_fonts` downloads the splash typeface over the network at first launch
**Severity: medium · CONFIRMED IN CODE**

- `lib/core/themes/app_theme.dart:131` → `GoogleFonts.cairo(...)`
- `lib/core/themes/app_theme.dart:151` → `GoogleFonts.arefRuqaa(...)`, used by `splashTitle`, which
  the splash screen renders (`splash_brand_texts.dart:40-45`)

`google_fonts 8.2.1` has `allowRuntimeFetching = true` by default, and **no font files are bundled**
— `pubspec.yaml` declares no `fonts:` section. So on every first install the app fetches
`fonts.gstatic.com` while the splash is on screen and writes the `.ttf` into the app support
directory. On an old phone with a slow link the splash renders with fallback glyphs, re-layouts
mid-animation, and on a metered or blocked network logs:

```
Error: google_fonts was unable to load font ArefRuqaa-Regular because the following exception occurred:
SocketException: Failed host lookup: 'fonts.gstatic.com'
```

Not fatal by itself, but it adds network latency and file I/O at the exact moment the app is
already slowest, and it breaks offline correctness.

**Fix:** bundle Cairo and Aref Ruqaa as assets, declare them under `flutter: fonts:`, and set
`GoogleFonts.config.allowRuntimeFetching = false`.

---

## 2. Why opening a video crashes

### 2.1 YouTube videos render in an Android `WebView` — renderer death kills the process
**Severity: blocker · PROBABLE (one logcat line confirms it)**

Dependency chain, verified in `pubspec.lock`:

```
youtube_player_flutter 9.1.3  →  flutter_inappwebview 6.1.5  →  flutter_inappwebview_android 1.1.3
                                                                  (minSdkVersion 19, compileSdk 34,
                                                                   androidx.webkit 1.12.0)
```

`lib/core/services/videoplayerservice/youtube_video_playback.dart:9-18` builds a
`YoutubePlayerController`, and `:89-95` renders a `YoutubePlayer` — which is an embedded `WebView`
running the YouTube **IFrame Player API**.

On old phones the bundled **Android System WebView / Chrome** is often years out of date and, on
Android 7–8 devices that no longer receive updates, cannot be upgraded. Two failure modes:

```
# a) renderer process killed — takes the whole app with it by default
E/chromium: [FATAL:memory.cc] Out of memory
I/WebViewFactory: Loading com.google.android.webview
E/AndroidRuntime: FATAL EXCEPTION: main
    java.lang.RuntimeException: Render process gone for a non-crashed WebView

# b) the IFrame API's modern JS is unsupported → the player never becomes ready
I/chromium: Uncaught TypeError: ... is not a function (YT iframe_api)
```

Mode (a) is a genuine process kill: unless `WebViewClient.onRenderProcessGone` returns `true`, the
Android framework terminates the app. Nothing in this project configures that.

Memory pressure is guaranteed here, because the WebView sits on top of everything else the app
already holds resident: Firebase, Syncfusion PDF, ExoPlayer, `just_audio`, `cached_network_image`.

**Fix (pick one):**

1. **Preferred:** stop using the YouTube IFrame WebView for lesson content — serve the same media
   as a direct HLS/MP4 URL and let `NetworkVideoPlayback` (ExoPlayer) play it. The project already
   has that path, and it is far cheaper on old hardware.
2. If YouTube must stay: open it out-of-process (`url_launcher` → the YouTube app, or a Chrome
   Custom Tab) on devices below a WebView-version threshold, detected via
   `WebViewCompat.getCurrentWebViewPackage()`.
3. At minimum, handle renderer death so it does not kill the app, and gate the YouTube path behind
   a device check (`Build.VERSION.SDK_INT` plus `ActivityManager.MemoryInfo`).

---

### 2.2 The same `GlobalKey` re-parents a live platform view between two widget trees
**Severity: high · CONFIRMED IN CODE**

Two separate places do this.

**(a) Lesson screen fullscreen toggle.**
`lib/features/lesson_detail/presentation/screens/lesson_detail_screen.dart:26` creates
`final GlobalKey _videoStageKey = GlobalKey();` and passes it into `LessonDetailBody`.
`lib/features/lesson_detail/presentation/refactor/lesson_detail_body.dart` then mounts
`LessonVideoStage` with that key in **two structurally different trees**:

- `:59-61` fullscreen → returned directly as the `Scaffold` body
- `:162-163` normal → one child of a `ListView`

**(b) Floating / PiP overlay.**
`lib/core/services/videoplayerservice/floating_video_controller.dart:40` creates
`_playerKey = GlobalKey()`, and that single key is handed to **both**
`widgets/expanded_video_player.dart:30` and `widgets/video_pip_player.dart:139`.

A `GlobalKey` move preserves the Dart `State` — which is the intent (keep playing across the
transition). But it forces Flutter to **detach and re-attach the underlying Android platform
view/surface within a single frame**. On old GPUs and old WebView builds, that re-attach is where
the surface is lost:

```
E/SurfaceTexture: [SurfaceTexture-0-1234-0] attachToContext: invalid current EGLDisplay
E/flutter: Failed to find AndroidView with id: 1
D/SurfaceView: onWindowVisibilityChanged ... surface destroyed
E/AndroidRuntime: java.lang.IllegalStateException: Trying to use a recycled SurfaceTexture
```

If the two trees are ever built in the same frame — which `_videoStageKey` risks, because the
fullscreen branch at `lesson_detail_body.dart:59` and the `ListView` branch at `:64` are selected
by `state.isVideoFullscreen` while `LessonDetailScreen`'s outer `BlocBuilder` rebuilds on the same
flag — Flutter throws outright:

```
Multiple widgets used the same GlobalKey.
The key [GlobalKey#a1b2c] was used by multiple widgets.
```

**Fix:** do not re-parent the platform view. Keep one stable host widget mounted for the whole
lesson and change only its *layout* (a size change, or a single `Stack` whose child is
repositioned), rather than moving the subtree between a `ListView` and a `Scaffold` body. If the
surface genuinely must be rebuilt, tear the controller down and re-create it deliberately instead
of relying on key re-parenting.

---

### 2.3 Picture-in-Picture is requested, but the manifest never declares support
**Severity: high · CONFIRMED IN CODE**

`lib/core/services/videoplayerservice/floating_video_controller.dart:46-51`, run on **every**
`open()`:

```dart
if (enablePictureInPicture) {                    // default true, video_player_options.dart:23
  unawaited(
    _floating.enable(const OnLeavePiP())
        .catchError((_) => PiPStatus.unavailable),
  );
}
```

`android/app/src/main/AndroidManifest.xml` declares **no** `android:supportsPictureInPicture` and
**no** `android:resizeableActivity` on `.MainActivity`. And `floating 6.0.0`'s own library manifest
is empty:

```xml
<!-- ~/.pub-cache/hosted/pub.dev/floating-6.0.0/android/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
  package="eu.wroblewscy.marcin.floating.floating">
</manifest>
```

so nothing is merged in for you. Calling `enterPictureInPictureMode()` on an activity that does not
declare support raises, on the **Android main thread**:

```
java.lang.IllegalStateException: Current activity does not support picture-in-picture.
    at android.app.Activity.enterPictureInPictureMode(Activity.java:2812)
```

A throw on the platform side is not reliably marshalled back into the `.catchError` on the Dart
future — a native `IllegalStateException` on the UI thread is a process-level crash. This fires
**at the moment a video is opened**, which matches the reported symptom precisely.

PiP also only exists from **API 26 (Android 8.0)**. With `minSdk 24`, Android 7.0/7.1 devices —
exactly the "old phones" — have no PiP at all.

**Fix:**

```xml
<activity
    android:name=".MainActivity"
    android:supportsPictureInPicture="true"
    android:resizeableActivity="true"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    ... >
```

and gate the call in Dart, so it is never attempted where it cannot work:

```dart
final bool pipSupported = await _floating.isPipAvailable;   // false on API < 26
if (enablePictureInPicture && pipSupported) {
  try { await _floating.enable(const OnLeavePiP()); }
  catch (e) { debugPrint('PiP unavailable: $e'); }
}
```

---

### 2.4 ExoPlayer / media3 1.9.2 decoder limits on old SoCs
**Severity: high · PROBABLE**

`video_player 2.14.0` → `video_player_android 2.12.0`, which pulls
`androidx.media3:media3-exoplayer:1.9.2` (plus `-hls`, `-dash`, `-rtsp`, `-smoothstreaming`), with
`minSdk = 24`.

`lib/core/services/videoplayerservice/network_video_playback.dart:47-66` initialises and plays:

```dart
final controller =
    vp.VideoPlayerController.networkUrl(uri, httpHeaders: item.httpHeaders);
_controller = controller;
controller.addListener(_onValueChanged);
try {
  await controller.initialize();
  if (_isDisposed) return;
  await controller.play();
} catch (error) {
  _errorMessage = '$error';          // Dart-side errors are handled
}
```

The Dart `try/catch` is correct, but it cannot catch a **native decoder abort**. A 2016-era SoC
cannot decode 1080p/60 or H.265/HEVC, and its `MediaCodec` instance count is tiny:

```
E/ExoPlayerImplInternal: Playback error
  androidx.media3.exoplayer.ExoPlaybackException: MediaCodecVideoRenderer error, index=0,
    format=Format(..., h265, 1920x1080), format_supported=NO
  Caused by: androidx.media3.exoplayer.mediacodec.MediaCodecRenderer$DecoderInitializationException:
    Decoder init failed: OMX.qcom.video.decoder.hevc
  Caused by: android.media.MediaCodec$CodecException: Failed to allocate component instance
    android.media.MediaCodec$CodecException: Error 0xffffec77    # ERROR_INSUFFICIENT_RESOURCE
  androidx.media3.exoplayer.mediacodec.MediaCodecUtil$DecoderQueryException
```

Related, and visible in this code: **`aspectRatio` is read before init completes.**
`network_video_playback.dart:41` returns `16 / 9` while uninitialised, but `:94-97` reads
`controller.value.aspectRatio` directly. If a malformed stream reports a zero height, that is
`NaN`/`0` into `AspectRatio`, which throws `BoxConstraints has NaN values`.

**Fix:**

- Serve an **HLS ladder with a low rung** (360p/480p, H.264 **baseline/main**, AAC) and let
  ExoPlayer adapt down. Do not ship a single high-bitrate H.265 MP4.
- Surface the `ExoPlaybackException` to the user through `VideoPlaybackError` instead of a black
  frame — `errorMessage` (`:55`) already carries it; make sure the UI shows it.
- Clamp the aspect ratio:
  ```dart
  double get aspectRatio {
    final r = isReady ? _value.aspectRatio : 16 / 9;
    return (r.isFinite && r > 0) ? r : 16 / 9;
  }
  ```

---

### 2.5 Playback speed above 1.0 on old decoders
**Severity: medium · PROBABLE**

Recent commits (`554ecd1`, `4c54436`) raised first-watch speed to 1.25× / 1.5×
(`lib/core/enums/playback_speed_enum.dart:9-10`, `maxOnFirstWatch = 1.5` at `:23`), and the sheet
also offers **2×** (`video_player_options.dart:19-26`). The rate is applied in
`lesson_video_stage.dart:143`, and again on first-ready at `:148-152`.

A device that can only just decode a stream at 1× has no headroom at 1.5×/2×: the decoder misses
its deadlines, and ExoPlayer's `Sonic` audio-speed path plus accelerated video dropping either
stalls or aborts with the `CodecException` of 2.4. This explains why the crash may have appeared
*after* those two commits.

**Fix:** cap the offered speed on low-end devices (use `DeviceInfoService.osVersion` together with
`ActivityManager.isLowRamDevice` / total RAM), and drop back to 1× on the first
`ExoPlaybackException` rather than retrying at speed.

---

### 2.6 `SizedBox(height: double.infinity)` in the fullscreen path
**Severity: medium · CONFIRMED IN CODE**

`lib/features/lesson_detail/presentation/widgets/lesson_video_stage.dart:188-196`

```dart
final double height = widget.isFullscreen
    ? double.infinity                                   // :190
    : MediaQuery.sizeOf(context).width / (16 / 10);

return SizedBox(
  height: height,
  width: double.infinity,                               // :195
  ...
```

In the fullscreen tree the parent is a `Scaffold` body, so `double.infinity` resolves fine. But the
non-fullscreen tree puts this widget **inside a `ListView`** (`lesson_detail_body.dart:64-66`),
whose vertical constraint is unbounded. Any frame where `isFullscreen` is `true` while the widget
is still in the `ListView` subtree — the single transition frame, or a `GlobalKey` re-parent that
lands one build late (see 2.2) — throws:

```
Another exception was thrown: BoxConstraints forces an infinite height.
The following assertion was thrown during performLayout():
RenderBox was not laid out: RenderConstrainedBox#... NEEDS-LAYOUT
```

In release that is a silently broken frame; combined with a platform view being re-attached in the
same frame, it is a plausible hard crash.

**Fix:** never use `double.infinity` for the height. Use the real viewport:

```dart
final double height = widget.isFullscreen
    ? MediaQuery.sizeOf(context).height
    : MediaQuery.sizeOf(context).width / (16 / 10);
```

---

## 3. Android manifest / Gradle gaps that bite only old or low-RAM devices

### 3.1 `audio_service` has no manifest entries — and the plugin does not supply them
**Severity: blocker for audio · CONFIRMED IN CODE**

`audio_service 0.18.19`'s own library manifest is **empty**:

```xml
<!-- ~/.pub-cache/hosted/pub.dev/audio_service-0.18.19/android/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
</manifest>
```

So nothing is merged in, and the app manifest must declare the service, the media-button receiver,
and the permissions itself. `android/app/src/main/AndroidManifest.xml` declares **none** of them —
it contains no `<service>` and no `<receiver>` at all.

`lib/core/services/audioplayerservice/audio_player_service.dart:23-27` calls
`JustAudioBackground.init(...)`, which starts `com.ryanheise.audioservice.AudioService`:

```
android.content.ActivityNotFoundException: Unable to find explicit activity class
  {tech.bilhikma.app/com.ryanheise.audioservice.AudioService}; have you declared this activity
  in your AndroidManifest.xml?

java.lang.IllegalStateException: Not allowed to start service Intent ... app is in background

# Android 14+ (targetSdk 36):
java.lang.SecurityException: Starting FGS with type mediaPlayback ... requires permissions:
  android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK
```

Separately, `MainActivity` extends plain `FlutterActivity`
(`android/app/src/main/kotlin/tech/bilhikma/app/MainActivity.kt:18`). Both `audio_service` and
`just_audio_background` require it to extend **`AudioServiceActivity`**; without that, the activity
cannot be re-attached from the media notification.

**Fix — add to `<application>`:**

```xml
<service
    android:name="com.ryanheise.audioservice.AudioService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true">
    <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService"/>
    </intent-filter>
</service>

<receiver
    android:name="com.ryanheise.audioservice.MediaButtonReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.MEDIA_BUTTON"/>
    </intent-filter>
</receiver>
```

**and to `<manifest>`:**

```xml
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
```

**and change `MainActivity`:**

```kotlin
import com.ryanheise.audioservice.AudioServiceActivity
class MainActivity : AudioServiceActivity() { ... }
```

---

### 3.2 No `largeHeap`, while the app holds several memory-heavy natives at once
**Severity: high · CONFIRMED IN CODE (config) / PROBABLE (as the crash cause)**

`<application>` sets no `android:largeHeap="true"`. An old phone gives a process a heap limit of
roughly **96–192 MB**. Simultaneously resident on a lesson screen:

| Component | Native cost |
|---|---|
| ExoPlayer / media3 1.9.2 decoder + buffers | tens of MB |
| `flutter_inappwebview` WebView (YouTube path) | 40–80 MB, plus its own renderer process |
| `syncfusion_flutter_pdfviewer 34.2.3` | large, page bitmaps |
| `just_audio` + `audio_service` | moderate |
| `cached_network_image 3.4.1` | ImageCache, 100 MB ceiling by default |

Plus un-downscaled bundled images — `assets/logo_ornament.png` is **427 KB**, and
`splash_medallion_entry.dart:38-42` decodes it full-size at `0.72.sw` **twice** (left and right
medallions, `splash_ornaments_band.dart:35-50`) with **no `cacheWidth`/`cacheHeight`**. Same for
`assets/background_image_logo.png` (107 KB) at `splash_mosque_background.dart:30-35`.

Expected log:

```
E/dalvikvm-heap: Out of memory on a 41943056-byte allocation
java.lang.OutOfMemoryError: Failed to allocate a 41943056 byte allocation with
  16777216 free bytes and 12MB until OOM
I/ActivityManager: Low on memory: ... killing tech.bilhikma.app
```

**Fix:**

```xml
<application android:largeHeap="true" ... >
```

cap the image cache early:

```dart
PaintingBinding.instance.imageCache
  ..maximumSizeBytes = 40 << 20
  ..maximumSize = 60;
```

and give every large `Image.asset` a decode hint:

```dart
Image.asset(AppAssets.assetsLogoOrnament,
    cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
    fit: BoxFit.cover)
```

---

### 3.3 Release builds are signed with the **debug** keystore
**Severity: high (ships broken updates) · CONFIRMED IN CODE**

`android/app/build.gradle.kts`:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

The debug keystore is per-machine and expires. Consequences that look like "the app won't load":

```
INSTALL_FAILED_UPDATE_INCOMPATIBLE: Package tech.bilhikma.app signatures do not match
  previously installed version; ignoring!
INSTALL_PARSE_FAILED_NO_CERTIFICATES
```

A user who already has a build signed from a different machine simply cannot update, and some OEM
installers report this as a corrupt package rather than a signature mismatch.

**Fix:** create a real upload/release keystore, add a git-ignored `android/key.properties`, and a
proper `signingConfigs { create("release") { ... } }`.

---

### 3.4 `targetSdk` floats to whatever the installed SDK ships
**Severity: medium · CONFIRMED IN CODE**

`compileSdk`, `minSdk`, and `targetSdk` are all `flutter.*` (`android/app/build.gradle.kts:11-24`),
currently resolving to **36 / 24 / 36**. Every Flutter upgrade can silently raise `targetSdk` and
bring in a new behaviour change (foreground-service types, notification permission, broadcast
restrictions) with no code change on your side. For a shipping app these must be pinned explicitly.

**Fix:** `minSdk = 24`, `targetSdk = 35`, `compileSdk = 36` as literals, and bump deliberately.

---

### 3.5 No crash reporting
**Severity: high (process) · CONFIRMED IN CODE**

`firebase_core` and `firebase_messaging` are present; `firebase_crashlytics` is **not** in
`pubspec.yaml`. Combined with §1.2 (no `FlutterError.onError`, no `runZonedGuarded`), there is
currently **no way to see any of these crashes from a user's phone**. Every diagnosis has to be
reproduced locally on matching hardware.

**Fix:** add `firebase_crashlytics`, wire it into `FlutterError.onError` and
`PlatformDispatcher.instance.onError`, and enable NDK crash capture for the ExoPlayer/WebView
native aborts:

```yaml
dependencies:
  firebase_crashlytics: ^5.0.0
```

```dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
PlatformDispatcher.instance.onError = (e, s) {
  FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
  return true;
};
```

---

## 4. Secondary findings (not crashes, found while tracing)

| # | Finding | Location |
|---|---|---|
| 4.1 | Raw translation keys instead of `LangKeys` constants — violates the project rule | `splash_brand_texts.dart:36,52`, `lesson_detail_body.dart:78,91,102,133`, `lesson_detail_screen.dart:66-68` |
| 4.2 | Hardcoded English UI strings in the shared video player | `video_player_options.dart:13` (`'Playback speed'`), `:27` (`'Description'`), `:29` (`'LIVE'`), `:31` (`'Retry'`) |
| 4.3 | `print()` in production code | `home_cubit.dart:40` |
| 4.4 | Unused imports | `lesson_detail_body.dart:8,9` |
| 4.5 | `LockCachingAudioSource` is an experimental just_audio API | `audio_player_handler.dart:258` |
| 4.6 | `CacheUtil` swallows every failure via `_prefs?.` — a failed `init()` makes the whole app silently stateless (the user appears logged out) | `cache_util.dart:4-10` |

---

## 5. Priority order

| # | Item | Severity | Effort |
|---|---|---|---|
| 1 | 1.1 Ship a universal APK / AAB, verify ABIs | blocker | minutes |
| 2 | 1.2 Guard `main()` + global error handlers | blocker | small |
| 3 | 1.3 `AndroidOptions(resetOnError: true)` + try/catch on secure storage | blocker | small |
| 4 | 1.4 Move FCM off the startup path, add `.timeout` | blocker | small |
| 5 | 3.1 `audio_service` manifest entries + `AudioServiceActivity` | blocker (audio) | small |
| 6 | 2.3 `supportsPictureInPicture` + gate `floating.enable()` on `isPipAvailable` | high | small |
| 7 | 1.6 Dio timeouts | high | minutes |
| 8 | 3.5 Crashlytics — so the next report is a stack trace, not a guess | high | small |
| 9 | 2.1 Replace the YouTube WebView path with direct HLS/MP4 | blocker (video) | medium |
| 10 | 2.2 Stop re-parenting the platform view via `GlobalKey` | high | medium |
| 11 | 3.2 `largeHeap` + image-cache cap + `cacheWidth` on big assets | high | small |
| 12 | 2.4 / 2.5 Low-bitrate H.264 rung; cap speed on low-end devices | high | medium |
| 13 | 2.6 Replace `double.infinity` with the viewport height | medium | minutes |
| 14 | 3.3 Real release keystore | high | small |
| 15 | 1.5 / 1.7 Shorten the splash; bundle the fonts | medium | small |
| 16 | 3.4 Pin `minSdk` / `targetSdk` / `compileSdk` | medium | minutes |
| 17 | §4 Localization keys, `print`, unused imports | low | small |

---

## 6. How to capture the real stack trace from a failing phone

The items marked **PROBABLE** become certain with one capture. On the old device:

```bash
adb logcat -c
# then launch the app / open a video, and:
adb logcat > crash.txt
```

Then grep for the signature of each hypothesis:

```bash
# 1.1 wrong ABI
grep -E "UnsatisfiedLinkError|NO_MATCHING_ABIS|libflutter.so" crash.txt

# 1.3 keystore
grep -E "BadPaddingException|UnrecoverableKey|KeyStoreException" crash.txt

# 1.4 FCM / Play services
grep -E "SERVICE_NOT_AVAILABLE|MISSING_INSTANCEID|FirebaseInstallations|GooglePlayServices" crash.txt

# 2.1 WebView renderer
grep -E "Render process gone|chromium.*FATAL|WebViewFactory" crash.txt

# 2.3 PiP
grep -E "picture-in-picture|enterPictureInPictureMode" crash.txt

# 2.4 decoder
grep -E "MediaCodec|ExoPlaybackException|DecoderInitializationException|CodecException" crash.txt

# 3.1 audio service
grep -E "ActivityNotFoundException|FOREGROUND_SERVICE|MediaBrowserService" crash.txt

# 3.2 OOM
grep -E "OutOfMemoryError|Out of memory|Low on memory" crash.txt
```

Also worth recording per device, so the pattern becomes visible:

```bash
adb shell getprop ro.build.version.release        # Android version
adb shell getprop ro.product.cpu.abilist          # ABI
adb shell dumpsys package com.google.android.webview | grep versionName   # WebView version
adb shell dumpsys package com.google.android.gms  | grep versionName      # Play services
adb shell getprop ro.config.low_ram               # low-RAM device flag
```
