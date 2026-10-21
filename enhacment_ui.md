# UI Enhancement Plan — Bilhikma Mobile

> Status: **plan only — nothing implemented yet.** Phases are independently shippable; pick the ones you want.

## Context

Bilhikma is an Arabic-first (RTL) Islamic education app with a deliberate cream/green/gold identity.
The request: **raise UI quality without changing the app's theme.**

A full audit of all 625 Dart files found the codebase is in genuinely good shape — this is a polish
job, not a rescue. Strengths worth preserving rather than "improving":

- **Typography is already a real system.** `AppTextStyles` (`lib/core/themes/app_theme.dart`) exposes
  ~39 semantic roles (`sectionTitle`, `cardTitle`, `rowTitle`, `statValue`, …) read via
  `AppTheme.styles(context)`. Only 21 ad-hoc `TextStyle(` remain outside `themes/`.
- **Zero hardcoded UI text.** 210 `Text(` call sites, **0** literal Arabic/English strings; `ar.json`
  and `en.json` are at exact 339/339 key parity.
- **RTL is handled deliberately** — `EdgeInsetsDirectional`, `AlignmentDirectional`,
  `PositionedDirectional` throughout, and **zero** `EdgeInsets.only(left:/right:)` in all of `lib/`.
- **Overflow guards are consistent** — 160 `maxLines` against 210 `Text(`, paired with `ellipsis` on
  every card widget.
- `AppEmptyView`/`AppErrorView` wired into ~15 features; `RefreshIndicator` on 9 list screens;
  reduced-motion already respected (`app_skeleton_box.dart:36`, `splash_body.dart:27`).
- Only 12 of 318 presentation files exceed 150 lines.

### Explicitly out of scope

- **No theme changes.** `app_colors.dart`, both `ColorScheme`s, and every `AppTextStyles` value stay
  exactly as they are. No new colors, no font or size changes.
- **Hardcoded colors are a non-issue.** 85 of 89 `Color(0x…)` live inside the 4 theme files. The
  `Colors.*` uses are overwhelmingly `white`/`black` over video surfaces and `transparent` for
  `Material` — intentionally correct. Not worth churning.
- **No `LangKeys` migration.** The global convention expects it, but this project has none: ~238
  untyped `'key'.tr()` literals. Converting them is a mechanical refactor with zero visual payoff.
  Flagged as a separate future task, deliberately not bundled here.
- **No new `CardTheme`/`ElevatedButtonTheme`/`InputDecorationTheme`.** Genuinely absent, but
  components are styled per-widget today; introducing them would silently shift appearance and
  violate the no-theme-change constraint.
- **No new dependencies.** `flutter_animate: ^4.5.2` is already declared with **zero call sites**.

---

## Phase 0 — Verified defects found during the audit (do this first)

These are not stylistic opinions; each is read from the file and confirmed. They are small, and three
are user-visible breakage. Strictly speaking they are bug fixes rather than "enhancements" — listed
separately so you can take them independently.

| # | File:line | Confirmed problem | Fix |
|---|---|---|---|
| 1 | `live_sessions/presentation/refactor/live_sessions_body.dart:32` | `errorKey: "state.messageKey"` — a **quoted string literal** where the variable was meant. No such key exists, so `easy_localization` renders the raw text `state.messageKey` on screen on any load failure. On a bottom-nav tab. | `errorKey: state.errorKey` (the state has both `errorKey` and `messageKey`; siblings use `errorKey`) |
| 2 | `core/drawer/presentation/widgets/drawer_profile_card.dart:30` | `const DrawerProfileMonogram(avatarUrl: '')` — hardcoded empty, so the user's avatar **never renders**; it always falls back to initials. | Pass the real URL from `ProfileState` via the existing `BlocBuilder` |
| 3 | `lesson_detail/presentation/refactor/lesson_detail_body.dart:54` | `if (detail == null \|\| state.isLoading)` returns a full-screen spinner. Because it's an **OR**, any reload *after* load tears down the whole subtree — including the live `LessonVideoStage`/`LessonAudioStage` — dropping player state mid-lesson. | Split: spinner only when `detail == null`; keep content mounted while `isLoading` |
| 4 | `textbooks/presentation/refactor/book_preview_body.dart:25` | A **failure** state rendered through `AppEmptyView`, which has no action button — so a failed book load is a dead end with no retry. | Switch to `AppErrorView(errorKey: …, onRetry: cubit.load)` |
| 5 | `lessons/presentation/widgets/lessons_content.dart:90` | Pagination button labelled `Text('view_all'.tr())` — reads "View all"/"عرض الكل" when it means "Load more". | New `load_more` key in both JSONs (verified **absent**) |
| 6 | `auth/login/presentation/refactor/login_body.dart:22` | `Expanded` inside `IntrinsicHeight` — the classic Flutter pitfall (O(n²) layout, can mislay out). The surrounding `LayoutBuilder` + `ConstrainedBox(minHeight:)` already achieves fill-to-viewport. | Drop `IntrinsicHeight`, keep the `ConstrainedBox` |
| 7 | `home/presentation/widgets/home_sections.dart:82` | `SliverList.builder` over `state.subjects` with **no empty branch** — a new user with zero subjects sees a section header followed by nothing. The only feature in the app with no empty state. | `AppEmptyView` with the **already-existing** `no_subjects` key |

