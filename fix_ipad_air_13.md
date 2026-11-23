# iPad Air 11-inch responsive issues — root causes

Target device: iPad Air 11" (820 x 1180 logical points portrait, 1180 x 820 landscape).
This app has no tablet layout system. It is a phone UI (412 x 917) stretched by
`flutter_screenutil`, then clamped into phone-sized columns. That combination is
the root cause of the reported responsive defects.

## 1. Every dimension is scaled from a phone canvas

- `lib/core/utils/app_screen_util.dart:6` — `designSize = Size(412, 917)` for every device.
- `lib/bilhikma_app.dart:33-37` — `ScreenUtilInit` applies this design size app-wide.
- ~258 Dart files use `.w` / `.h` / `.sp` (554 `.w`, 511 `.h`), including all paddings, gaps, icons and buttons.

Resulting scale factors on iPad Air 11":

| Orientation | `.w` factor (820/412 or 1180/412) | `.h` factor (1180/917 or 820/917) |
|---|---|---|
| Portrait | 1.99x | 1.29x |
| Landscape | 2.86x | 0.89x |

`minTextAdapt: true` (`app_screen_util.dart:8`) keeps text near the smaller factor,
so text grows ~1.29x while boxes, paddings and icons grow ~2x. This produces
cramped/ellipsised text, premature overflow, and wildly different results between
portrait and landscape. `.w` and `.h` must not be used as a general layout system.

## 2. Contradictory width caps fight the scaled widgets

- `lib/features/main_shell/presentation/widgets/main_shell_view.dart:12-13,43-52` — anything wider than 600 is forced into a fixed `SizedBox(width: 720)`, full height.
- `lib/core/widgets/app_content_width.dart:4,13-17` — default `maxWidth: 900` for all section screens.
- `lib/features/auth/login/presentation/refactor/login_body.dart:19-22` — login is capped at 560 with `40.w` horizontal padding (~80pt on iPad).

On portrait iPad the content area is 720pt while its children were sized as if the
screen were 820pt wide (~2x phone values). The double constraint plus oversized
children is the most direct cause of squeezed rows and overflow errors.

## 3. Tablet detection exists but drives no layout

- `lib/core/utils/screen_size.dart:8-11` — `isTablet = shortestSide >= 600`.
- `lib/core/utils/orientation/orientation_util.dart:11-22` — tablet and mobile return the identical value (`portraitUp`).
- `lib/features/lesson_detail/presentation/widgets/lesson_video_stage.dart:86,186` — the only UI use of `isMobile`, and both orientations are the same.

There is no `NavigationRail`, no multi-pane layout, no tablet-specific column
counts, and no breakpoint strategy beyond the single 600 check in `main_shell_view.dart`.
`ScreenSize.isTablet` is effectively dead code for layout purposes.

## 4. Portrait-only lock on tablets

- `lib/core/utils/orientation/orientation_util.dart:11-22` — both branches lock to `[DeviceOrientation.portraitUp]`.
- `lib/core/utils/orientation/orientation_lock.dart:18-22` — one-shot `_done` flag set inside `build()`; the decision is never re-evaluated when the window resizes or iPad enters Split View.
- `lib/core/routing/app_router.dart:63-65` — `OrientationLock` wraps the splash route but applies `SystemChrome` globally.

Video fullscreen temporarily forces landscape (`lesson_video_stage.dart:174-181`),
then restores portrait; with the 2.86x width factor in landscape, returning to
portrait leaves inconsistent cached sizing and orientation state.

## 5. Video stages sized from raw screen width

- `lib/features/lesson_detail/presentation/widgets/lesson_video_stage.dart:200-207` — `height = screen.width / 1.6` → ~512pt tall in portrait, ~738pt in landscape (almost the entire 820pt height).
- `lib/features/live_sessions/presentation/widgets/live_player_stage.dart:105-133` — same pattern, and its restore orientation list (`portraitUp, portraitDown`) differs from the lesson player.

The stage ignores the actual available width (720/900pt cap) and leaves almost no
room for lesson content below it on iPad.

## 6. Phone-shaped layouts and fixed children

- `lib/features/auth/login/presentation/refactor/login_body.dart:17-47` — `Expanded` + `IntrinsicHeight` + `ConstrainedBox(minHeight: maxHeight)` inside a `SingleChildScrollView`; unbounded scroll height with `Expanded` is fragile at tablet sizes.
- `lib/core/widgets/app_top_bar.dart:29-35` — `56.w` horizontal padding (~112pt each side on iPad) plus a full-width bottom nav bar while the body is only 720pt wide.
- `lib/core/widgets/live_session_action_button.dart:24` — fixed `132.w` button (~263pt on iPad) inside `Row`s.
- `lib/features/gallery/presentation/widgets/gallery_grid.dart:26-42` — the only responsive grid (900/600 → 4/3/2 columns), but it sits inside the 900pt `AppSectionScaffold`, so at 820pt portrait the 4-column branch is unreachable.
- `lib/core/widgets/app_bottom_nav_bar.dart:25-37` — bottom bar stays full width; no tablet rail, no `endDrawer`.

## 7. Sheets and modals use percentages of the full screen

- `lib/core/utils/custom_bottom_sheet.dart:17-19` — `maxHeight = screen.height * 0.85`.
- `lib/core/widgets/playback_speed_sheet.dart:33-35`, `lib/features/notifications/presentation/widgets/notification_image.dart:28-29`.

On a tall iPad these become very tall panels with phone-scaled content floating inside.

## Summary

The iPad issues are not a single widget bug. They come from four systemic
decisions: a 412x917 design size applied to all devices, `.w`/`.h` used for
nearly every dimension, multiple hard width caps (560/720/900) that conflict
with those scaled dimensions, and a portrait-only lock with unused tablet
detection. Fixing one screen will not resolve it; the layout system itself needs
a real tablet breakpoint path.
