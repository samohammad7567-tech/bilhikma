# Local Progress Report — Lesson Watch Percentage

**Branch:** `feature/pdf-file-updates-phone-number`
**Commit:** `7c85d5b` — *add local progress*
**Feature:** `lib/features/lesson_detail`

---

## 1. The Problem

Lesson watch progress is owned by the **server**, and the server only updates it at
**checkpoints**.

- The backend sends a `checkpoints` list with the lesson detail
  (`LessonDetailModel.checkpoints` — `lib/features/lesson_detail/data/models/lesson_detail_model.dart:39`).
- Checkpoints sit at **quartiles of the lesson duration** (25% / 50% / 75% / 100%).
- The app only reports progress when playback crosses the next checkpoint
  (`LessonDetailCubit._reportDueCheckpoint`).
- The credited percentage comes back as `progress_percent`
  (`LessonProgressModel.progress` — `lib/core/models/lesson_progress_model.dart`).

**Result for the user:** on a 40-minute lesson the progress bar showed `0%` for
the first 10 minutes, then jumped straight to `25%`, then froze again for another
10 minutes. The bar looked broken / frozen, and the user could not tell whether
their watching was being tracked at all.

---

## 2. The Fix — Two Progress Tracks

We kept the server as the **only source of truth**, and added a **local,
display-only** progress value that fills the gap between checkpoints.

| Track | Source | Used for |
|-------|--------|----------|
| **Confirmed** | Server `progress_percent` | Unlocking, completion, reporting, business logic |
| **Local / Pending** | `watchedHighWaterSeconds / durationSeconds` | Display only — never sent anywhere |

### 2.1 State-level computation

`lib/features/lesson_detail/presentation/cubit/lesson_detail_state.dart`

```dart
/// Furthest second reached on this device.
int get watchedHighWaterSeconds =>
    positionSeconds > progress.maxPositionSeconds
        ? positionSeconds
        : progress.maxPositionSeconds;

/// Progress the server has actually credited.
double get confirmedProgress => progress.progress;

/// Optimistic progress derived from local playback, for display only.
double get localProgress {
  final int total = detail?.durationSeconds ?? 0;
  if (total <= 0) return confirmedProgress;
  return (watchedHighWaterSeconds / total).clamp(0.0, 1.0);
}

/// What the progress bar renders. Never falls below confirmedProgress.
double get displayProgress {
  if (progress.isCompleted) return 1;
  return localProgress > confirmedProgress ? localProgress : confirmedProgress;
}
```

Key guarantees written into these getters:

1. `displayProgress` **never drops below** `confirmedProgress` — if the server
   rejects a seek (422) and pulls the position back, the bar falls back to the
   credited value instead of showing a fake number.
2. `localProgress` falls back to `confirmedProgress` when duration is unknown
   (`total <= 0`), so no division by zero and no bogus `0%`.
3. `isCompleted` short-circuits to `1.0`, so a finished lesson always reads 100%.
4. `watchedHighWaterSeconds` was deliberately kept **separate** from
   `seekLimitSeconds`, even though the formula is identical today — seek policy
   and display policy must be free to diverge without one silently changing the other.

### 2.2 UI-ready view object

`lib/features/lesson_detail/presentation/refactor/lesson_progress_view.dart` (new file)

```dart
class LessonProgressView {
  factory LessonProgressView.of(LessonDetailState state) => LessonProgressView(
    totalSeconds:   state.detail?.durationSeconds ?? 0,
    elapsedSeconds: state.watchedHighWaterSeconds,
    confirmed:      state.confirmedProgress,
    pending:        state.displayProgress,
  );

  int  get percent    => (pending * 100).floor();  // floor -> never 100% early
  bool get hasPending => pending > confirmed;
}
```

This keeps the widgets dumb: they render `confirmed`, `pending`, `percent` and
`hasPending`, and compute nothing.

### 2.3 Widget rendering — two-layer bar

`lib/features/lesson_detail/presentation/widgets/lesson_summary_position.dart`

The bar is a `Stack` of two `LinearProgressIndicator`s:

- **Back layer** (only when `hasPending`): `view.pending`, drawn in
  `secondaryContainer.withValues(alpha: 0.4)` — the faded "watched but not yet
  credited" segment.
- **Front layer**: `view.confirmed`, drawn in full `secondaryContainer` — the
  server-credited segment.

The row above the bar shows `elapsed/remaining` (`LessonDetailFormats.position`)
on one side and `${view.percent}%` on the other, forced to `TextDirection.ltr`
so the clock never mirrors in Arabic.

