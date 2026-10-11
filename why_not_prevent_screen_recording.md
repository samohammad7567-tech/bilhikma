# Why screen recording is not prevented

**Question answered:** the app appears to stop screenshots but not screen recording. Why?

**Decision recorded here:** the app **stays on detect-and-report**. Prevention was implemented and
then reverted on request; §5 documents what it would take, and §6 the cost that made it unwanted.
Nothing in the shipped code blocks a capture.

**Short answer:** nothing in this project sets `FLAG_SECURE`, which is the *only* Android mechanism
that prevents a capture. The whole feature is built as **detect-and-report**, not as prevention, and
that is a deliberate decision recorded in the code itself. Detection can make a screenshot *look*
prevented — the server answers with a warning or a suspension, so the user sees a consequence — but
a recording produces no such consequence, because the detector almost never sees a recording in the
first place.

So the accurate statement of the current behaviour is:

| Capture route | Blocked? | Reported? |
|---|---|---|
| Screenshot, Android 14+ | **No** | Yes — `Activity.registerScreenCaptureCallback` |
| Screenshot, Android 7–13 (most of the install base at `minSdk 24`) | **No** | **No** — the API does not exist |
| Screen recording (built-in recorder, most third-party recorders) | **No** | **Rarely** — see §3 |
| Casting / mirroring / HDMI | **No** | Yes — a second display is visible |

---

## 1. What the code does

`android/app/src/main/kotlin/tech/bilhikma/app/MainActivity.kt` states the root cause in its own
header:

```
 * The window is never protected. FLAG_SECURE would block the screenshot, and a
 * blocked screenshot raises no callback and can never be reported — so the app
 * lets every capture happen and reports the ones it is told about.
```

The pipeline built on that decision:

| File | Role |
|---|---|
| `MainActivity.kt` | Android 14 `ScreenCaptureCallback` → screenshot event |
| `ScreenCaptureDetector.kt` | `DisplayManager.DisplayListener` → recording / external-display events, over `EventChannel("bilhikma/screen_capture")` |
| `lib/core/services/screen_capture_service.dart` | de-duplicates, attaches the current screen + content id, `POST`s a security event |
| `lib/features/security/presentation/cubit/security_cubit.dart` | turns the server's answer into `warned` / `suspended` |
| `lib/core/services/screen_capture_policy.dart` | lifts reporting for an account the server marks `can_capture_screen` |

Every path in it ends in a **report**. There is no code path that returns "no" to the OS, because
none of these APIs can.

## 2. Why a reporting design cannot stop a recording

A screenshot is a single instant with a user behind it, so a consequence delivered after the fact
(warning, suspension) functions as a deterrent and reads as prevention.

A recording is a *continuous* capture started once and left running, and the frames keep flowing no
matter what the app does afterwards. Even a correct, instant report cannot un-record the frames
already written to the file. Reporting is a deterrent for screenshots and an audit trail for
recordings; it is not a control for either.

## 3. Why the recorder is usually not even detected

`ScreenCaptureDetector` infers a recording from a **second display appearing**. That inference is
weak, and the file says so:

```
 * Not every recorder is caught. A MediaProjection virtual display created
 * without VIRTUAL_DISPLAY_FLAG_PUBLIC stays invisible to other processes, and
 * nothing short of a privileged app can see it.
```

Concretely:

1. A `MediaProjection` recorder creates its virtual display **private by default**. A private
   virtual display is not returned by `DisplayManager.getDisplays()` to other apps and raises no
   `onDisplayAdded` in this process. The built-in Android recorder and the common Play Store
   recorders all behave this way.
2. `report()` also skips any display in `STATE_OFF` and any display already seen, so a recorder that
   flickers a display on and off is reported at most once per display id.
3. There is **no Android API at all** that tells an ordinary app "my screen is being recorded".
   `MediaProjection` callbacks only reach the app that *owns* the projection — the recorder, not the
   app being recorded. `screen_protector`'s `isRecording()` returns a hardcoded `false` on Android
   (`ScreenProtectorPlugin.kt`), which is exactly this limitation.

So on a typical device the recording raises no event, no report is sent, no warning or suspension
comes back, and nothing visible happens — which is precisely the symptom reported.

## 4. The dependency that could do it is never asked to

`pubspec.yaml` has `screen_protector: ^1.5.3`, and its Android implementation *is* `FLAG_SECURE`:

```kotlin
"protectDataLeakageOn", "preventScreenshotOn" -> activity?.window?.setFlags(FLAG_SECURE, FLAG_SECURE)
```

