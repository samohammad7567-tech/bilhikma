# Responsive plan — every iOS / Android device, powered by `my_screen_size.dart`

## 0. Current state

`flutter_screenutil` has been removed from `pubspec.yaml`, `lib/` and `test/`.
`lib/core/utils/my_screen_size.dart` is now the responsive API, and
`lib/core/utils/screen_scale.dart` only delegates to it via
`(n).w(context) / .h(context) / .r(context) / .sp(context)`.

Verified baseline: `flutter analyze` has 0 errors (8 pre-existing warnings/infos),
`flutter test` passes all 206 tests.

The migration and the responsive pass are **complete**. `MyScreenSize.w/h/r/sp`
clamp the raw 412 × 917 design ratios, so an iPad Air in landscape no longer
multiplies `.w` by `1180 / 412 = 2.86`.

All bypasses listed in the original plan are closed: the shell breakpoint, caps,
grid columns, tab icons, video stage, sheets and chrome heights now come from
`MyScreenSize`; `screen_size.dart` and `responsive_design_canvas.dart` are
deleted; the migration debug prints are removed. The last two raw
`MediaQuery.sizeOf` reads (`app_empty_view.dart`, `drag_dismiss_backdrop.dart`)
and the raw `textScaler` multiplication in `live_session_action_button.dart`
were routed through `MyScreenSize` as well.

## 1. Goals

1. **One source of truth:** every responsive decision (breakpoint, cap, scale,
   safe area, keyboard, orientation) is answered by `MyScreenSize`. No file reads
   `MediaQuery.sizeOf` for layout decisions, no second `ScreenSize` helper.
2. **Phone UI on phones, tablet UI on tablets.** Compact → bottom bar + full-width
   content; medium/expanded → nav rail + capped, centred content.
3. **Bounded scaling.** Design-baseline values may grow on bigger screens, but
   never by 2–3×. Text stays legible and never fights the accessibility text scaler.
4. **Works in split view, landscape and with the keyboard open.** Decisions follow
   the *available* window, not the physical device.
5. **Zero layout exceptions** (overflow / render flex) in the device matrix below.

Non-goals: a different design system, multi-pane master/detail screens, or changing
business logic. This is layout infrastructure only.

## 2. Device / state matrix

`MyScreenSize.windowSize` uses width classes; `isTablet` uses `shortestSide >= 600`.
Use **`isTablet` for chrome choice** (rail vs bar) and **`windowSize` for content
width / columns**. A landscape phone (844 × 390) is therefore still a phone.

| Class | Examples (logical points) | Chrome | Content |
|---|---|---|---|
| compact | 360 × 640, 390 × 844, 430 × 932, 507 × 744 split view, 280 × 653 foldable cover, 844 × 390 landscape phone | bottom bar, 70 pt | full width |
| medium | 600–839 short side: iPad mini 744 × 1133, iPad 810 × 1080, 674 × 841 foldable | rail, 96 pt | capped ~900 |
| expanded | ≥ 840 short side: iPad Air 820 × 1180 (portrait → compact side 820 = medium), iPad Pro 1024 × 1366, iPad Air 1180 × 820 landscape | rail | capped ~1040 |

Also in scope for every class: RTL (`ar` is the default locale), `textScaler` up to
2.0, app `fontScale` 0.8–1.4 (`AppChrome`), keyboard open (`viewInsets.bottom`),
notches/home bars (`paddingOf`), and DPR 1–3.

## 3. Phase 1 — encode the policy in `my_screen_size.dart`

Change this file first; every later phase consumes it.

1. **Clamp design scaling** so a 412 dp value does not become 1180 dp:
   ```dart
   static double scaleW(BuildContext context) =>
       (width(context) / _designWidth).clamp(0.85, 1.35);
   static double scaleH(BuildContext context) =>
       (height(context) / _designHeight).clamp(0.85, 1.25);
   ```
   `w()` uses `scaleW`, `h()` uses `scaleH`, `r()` uses `scaleW`,
   `sp()` uses `min(scaleW, scaleH)` (keep `minTextAdapt` behaviour, clamp 0.9–1.3).
   Keep the existing 412 × 917 baseline constants.
2. **Add height awareness** (landscape phones are short, tall iPads are not):
   ```dart
   static bool isCompactHeight(BuildContext context) => height(context) < 600;
   ```
3. **Add discrete layout answers** so screens never re-implement thresholds:
   - `contentMaxWidth(context)` → `value(context, compact: double.infinity, medium: 900, expanded: 1040)`
   - `galleryColumns(context)` → `value(context, compact: 2, medium: 3, expanded: 4)`
   - `bottomChromeHeight(context)` → `isTablet(context) ? 0 : 70`
   - `navRailWidth(context)` → `isTablet(context) ? 96 : 0`
4. **Use the existing safe-area / keyboard / DPR getters** where phases 4–5 need
   them; do not add new `MediaQuery` reads anywhere else.
5. `screen_scale.dart` stays a thin adapter — no policy there.
6. Remove `lib/core/utils/screen_size.dart` after migrating its consumers.