---

## Phase 1 — Shared foundations (additive, zero visual change)

New files only; nothing existing is restyled, so this phase is visually inert and independently
shippable. Note `lib/core/` **is** the shared layer — there is no `corereusablepackage` in this repo.

**`lib/core/themes/app_motion.dart`** — motion tokens matching the idiom the app already uses in
`app_toast.dart` (220ms, `easeOutCubic`) and `splash_timeline.dart` (`easeOut`/`easeOutCubic`/`easeOutBack`):

```dart
class AppMotion {
  AppMotion._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration stagger = Duration(milliseconds: 40);
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeIn;
}
```

**`lib/core/themes/app_spacing.dart`** — *names the scale already in use* (values taken from the
existing de-facto vocabulary, so adoption is a pure rename, never a visual shift):

```dart
class AppSpacing { // .w/.h applied at call site
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 20, xxl = 24;
}
class AppRadii { // observed: 10.r×24, 12.r×18, 8.r×16, 6.r×9, 14.r×9, 20.r×7
  static const double sm = 6, md = 8, lg = 10, xl = 12, xxl = 14, pill = 20;
}
```

**`lib/core/widgets/app_fade_slide_in.dart`** — the single motion wrapper the whole app reuses: fade
+ small upward slide, `index`-based stagger, and a `MediaQuery.disableAnimationsOf(context)`
early-out that renders `child` instantly (mirroring `app_skeleton_box.dart:36`). Plain
`TweenAnimationBuilder` — no dependency surface.

**`lib/core/widgets/app_skeleton_list.dart`** — generic `ListView.separated` of skeleton rows,
generalised from `downloads_log_skeleton.dart`, which is already the correct pattern and serves as
the in-repo reference implementation.

**Two existing shared widgets enhanced additively** (every new param optional, so all current call
sites compile and look identical):

- `app_empty_view.dart` — add optional `titleKey`, `actionLabelKey`, `onAction`. Title in
  `sectionTitle` above the message; `CustomButton` below when an action is given.
- `app_error_view.dart` — add optional `icon` (default `Icons.cloud_off_rounded`) at `44.w` /
  `colors.outline`, plus the same `LayoutBuilder` min-height treatment `AppEmptyView` has. Today the
  error view has **no icon and no min-height**, so the more alarming of the two states looks the less
  finished one; this makes them read as one family.

---

## Phase 2 — Skeleton loading (the headline win)

`AppSkeletonBox` is a good, reduced-motion-aware primitive with only **2 consumers**, while **33
sites** render `const Center(child: CircularProgressIndicator())` as their first-load state.
`downloads_log_body.dart:20` is the one screen doing it right — and it sits in the *same feature* as
`profile_body.dart:23`, which uses a bare spinner. Two standards inside one feature.

One `*_skeleton.dart` per feature in that feature's `widgets/`, each mirroring the real layout so
there is **no layout shift** when content arrives. The body edit is the same shape every time:

```dart
if (state.isFirstLoad) return const HomeSkeleton();   // was Center(child: CircularProgressIndicator())
```