But `screen_capture_service.dart` only calls `ScreenProtector.addListener(...)` and
`removeListener()` — the **iOS-only listener API**, documented as "do nothing when run on Android".
The one call that would block everything, `preventScreenshotOn()`, is never made. Nothing in
`android/` sets the flag either: the only matches for `FLAG_SECURE` in the project are that
explanatory comment and a *read* of another display's flag.

---

## 5. What it would take to prevent it

One flag covers both halves of the requirement — there is no separate "block recording" API, which
is why the detector could never grow into one.

`WindowManager.LayoutParams.FLAG_SECURE` makes the platform:

- refuse screenshots (the system shows its own "can't take screenshot" message),
- hand a **black frame** to every `MediaProjection` consumer: the built-in recorder, third-party
  recorders, `scrcpy`-style mirrors, Chromecast, an HDMI/USB-C cable,
- blank the window's thumbnail in the Recents switcher,
- refuse to show the content on any non-secure external or virtual display.

It has existed since API 1, so unlike the current screenshot detection it would cover the **entire**
install base from `minSdk 24`, not just Android 14+.

Should it ever be wanted, the shape that was built and reverted was:

| File | Change |
|---|---|
| `android/.../ScreenProtection.kt` | new — owns the flag, exposes `MethodChannel("bilhikma/screen_protection")` with `enable` / `disable` / `isEnabled` |
| `android/.../MainActivity.kt` | sets the flag in `onCreate` **before `super.onCreate`** — the earliest the window exists, so the launch theme, the splash and the first Flutter frames are covered too |
| `lib/core/services/screen_protection_service.dart` | new — Dart entry point |
| `lib/core/services/screen_capture_policy.dart` | `resolve()` applies `isProtected: !canCaptureScreen`, so an exempt account still gets the flag cleared |

Two details that mattered: the native default is *protected*, so a failed network call, an
unreadable cache or a logout all leave the window protected (fail-closed); and the apply call has to
ignore a no-op, because `AppLifecycleService` re-resolves the policy on **every resume** and
toggling `FLAG_SECURE` re-creates the window surface — an unguarded re-apply flickers a playing
video each time.

## 6. Why detect-and-report is kept instead

Prevention and screenshot reporting are **mutually exclusive on Android**, and that is the whole
trade. A refused screenshot raises no `ScreenCaptureCallback`, so with the flag on:

- screenshot security events stop being sent — there is nothing to send, the capture did not happen;
- the warning / suspension ladder in `SecurityCubit` is no longer driven by screenshots, so the
  backend loses the signal it uses to act on an account;
- only **external-display / mirroring** attempts keep reporting, through `DisplayManager`.

Keeping the current method keeps that signal. The accepted consequence is the one in the table at
the top: captures happen, and the app answers for them afterwards.

## 7. What `FLAG_SECURE` would *not* stop either

Worth stating plainly to whoever asks for the feature — it is a platform guarantee against ordinary
apps and the system UI, not a DRM system:

- **A camera pointed at the screen.** Nothing in software addresses this.
- **A rooted device or a modified framework.** A privileged process can read secure layers; the flag
  is enforced by the platform, so a platform the owner controls can ignore it.
- **An emulator, or host-side capture** of a device whose build the capturer controls.
- **Accessibility / automation services** with system privileges on a managed device.
- **A separate overlay window** the app might create. The flag is per-window: it covers
  `MainActivity`'s window and everything Flutter draws in it (the `youtube_player_flutter` WebView
  and the ExoPlayer surface included), but a `SYSTEM_ALERT_WINDOW` overlay would need its own flag.
  Nothing in `lib/features/` builds one today — `FloatingVideoOverlay` and friends are unreferenced,
  see `issues.md`.
- **Audio.** The flag is a video-layer guarantee. A recording of a protected screen is black but
  still carries the lesson audio. Silencing that needs playback to *pause on detection*, and
  detection is the half the OS does not reliably give us (§3).
- **Picture-in-Picture** would deserve a re-check if it were ever switched on: a secure window and
  PiP do not mix well across OEMs. The PiP call is currently dead code.

## 8. iOS, for the branch that follows

This branch has no `ios/` directory, so everything above is Android-only. When iOS lands, the honest
position is that **iOS cannot prevent a screen recording at all** — there is no `FLAG_SECURE`
equivalent. What exists there:

- `preventScreenshotOn()` — blanks the captured image rather than refusing the capture;
- `protectDataLeakageWithBlur()` — blurs the app-switcher snapshot;
- `UIScreen.isCaptured` / `ScreenProtector.addListener` — **detection** of a recording, already
  consumed by `ScreenCaptureService`.

So on iOS the recording requirement can only be met by *reacting*: pause playback and cover the
player while `isCaptured` is true, then report the event. That is a product decision, and it belongs
in the iOS pass rather than here.