Acceptance: `flutter_check` clean on `my_screen_size.dart` / `screen_scale.dart`;
a new test asserts clamped factors on 390 × 844, 820 × 1180 and 1180 × 820.

## 4. Phase 2 — shell and navigation

- `lib/features/main_shell/presentation/widgets/main_shell_view.dart`
  - drop the local `_wideBreakpoint = 600`; use `MyScreenSize.isTablet(context)`.
  - drop `_contentMaxWidth`; use `MyScreenSize.contentMaxWidth(context)`.
  - compact: `bottomNavigationBar: AppBottomNavBar(...)`, body = tabs, full width.
  - medium/expanded: rail row, content `SizedBox(width: contentWidth)`; when
    `contentMaxWidth` is infinite, do not centre-cap.
  - keep `LayoutBuilder` only for the *available height* of the rail row, never
    for breakpoint decisions.
- `lib/core/widgets/app_bottom_nav_bar.dart`: `barHeight` from
  `MyScreenSize.bottomChromeHeight(context)`; keep the 64–76 clamp and fixed-12
  label size with `MediaQuery.withClampedTextScaling(maxScaleFactor: 1)`.
- `lib/core/widgets/app_nav_rail.dart`: width from `MyScreenSize.navRailWidth(context)`;
  clamp labels exactly as today.
- `lib/core/widgets/bottom_nav_tab_icon.dart`: replace raw width fractions with
  `MyScreenSize.widthFraction(context, …)`; keep the 24 / 44 max clamps.
- Delete `lib/core/widgets/responsive_design_canvas.dart`; remove it from
  `lib/bilhikma_app.dart:50` and `test/nav_label_responsive_test.dart`. If a
  wrapper is still wanted, make it delegate to `AppContentWidth` + `MyScreenSize`,
  not a no-op.
- Remove the migration debug prints in `lib/bilhikma_app.dart:24-37`.

Acceptance: bottom bar on 390 × 844 and 844 × 390; rail on 820 × 1180 and
1180 × 820; split view 507 × 744 keeps the bottom bar.

## 5. Phase 3 — shared layout primitives

- `lib/core/widgets/app_content_width.dart`: default `maxWidth` becomes
  `MyScreenSize.contentMaxWidth(context)`; `double.infinity` remains the opt-out.
- `lib/core/widgets/app_section_scaffold.dart`: stop passing a hardcoded 900;
  inherit the new default (keep `maxContentWidth` override for media screens).
- Content caps to reconcile: `login_body.dart:20` (560 → `widthFraction(context, 0.85, max: 560)`),
  drawer (`widthFraction(0.8, max: 320)` already correct),
  `test/responsive_content_test.dart` expectations updated to the new policy.
- Consumers of `AppBottomNavBar.barHeight` (`archive_content.dart:47`,
  `live_sessions_list.dart:28`, `profile_body.dart:38`, `notifications_list.dart:74`,
  `home_sections.dart:119`, `subjects_list.dart:36`, `app_toast.dart:133-136`)
  use `MyScreenSize.bottomChromeHeight(context)` so rail layouts do not reserve
  bottom-bar space.
- `app_top_bar.dart:29-35`: 48 pt min height stays, 56.w padding becomes
  `MyScreenSize.value(context, compact: 16, medium: 24, expanded: 32)`.
- `live_session_action_button.dart:23`: replace `132 * textScaler` with a
  `MyScreenSize.value` width plus `TextScaler` only for the label.

Acceptance: no fixed width/height in `core/widgets` is a multiple of the old
design ratio; `flutter_check` clean on every touched file.

## 6. Phase 4 — feature layouts

- `lib/features/gallery/presentation/widgets/gallery_grid.dart`: use
  `MyScreenSize.galleryColumns(context)` instead of `constraints.maxWidth` (keep
  `LayoutBuilder` only for OTP-like genuinely constraint-driven widgets).
- Audit all grids/lists for hidden 2/3/4-column logic and route them through the
  same `value(context, compact:, medium:, expanded:)` call.
- `lib/core/utils/video_stage_sizing.dart`: replace raw `MediaQuery.sizeOf` with
  `MyScreenSize.width/height`; fullscreen uses `heightFraction(context, 1)`;
  normal stage `min(width / aspectRatio, heightFraction(context, 0.55))`.
  Landscape on compact-height devices gets a short, full-bleed stage; medium/
  expanded keeps the 55 % cap and the media-screen width opt-out.
- `lib/core/services/videoplayerservice/widgets/expanded_video_player.dart:68-103`
  keeps its landscape branch but sources the decision from `MyScreenSize.isLandscape`.
- Sheets/dialogs: `playback_speed_sheet.dart:22` (0.85) and
  `notification_image.dart:23,28` (0.42) use `MyScreenSize.heightFraction`;
  `custom_bottom_sheet.dart` / `country_picker_sheet.dart` already do — align
  their factors and keyboard padding through `MyScreenSize.keyboardHeight`.
- Full-bleed opt-outs (`book_preview_screen.dart:32`, `live_player_screen.dart:106`)
  remain explicit; every other screen inherits the cap.