| Feature | Body to edit | Skeleton mirrors |
|---|---|---|
| home | `refactor/home_screen_body.dart:56` | `home_sections.dart` — institution card, stats row, section header, 3 `SubjectCard`s |
| **sidebar/drawer** | `drawer_profile_card.dart:38` | name slot — currently a **blank underlined text slot** on every drawer open, with no error state either |
| subjects | `refactor/subjects_body.dart:19` | `subjects_list.dart` rows |
| subject_content | `widgets/subject_content_content.dart:43` | section headers + lesson/book/album tiles |
| lessons | `widgets/lessons_content.dart:24,63` | `lesson_card.dart` rows |
| live_sessions | `refactor/live_sessions_body.dart:27` | `live_session_tile.dart` rows |
| notifications | `refactor/notifications_body.dart:25` | `notification_card.dart` rows |
| profile | `refactor/profile_body.dart:23` | avatar + info rows |
| search | `widgets/search_results.dart:20` | result rows |
| textbooks | `refactor/book_preview_body.dart:42` | page frame — **no loading branch exists today**, and a large PDF is the slowest asset in the app |
| educational_pathways | `refactor/educational_pathways_body.dart:24` | `pathway_card.dart` rows |

**Keep the spinners that are correct** — button-local progress (`custom_button.dart`,
`custom_outline_button.dart`), media buffering (`lesson_video_stage`, `live_player_stage`), and
per-item download progress (`download_log_tile.dart`). A skeleton is for first paint of unknown
content, not for a button the user just pressed.

**Background refresh must not skeleton-ise.** Where a cubit separates first load from refresh
(`isFirstLoad` in `home_cubit`, `live_sessions_state.dart:20`), keep existing content on screen — the
`RefreshIndicator` is the feedback. Two related list-collapse bugs to fix while here:
`lessons_content.dart:60` replaces the whole list with a centered spinner on category switch, and
`search_results.dart:20` does the same on every query — both collapse list height and jump the
scroll position.

---

## Phase 3 — Motion & micro-interactions

- **List/section entrance** — wrap list items and home sections in `AppFadeSlideIn` with `index`
  stagger, capped at the first ~8 items so long lists don't animate forever.
- **Loading → content handoff** — wrap the Phase-2 skeleton/content swap in
  `AnimatedSwitcher(duration: AppMotion.normal)` so content fades in instead of snapping.
- **Image fade** — `app_network_image.dart` hardcodes `fadeInDuration: Duration.zero`, so every
  remote image in the app pops in. Change to `AppMotion.normal` (keep `fadeOutDuration: Duration.zero`).
  One line, app-wide benefit.
- **Page transitions** — all ~25 routes in `core/routing/app_router.dart` are `MaterialPageRoute` and
  no `pageTransitionsTheme` is set. Add a shared RTL-aware fade-through builder to `AppTheme.light()`
  and `dark()`. This changes *motion only* — no colour, no type — so it holds the no-theme-change line.
- **Hard cuts to soften** — `notification_filter_tabs` (`notifications_body.dart:39`),
  `LessonCategoryChips` (`subject_content_content.dart:68`), and pathway expand/collapse
  (`educational_pathways_content.dart:53`, needs `AnimatedSize`) all switch content instantly.
- **Tap feedback** — convert the 5 genuine button-like `GestureDetector`s to `InkWell`:
  `auth/forget_password/.../back_to_login_row.dart`, `field_icon_box.dart`,
  `auth/login/.../login_options_row.dart`, `login_remember_me.dart`,
  `notifications/.../notification_image.dart`. Leave real gesture handlers (video seek,
  `drag_dismiss_backdrop`, `photo_view`) alone.

All motion routes through `AppFadeSlideIn`/`AppMotion`, which honour
`MediaQuery.disableAnimationsOf` — reduced-motion users get instant rendering.

---

## Phase 4 — RTL, responsiveness, accessibility

- **Menu-icon side** (already-reported bug, see `fix_ui.md`): the drawer toggle sits on the wrong side
  on some screens, confirmed on live sessions. `AppSectionScaffold`/`AppTopBar` already position
  start/end slots correctly, so the fix is routing the offending screens through those slots instead
  of a hand-placed icon.
- **Ornaments don't mirror in LTR** (also `fix_ui.md`): `splash_ornaments_band.dart:30,38,47` uses bare
  `Positioned`. Switch to `PositionedDirectional` so decoration follows text direction.