The same two-layer capability was added to the shared `AppProgressBar`
(`lib/core/widgets/app_progress_bar.dart`) via an optional `pendingProgress`
parameter, so other screens can adopt it later.

---

## 3. Local Persistence (survives app restart)

Local progress is not just in-memory — it is cached per lesson so closing the app
mid-lesson does not reset the bar.

**Model:** `lib/features/lesson_detail/data/models/lesson_playback_state_model.dart`

```json
{
  "content_id": 12,
  "position_seconds": 480,
  "watched_delta_seconds": 35,
  "next_checkpoint_index": 1
}
```

**Data source:** `lib/features/lesson_detail/data/data_source/lesson_playback_data_source.dart`
— JSON stored in `CacheUtil` under key `lesson_playback_<contentId>`.

**Write path:** `LessonDetailCubit._persistCounter()` runs on every playback tick,
on media end, after each accepted checkpoint, and after a server correction.

**Read path:** `LessonDetailCubit._restoredCounter(detail)` on `loadLesson()`:

1. If a cached entry exists (`positionSeconds > 0 || nextCheckpointIndex > 0`) → use it.
2. Else if the lesson is already completed → return the empty entry.
3. Else **seed from the server**: `positionSeconds = progress.maxPositionSeconds`,
   and `nextCheckpointIndex` = number of checkpoints already passed. This makes a
   fresh install / new device resume correctly from server state.

**Clear path:** when `hasReportedEveryCheckpoint && progress.isCompleted`, the
cache entry is deleted (`playbackStore.clear(id)`) — no stale local data for a
finished lesson.

---

## 4. Safety Rules Preserved

The local track is purely cosmetic. None of the existing server contracts changed:

- **Reporting** still only fires at `nextCheckpointSeconds`; local progress is
  never sent to the API.
- **Seek limit** still comes from `seekLimitSeconds` — local progress does not
  let the user scrub further ahead.
- **Completion / unlocking** still read `progress.isCompleted` and
  `confirmedProgress` only.
- **Seek rejection (422)**: `_applyCorrection` resets `positionSeconds`, zeroes
  `watchedDeltaSeconds`, and starts a 5-second cooldown (`_correctionCooldown`) —
  the bar snaps back down to the credited value.
- **Refusal (403 / 404)**: `_isProgressHalted` stops the once-a-second retry loop
  permanently for that lesson.
- **Delta carry-over**: `_sendCheckpoint` captures `sentDelta` before the await and
  carries the remainder afterwards, so seconds watched while the request was in
  flight are not lost.

---

## 5. Files Touched

| File | Change |
|------|--------|
| `presentation/refactor/lesson_progress_view.dart` | **New** — UI-ready two-track progress view |
| `presentation/cubit/lesson_detail_state.dart` | Added `watchedHighWaterSeconds`, `confirmedProgress`, `localProgress`, `displayProgress` |
| `presentation/widgets/lesson_summary_position.dart` | Two-layer bar, elapsed/remaining + percent row |
| `presentation/widgets/lesson_summary_card.dart` | Takes `LessonProgressView` instead of `LessonProgressModel` |
| `presentation/refactor/lesson_detail_body.dart` | Passes `LessonProgressView.of(state)` |
| `core/widgets/app_progress_bar.dart` | Optional `pendingProgress` layer |
| `data/models/lesson_playback_state_model.dart` | Local playback cache model |
| `data/data_source/lesson_playback_data_source.dart` | Local read / write / clear |

---

## 6. Behaviour Before vs After

**Lesson: 40 minutes, checkpoints at 10 / 20 / 30 / 40 min**

| Watch time | Before | After |
|-----------|--------|-------|
| 0:00 | 0% | 0% |
| 4:00 | 0% (frozen) | 10% (faded bar) |
| 9:59 | 0% (frozen) | 24% (faded bar) |
| 10:00 | 25% (jump) | 25% (faded segment turns solid) |
| 15:00 | 25% (frozen) | 37% (faded bar) |
| 40:00 | 100% | 100% |

---

## 7. Open Items / Notes

- `AppProgressBar.pendingProgress` is implemented but **no caller passes it yet**.
  Lesson cards, subject headers, and the home resume card still show
  server-confirmed progress only. If the same two-track display is wanted in lists,
  the local value has to be plumbed through to those call sites.
- `percent` uses `floor()` on purpose — the label must not read 100% before the
  final checkpoint is acknowledged.
- The local cache is keyed per `content_id` and per device; it is not synced across
  devices. The server seed in `_restoredCounter` covers the new-device case.
- No `build_runner` needed — no generated code involved.