Acceptance: at 1180 × 820 no sheet exceeds 85 % of viewport height, no video
stage exceeds 55 %, no `RenderFlex overflowed` exception in the matrix.

## 7. Phase 5 — orientation, keyboard, accessibility

- `lib/core/utils/orientation/orientation_util.dart`: replace legacy
  `ScreenSize.isMobile` with `MyScreenSize.isTablet/shortestSide`; phones stay
  portrait-only (except fullscreen video), tablets allow portrait + both
  landscapes. Return the same list for both branches today only if intentional —
  document the decision in the plan's risk section.
- `lib/core/utils/orientation/orientation_lock.dart`: re-evaluate when the window
  changes (split view / dock / rotate) instead of the one-shot `_done` flag.
- `lib/core/utils/orientation/video_fullscreen_orientation.dart`: restore the
  per-class orientation list after fullscreen; never restore "portrait only" on a
  tablet.
- Keep `AppChrome`'s user `fontScale` (`MediaQuery.withClampedTextScaling`) as the
  only global text-scale override; `MyScreenSize.textScaler` is read, never
  cancelled. Nav labels keep their local `maxScaleFactor: 1`.
- Forms: with the keyboard open, use `MyScreenSize.keyboardHeight` +
  `isKeyboardOpen` for sheet/form insets; keep
  `ScrollViewKeyboardDismissBehavior.onDrag` in search / forgot-password flows.
- `SafeArea` comes from `AppChrome` (`top/left/right: false`); screens that need
  bottom inset use `MyScreenSize.bottomPadding`.

Acceptance: rotate a tablet with the app open, enter/exit video fullscreen, open
the keyboard on 390 × 844 — no exception, correct orientation restored.

## 8. Phase 6 — tests and verification

Update existing tests for the new policy (they currently assert pre-migration
constants):

| File | Change |
|---|---|
| `test/bottom_nav_responsive_test.dart` | keep bar 64–76 / icon 24 / halo 44; add 844 × 390 and 360 × 640 |
| `test/nav_label_responsive_test.dart` | remove `ResponsiveDesignCanvas`; rail width 96 on medium/expanded |
| `test/responsive_content_test.dart` | caps from `MyScreenSize.contentMaxWidth`, columns from `MyScreenSize.galleryColumns` |
| new `test/my_screen_size_test.dart` | clamped `w/h/r/sp`, `windowSize`, `isTablet`, `isCompactHeight`, `value`, fractions, keyboard/safe area |

Add a shared helper that sets `tester.view.physicalSize` + `devicePixelRatio` and
`addTearDown(tester.view.reset)` (the pattern already used in the three responsive
tests). For every device-matrix row assert:

1. `tester.takeException()` is null (catches overflow and bad constraints).
2. Correct chrome: bottom bar vs rail; correct width/height.
3. Content width equals the class cap (or full width when opted out).
4. Gallery column count matches `galleryColumns`.
5. Text/RTL: labels render, nav label `fontSize == 12` with scale clamped.
6. Keyboard open: no clipped input, sheet bottom inside the viewport.

Commands at each phase boundary:

```powershell
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed lib test
```

Run `flutter_check` on every touched Dart file and fix all violations. No
generated code is involved, so **`build_runner` is not needed**.

## 9. Definition of done

- [x] No `MediaQuery.sizeOf` used for layout decisions outside `my_screen_size.dart`.
- [x] `screen_size.dart` and `responsive_design_canvas.dart` removed or converted
      to thin `MyScreenSize` adapters; no dead duplicate helpers remain.
- [x] `.w/.h/.r/.sp` scale factors are clamped on tablets.
- [x] One breakpoint policy (`isTablet` for chrome, `windowSize` for content) used
      by shell, grid, caps and video.
- [x] `flutter analyze`: 0 errors (8 pre-existing warnings/infos); `flutter test`:
      all 215 pass; `flutter_check`: clean on touched files.
- [ ] Manual pass on iPhone SE, iPhone 15 Pro Max, Android 360 dp phone, foldable
      cover/unfolded, iPad mini, iPad Air portrait/landscape, iPad Pro split view,
      Arabic RTL, largest font size, keyboard open, video fullscreen.

## 10. Risks and order

1. **Clamping changes every screen at once.** Do Phase 1 first, run the full test
   suite, then visually spot-check three screens before touching the shell.
2. **Test constants reflect the old policy.** Update tests in the same phase as
   the code they cover; do not leave red tests between phases.
3. **Orientation locks are global.** Tablet landscape must be paired with the
   fullscreen restore path, otherwise rotation gets stuck.
4. **Full-bleed media vs caps.** Keep `maxContentWidth: double.infinity` explicit
   and tested; never make the cap unconditional.
5. **Accessibility.** Never compensate for a large `textScaler` by shrinking
   fonts; clamp boxes instead and allow scrolling.

Recommended execution order: **1 → 2 → 3 → 4 → 5 → 6**, with `flutter analyze`,
`flutter test` and `flutter_check` after each phase.