- **Text scale — the biggest accessibility win available.** `app_chrome.dart:13-14` calls
  `MediaQuery.withClampedTextScaling(minScaleFactor: fontScale, maxScaleFactor: fontScale)` — min and
  max identical, which **pins** text scale to the in-app setting and completely overrides the user's
  OS accessibility preference. Relax to a range around the in-app scale (e.g. `×0.9`–`×1.3`) and fix
  the resulting overflow.
- **Tablet layouts.** `ScreenSize.isTablet` exists but is referenced in exactly **one** feature.
  Make `gallery_grid.dart:31`'s hardcoded `crossAxisCount: 2` responsive (3–4 on tablet) and cap
  content width on wide screens so cards don't stretch absurdly.
- **Raw-px leaks** (mixed with `.w`/`.h` in the same widgets, so they scale inconsistently). Highest
  leverage first: `app_section_scaffold.dart:47` — the top-bar inset on **every** section screen;
  then `home_sections.dart:87`, `educational_pathways_body.dart:41` **and its fixed `height: 40`
  button** (the clearest long-Arabic-string overflow risk found), `educational_pathways_content.dart:27`,
  `app_drawer.dart:34`, `login_form.dart:51`.
- **Missing pull-to-refresh** on two network-backed lists whose siblings all have it:
  `profile_body.dart:33` (a bottom-nav tab — users will pull) and
  `educational_pathways_content.dart:26`.
- **`notifications_list.dart:82-99`** flattens day groups into a pre-built `List<Widget>` fed to
  `ListView.builder` by index, defeating lazy building — every row is constructed on every rebuild.
  Will be felt once a user has a long history. Restructure to build lazily.

---

## Localization

Every new user-visible string gets a key in **both** `assets/translations/ar.json` and `en.json`,
Arabic first, preserving the current exact 339/339 parity. Referenced as `'key'.tr()` per existing
project convention — no `LangKeys` class exists here and this plan does not introduce one.

Confirmed key status: `load_more` must be **added** (absent from both files); `no_subjects`,
`retry`, `something_went_wrong`, `reader_load_failed` already **exist** and should be reused.

---

## Files at a glance

**New:** `core/themes/app_motion.dart`, `core/themes/app_spacing.dart`,
`core/widgets/app_fade_slide_in.dart`, `core/widgets/app_skeleton_list.dart`, plus one
`*_skeleton.dart` per feature in Phase 2.

**Modified:** `core/widgets/app_empty_view.dart`, `app_error_view.dart`, `app_network_image.dart`,
`app_chrome.dart`, `app_section_scaffold.dart`, `core/themes/app_theme.dart` (transitions only),
`core/routing/app_router.dart`, the ~11 feature bodies in Phase 2, the Phase 0 defect files, and the
ornament/menu-icon widgets in Phase 4.

**Untouched:** `core/themes/app_colors.dart`, both `ColorScheme`s, all `AppTextStyles` token values.

---

## Verification

1. `flutter analyze` — must stay clean; state the result.
2. `flutter test` — `test/lesson_playback_reporter_end_delay_test.dart` must still pass. **No
   `build_runner` needed** (no codegen in this project — `freezed`/`json_serializable` absent).
3. Confirm JSON parity after adding keys: `ar.json` and `en.json` must remain key-for-key equal.
4. Run the app and check per phase:
   - **Phase 0:** force a live-sessions load failure and confirm a translated message, not the literal
     `state.messageKey`; open the drawer and confirm the real avatar renders; start a video lesson and
     trigger a reload — the player must **not** tear down; fail a book load and confirm a working retry.
   - **Skeletons:** throttle the network (or add a temporary data-source delay) and confirm each
     Phase-2 screen shows a layout-matching skeleton with **no layout shift** when content lands.
   - **Refresh:** pull-to-refresh and category/query switches keep existing content visible — no
     skeleton flash, no scroll jump.
   - **Reduced motion:** enable OS "reduce motion" — skeletons stop pulsing, `AppFadeSlideIn` renders
     instantly.
   - **RTL/LTR:** switch Arabic ⇄ English via the in-app toggle; menu icon on the correct side and
     ornaments mirrored on every screen.
   - **Tablet:** large emulator — gallery grid gains columns, cards don't over-stretch.
   - **Text scale:** set OS font size to max and sweep the Phase-2 screens for overflow.
5. Prove the theme is untouched: `git diff lib/core/themes/app_colors.dart` must be **empty**, and the
   `app_theme.dart` diff must contain **only** the `pageTransitionsTheme` addition.
