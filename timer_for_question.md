# Per-Question Timer (Section 6.10) — Implementation Plan

Feature: **مؤقّت السؤال الواحد** — a server-enforced countdown per question.

Source of truth: `https://bilhikma.tech/guides/11a59d713e63542b/#s29` (section **6.10**), plus the
related sections 6.2 (flow), 6.3 (answer saving) and 6.4 (deadline/submission).

---

## 1. Goal

When a question has `default_time_seconds`, its timer starts the **first time the student opens
that question** and keeps running on the server even after the student moves to another question.
When it reaches zero the question is locked: the server refuses new answers and grades the answer
that was **saved before expiry**.

The app must:

1. Open every displayed question on the server before accepting answers.
2. Show a countdown derived from the server's `timer.expires_at` (not from the local
   `default_time_seconds`).
3. Keep timers running across question navigation and app minimize/resume.
4. Save each answer to the server (`PUT .../answers`) shortly after it changes.
5. Lock the question UI when `can_answer == false` / `has_expired == true`.
6. Restore the server `saved_answer` when returning to a question or resuming an attempt.

---

## 2. Rules from the spec (must match exactly)

| Situation | Server behavior | App behavior |
|---|---|---|
| Question has no time | Saved/graded normally | No countdown, answers enabled |
| Question has time and was never opened | Answer is not saved; `ignored_question_ids` lists it. If it is the only answer: 422 "يجب فتح السؤال أولاً" | Never allow this state: call `start` before displaying |
| Question opened, time remaining | Saved and graded normally | Show countdown, allow edits |
| Question opened, time expired | Answer is not saved; previous saved answer is graded. If only answer: 422 "انتهى وقت هذا السؤال" | Lock inputs, show saved answer, show "انتهى وقت السؤال" |
| Student leaves the question | Timer keeps running | Do **not** call any stop endpoint; do not reset |
| Student returns to the question | Call `start` again; same `expires_at`, lower `seconds_left`, plus `saved_answer` | Reopen, refresh countdown, restore saved answer |
| App closed and reopened | Call `start` again; returns real remaining time (may already be expired) | Reopen current question on resume |
| Question not yet reached | Its timer has not started | Do not start timers in advance |
| Quiz total time ends | Attempt is submitted automatically by server after 15s grace | Existing total-timer submit flow stays |
| Request sends a time value | Ignored; server clock only | Never send time values |

Important consequence: **the per-question expiry is only meaningful if answers are saved to the
server as the student edits them**. The current app only writes answers to a local cache and sends
everything at submit time. Section 6.3 + 6.10 require `PUT /user/quiz-attempts/{id}/answers`.
This plan therefore includes remote answer saving as **Phase 0 (prerequisite)**.

---

## 3. Current implementation and gaps

Relevant code:

- `lib/features/lesson_test/data/models/test_question_model.dart`
  - `timeLimit` parsed from `options['default_time_seconds']` (line ~171). New API also returns
    `default_time_seconds` and a `timer { ... }` object on each `answers[]` row — not parsed today.
- `lib/features/lesson_test/data/models/quiz_attempt_model.dart`
  - Does not parse `server_now`, `question_timing_enabled`, or per-question `timer`.
- `lib/features/lesson_test/presentation/cubit/lesson_test_state.dart`
  - `questionStartedAt` / `questionRemaining` (lines ~111-121) are computed **locally** from
    `question.timeLimit` and reset on every `_moveTo`. This is wrong for the server-driven model.
- `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart`
  - `_moveTo` (line ~637) resets `questionStartedAt` on every navigation.
  - `_tick` (line ~608) only handles the total attempt timer and a local question timer.
  - `_persistAnswers` (line ~762) writes **local cache only**.
  - No call to the question `start` endpoint and no remote answer saving.
- `lib/features/lesson_test/data/data_source/lesson_test_data_source.dart`
  - Has start attempt / submit / fetch attempt; missing `start question` and `save answers`.
- `lib/core/constants/api_endpoints.dart`
  - Missing `/questions/{questionId}/start` and `/answers`.
- `lib/features/lesson_test/presentation/widgets/test_question_prompt.dart`
  - Already renders a timer chip from `questionRemaining`; reuse it with server-derived remaining
    and a locked/urgent style.
- `lib/features/lesson_test/presentation/screens/lesson_test_screen.dart`
  - On pause it calls `flushAnswers()`; on resume nothing happens. Add a resume hook.

No `build_runner` is needed for this feature (no code generation).

---

## 4. API contract additions

```
POST /user/quiz-attempts/{attemptId}/questions/{questionId}/start   (no body)
PUT  /user/quiz-attempts/{attemptId}/answers
```

### `start` response (200)

```json
{
  "status_code": 1,
  "data": {
    "attempt_id": 171,
    "question_id": 38,
    "server_now": "2026-11-04T11:35:14+00:00",
    "attempt_expires_at": null,
    "timer": {
      "enabled": true,
      "started_at": "2026-11-04T11:35:09+00:00",
      "expires_at": "2026-11-04T11:35:54+00:00",
      "seconds_left": 40,
      "has_expired": false,
      "can_answer": true
    },
    "saved_answer": { "option_id": "red" }
  }
}
```

### `save answers` response (200)

```json
{
  "status_code": 1,
  "data": {
    "attempt_id": 171,
    "saved": 2,
    "ignored_question_ids": [40],
    "expires_at": null,
    "server_now": "2026-11-04T11:36:02+00:00",
    "seconds_left": null,
    "has_expired": false
  }
}
```

### Error handling

- `401` → existing session handling.
- `403` → not the student's attempt (programming error; show generic quiz error).
- `404` question not in attempt → programming error; log + generic error.
- `422` already submitted → fetch attempt, show result.
- `422` attempt time over → show time up, fetch attempt.
- `422` question not opened → call `start` for the question, retry once.
- `422` question time over → mark question locked, keep saved answer, do not retry.

---

## 5. Files to change / add

### Data layer

| File | Change |
|---|---|
| `lib/core/constants/api_endpoints.dart` | Add `quizAttemptQuestionStart(...)` and `quizAttemptAnswers(...)` |
| `lib/features/lesson_test/data/models/question_timer_model.dart` | **New** immutable model |
| `lib/features/lesson_test/data/models/question_start_model.dart` | **New** start response model |
| `lib/features/lesson_test/data/models/quiz_save_result_model.dart` | **New** save response model |
| `lib/features/lesson_test/data/models/test_question_model.dart` | Parse `timer`, top-level `default_time_seconds` fallback |
| `lib/features/lesson_test/data/models/quiz_attempt_model.dart` | Parse `server_now`, `question_timing_enabled` |
| `lib/features/lesson_test/data/data_source/lesson_test_data_source.dart` | `startQuestion`, `saveAnswers` |
| `lib/features/lesson_test/data/repos/lesson_test_repo.dart` | Delegate new methods |
| `lib/features/lesson_test/data/quiz_error_mapper.dart` | Map new 422 reasons |

### Presentation layer

| File | Change |
|---|---|
| `lib/features/lesson_test/presentation/cubit/lesson_test_state.dart` | Timer map, locked/opened sets, clock offset, save queue |
| `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart` | Open question, tick, remote save, submit flush, resume |
| `lib/features/lesson_test/presentation/refactor/lesson_test_question_body.dart` | Locked banner + disabled content |
| `lib/features/lesson_test/presentation/refactor/test_question_view.dart` | Pass `enabled`/locked state |
| `lib/features/lesson_test/presentation/widgets/test_question_prompt.dart` | Urgent/locked timer styling, "time over" state |
| `lib/features/lesson_test/presentation/widgets/question_locked_banner.dart` | **New** small dumb banner |
| `lib/features/lesson_test/presentation/screens/lesson_test_screen.dart` | Re-open current question on `resumed` |

### Localization

| File | Change |
|---|---|
| `lib/core/localization/lang_keys.dart` | New constants |
| `assets/translations/en.json` | New keys |
| `assets/translations/ar.json` | New keys (Arabic primary) |

### Tests

| File | Change |
|---|---|
| `test/features/lesson_test/lesson_test_cubit_test.dart` | New timer/open/save tests + extend fake repo |
| `test/features/lesson_test/quiz_models_test.dart` | Parse `timer`, `server_now` |
| `test/features/lesson_test/quiz_error_mapper_test.dart` | New 422 reason mappings |

---

## 6. Model design

### `QuestionTimerModel`

```dart
class QuestionTimerModel {
  const QuestionTimerModel({
    this.enabled = false,
    this.startedAt,
    this.expiresAt,
    this.secondsLeft,
    this.hasExpired = false,
    this.canAnswer = false,
  });

  final bool enabled;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final int? secondsLeft;
  final bool hasExpired;
  final bool canAnswer;

  bool get isTimed => enabled && expiresAt != null;

  factory QuestionTimerModel.fromJson(Map<String, dynamic> json) =>
      QuestionTimerModel(
        enabled: Json.asBool(json['enabled']),
        startedAt: Json.asDateTime(json['started_at']),
        expiresAt: Json.asDateTime(json['expires_at']),
        secondsLeft: Json.asOptionalInt(json['seconds_left']),
        hasExpired: Json.asBool(json['has_expired']),
        canAnswer: Json.asBool(json['can_answer']),
      );

  QuestionTimerModel copyWith({
    bool? enabled,
    DateTime? startedAt,
    DateTime? expiresAt,
    int? secondsLeft,
    bool? hasExpired,
    bool? canAnswer,
  }) => ...;
}
```

`expires_at` is the only source used for the countdown. `seconds_left` is only used for a one-time
correction when a response arrives.

### `QuestionStartModel`

```dart
class QuestionStartModel {
  const QuestionStartModel({
    required this.attemptId,
    required this.questionId,
    required this.serverNow,
    required this.timer,
    this.attemptExpiresAt,
    this.savedAnswer,
  });

  final int attemptId;
  final String questionId;      // keep the app's string ids for keys
  final DateTime serverNow;
  final DateTime? attemptExpiresAt;
  final QuestionTimerModel timer;
  final Map<String, dynamic>? savedAnswer;

  factory QuestionStartModel.fromJson(Map<String, dynamic> json) => ...;
}
```

### `QuizSaveResultModel`

```dart
class QuizSaveResultModel {
  const QuizSaveResultModel({
    required this.attemptId,
    required this.saved,
    required this.ignoredQuestionIds,
    required this.serverNow,
    this.expiresAt,
    this.secondsLeft,
    this.hasExpired = false,
  });
  ...
}
```

### `TestQuestionModel`

- Keep `timeLimit` for backwards compatibility but read the fallback:
  `Json.asDuration(options['default_time_seconds'] ?? json['default_time_seconds'])`.
- Add `final QuestionTimerModel? initialTimer;` parsed from `json['timer']`.
- Do **not** mutate the model when the timer ticks; the cubit keeps a separate timer map.

### `QuizAttemptModel`

- Add `final DateTime? serverNow;` from `json['server_now']`.
- Add `final bool questionTimingEnabled;` from `json['question_timing_enabled']` (default `true`
  for attempts created after this feature; `false` disables per-question locking).
- Add getter/helper that builds the initial timer map:

```dart
Map<String, QuestionTimerModel> get questionTimers => {
  for (final q in questions)
    if (q.initialTimer != null) q.id: q.initialTimer!,
};
```

---

## 7. Cubit design

### 7.1 State additions (`lesson_test_state.dart`)

```dart
const LessonTestState({
  ...
  this.questionTimers = const <String, QuestionTimerModel>{},
  this.openedQuestionIds = const <String>{},
  this.lockedQuestionIds = const <String>{},
  this.openingQuestionId,
  this.clockOffset = Duration.zero,
  this.isSavingRemote = false,
});

final Map<String, QuestionTimerModel> questionTimers;
final Set<String> openedQuestionIds;
final Set<String> lockedQuestionIds;
final String? openingQuestionId;
final Duration clockOffset; // serverNow - deviceNow, applied to all comparisons
final bool isSavingRemote;
```

Getters:

```dart
DateTime get serverNow => DateTime.now().add(clockOffset);

QuestionTimerModel? get currentQuestionTimer =>
    questionTimers[currentQuestion?.id];

Duration? get currentQuestionRemaining {
  final timer = currentQuestionTimer;
  if (timer == null || !timer.isTimed || timer.hasExpired) {
    return timer?.hasExpired == true ? Duration.zero : null;
  }
  final left = timer.expiresAt!.difference(serverNow);
  return left.isNegative ? Duration.zero : left;
}

bool get isCurrentQuestionLocked {
  final timer = currentQuestionTimer;
  if (timer == null) return false;             // untimed question
  if (!timer.enabled) return false;            // no server timer
  if (!openedQuestionIds.contains(currentQuestion?.id)) return timer.isTimed;
  return timer.hasExpired || !timer.canAnswer;
}
```

Remove (or deprecate) `questionStartedAt` and the old `questionRemaining` getter after migration.

`copyWith` must support clearing `openingQuestionId` and replacing the timer map.

### 7.2 Open a question — `Future<void> openQuestion(int index)`

Called:

- After `startAttempt` succeeds (index 0).
- On `goNext` / `goPrevious`.
- On app `resumed` for the current index.
- On a save 422 "not opened" retry.

Pseudo-flow:

```
question = questions[index]
if not running or question == null: return
if openingQuestionId == question.id: return
if questionTimingEnabled == false: mark opened, no start call (old attempts)

emit(openingQuestionId = question.id)

try:
  result = await repo.startQuestion(attempt.id, question.id)
  emit clockOffset = result.serverNow - DateTime.now()
  emit questionTimers[question.id] = result.timer
  emit openedQuestionIds += question.id
  if result.attemptExpiresAt != null:
      attempt = attempt.copyWith(expiresAt: result.attemptExpiresAt)
      remaining = corrected remaining
  if result.timer.hasExpired || !result.timer.canAnswer && result.timer.enabled:
      lockedQuestionIds += question.id
  if result.savedAnswer != null:
      // Server is authoritative for the saved answer.
      // If the local answer is touched and the question is still open,
      // re-save the local answer shortly after so it wins on the server.
      hydrate answer from savedAnswer
      if localTouched && timer.canAnswer: enqueue remote save for question
  emit openingQuestionId = null

on AppException:
  emit openingQuestionId = null
  if already submitted -> fetch attempt / emit result
  if attempt expired -> didTimeOut = true, submit(timedOut: true)
  else -> messageKey = quizQuestionOpenFailed
```

Do **not** reset any timer on navigation. Expired timers remain expired.

### 7.3 Ticker (`_tick`)

Keep one periodic 1s ticker. On each tick:

1. Recompute total remaining from `attempt.expiresAt` using `state.serverNow`. If `<= 0` and not
   already timed out → `didTimeOut = true`, `submit(timedOut: true)` (existing behavior).
2. For every timer in `questionTimers` with `isTimed` and not expired:
   - if `expiresAt <= serverNow` → mark `hasExpired = true`, `canAnswer = false`, add to
     `lockedQuestionIds`.
3. Emit once with incremented `questionTick` so the UI rebuilds.

When the **current** question becomes locked, set `messageKey = LangKeys.quizQuestionTimeUp` once
(track a `Set<String> _notifiedLocked` in the cubit or emit only on transition).

Important: per-question expiry must **not** submit the whole quiz; only total expiry does.

### 7.4 Remote answer saving — Phase 0

Replace the local-only `_persistAnswers` with two layers:

- Local cache: keep the current `LessonTestLocalDataSource` write (fast, offline safety).
- Remote save: new `_pendingRemoteSaves: Map<String, Map<String, dynamic>?>` +
  `_remoteSaveTimer`.

On `_emitAnswer`:

```
_pendingRemoteSaves[question.id] = answer.toSubmissionJson(question)
local cache write (debounced ~350ms, existing)
remote flush (debounced ~1200ms, per spec "بعد تأخير ثانية أو ثانيتين")
```

`_flushRemoteSaves()`:

```
if pending empty or not running: return
payload = Map.of(pending)
revision = _saveRevision
try:
  result = await repo.saveAnswers(attempt.id, payload)
  update clockOffset from result.serverNow
  update attempt expiry / remaining from result
  for id in result.ignoredQuestionIds:
      lockedQuestionIds += id
      questionTimers[id] = timer.copyWith(canAnswer: false)
  remove only entries whose current pending value still equals payload[id]
  emit saveStatus = saved, isSavingRemote = false
catch AppException e:
  handle 401 / already submitted / attempt expired (stop saving)
  422 question not opened -> start that question, retry once next flush
  422 question expired -> lock those ids, drop them from pending
  otherwise keep pending and emit saveStatus = failed (retry on next change / before submit)
```

- Never block typing on a save.
- `flushAnswers()` (called on app pause) must call `_flushRemoteSaves()` too, best effort.
- Before `submit()`, `await _flushRemoteSaves()` with a short timeout, then submit all current
  answers (server ignores answers of expired questions and grades the saved ones).

Payload format per question is exactly what `TestAnswerModel.toSubmissionJson(question)` already
produces (`option_id`, `option_ids`, `boolean`, `blanks`, `matches`, `order`). Use `null` to clear
an answer if a clear action is added (for now the app has no "clear answer" action).
Note: `toSubmissionJson` runs strict validation. For partial saves it is safe for blanks/matches,
but for ordering the app already seeds the full order. Keep validation; if it throws for a
partial state, skip the remote save for that question rather than failing the UI.

### 7.5 Navigation

```dart
void goNext() {
  ...
  _moveTo(state.currentIndex + 1);
}

void _moveTo(int index) {
  emit(state.copyWith(
    currentIndex: index,
    questionTick: 0,
    clearSelectedBlank: true,
    clearSelectedPrompt: true,
  ));
  unawaited(openQuestion(index)); // no timer reset
}
```

Remove `questionStartedAt: DateTime.now()` from `_moveTo`.

### 7.6 Start attempt / resume

In `startAttempt` after receiving the attempt:

```
clockOffset = attempt.serverNow == null ? 0 : attempt.serverNow - DateTime.now()
questionTimers = restored from attempt.questions[].initialTimer
opened/locked derived from initial timers:
  - enabled && hasExpired -> locked
  - started_at != null -> opened
answers = _restoredAnswers(attempt)   // existing
emit running
_startTicker()
unawaited(openQuestion(0))
```

Resume (app reopened mid-attempt): `POST /attempts` returns the same open attempt with
`saved_answers` and per-question `timer`, so the above already restores timers. Then `openQuestion`
calls `start` and refreshes the current question.

### 7.7 Lifecycle

In `lesson_test_screen.dart`:

```dart
if (state == AppLifecycleState.resumed && cubit.state.isRunning) {
  unawaited(cubit.reopenCurrentQuestion());
}
```

`reopenCurrentQuestion()` = `openQuestion(state.currentIndex)`. This is what makes the countdown
correct after the app was in the background, and locks the question if it expired meanwhile.

---

## 8. UI changes

### Question body

`lesson_test_question_body.dart`:

```dart
final bool locked = state.isCurrentQuestionLocked;
final bool opening = state.openingQuestionId == question.id;

Column(
  children: [
    TestProgressHeader(...),
    if (opening) const LinearProgressIndicator(),
    if (locked) const QuestionLockedBanner(),
    Expanded(
      child: SingleChildScrollView(
        child: IgnorePointer(
          ignoring: locked,
          child: Opacity(
            opacity: locked ? 0.55 : 1,
            child: TestQuestionView(...),
          ),
        ),
      ),
    ),
    TestNavButtons(...), // navigation stays enabled
  ],
)
```

`QuestionLockedBanner` (new, ~20 lines):
- icon `Icons.lock_clock_outlined`
- text `LangKeys.quizQuestionTimeUp.tr()`
- optional subtitle `LangKeys.quizQuestionLockedHint.tr()`
- colors from `Theme.of(context).colorScheme`.

Also call `FocusManager.instance.primaryFocus?.unfocus()` when a typed-blank question becomes
locked so the keyboard does not stay open.

### Timer chip

`test_question_prompt.dart` + `test_timer_chip.dart`:
- Show `state.currentQuestionRemaining` instead of the local `questionRemaining`.
- When remaining `<= 10s`: use `colorScheme.error` for the chip.
- When locked: show the chip with label from `quizQuestionTimeUp`.
- Do not show a question timer when the timer is `enabled == false`.

### Options

`TestQuestionView` already forwards `onSelect` etc. The `IgnorePointer` wrapper is enough to block
all question interactions. Add `Semantics(enabled: !locked)` if accessibility matters.

### Save status

Reuse the existing `quiz_saving` / `quiz_saved` / `quiz_save_failed` keys; the header already
renders `saveStatus`. Set `saveStatus = saving` on every answer change and after a successful PUT
set `saved`.

---

## 9. Localization keys

Add to `assets/translations/en.json` and `assets/translations/ar.json`, and constants in
`lib/core/localization/lang_keys.dart`:

| Key | English | Arabic |
|---|---|---|
| `quiz_question_time_up` | Question time is over | انتهى وقت هذا السؤال |
| `quiz_question_locked_hint` | Your saved answer will be graded | إجابتك المحفوظة قبل انتهاء الوقت هي التي تُحتسب |
| `quiz_question_open_failed` | Could not open the question. Please try again | تعذّر فتح السؤال. أعد المحاولة |
| `quiz_question_not_opened` | Open the question before answering | يجب فتح السؤال قبل الإجابة |
| `quiz_question_loading` | Opening question... | جارٍ فتح السؤال... |

Error-mapper keys (same names) must also be in `QuizErrorMapper._stableKeys` so they are not
remapped to generic values:

- `quiz_question_time_up`
- `quiz_question_open_failed`
- `quiz_question_not_opened`

---

## 10. Behavior matrix to verify

| Case | Expected |
|---|---|
| Untimed question | No timer chip; answers save normally; no `lock` |
| Timed question, first display | `start` called once; chip counts down from server remaining |
| Answer within time | Local + remote save; save status shows saved |
| Move to next question | Previous timer keeps counting; no stop call |
| Return after 5s | `start` returns lower `seconds_left`; chip resumes at that value |
| Return after expiry | Question locked; saved answer shown; inputs disabled |
| App backgrounded past expiry | On resume `start` returns expired; question locked |
| Total timer expires | Existing timedOut → submit; no per-question submission |
| Save fails (network) | Keep pending; status failed; retry on next change and before submit |
| Save returns `ignored_question_ids` | Those questions locked, no retry loop |
| Resume an open attempt | `saved_answers` + `timer` restored from `POST /attempts` |
| Old attempt (`question_timing_enabled == false`) | No per-question locking, no timer UI |

---

## 11. Edge cases / decisions

1. **Race on fast navigation.** Key all timer/saved-answer updates by `question.id`; do not assume
   the response belongs to the currently visible question.
2. **Duplicate `start` calls.** Guard with `openingQuestionId` and `openedQuestionIds`. Returning
   to a question must call `start` again (spec), so do not skip based on `openedQuestionIds`; only
   guard concurrent duplicates.
3. **Saved answer vs local cache.** Server `saved_answer` is authoritative when the question is
   locked. When the question is still open and the local cache has a touched answer, keep the
   local answer and immediately enqueue a remote save so the server catches up.
4. **404 on `start`.** Programming error (`question_id` not from `answers[]`); show
   `quiz_question_open_failed`, do not lock the question forever.
5. **Clock skew.** Apply one shared `clockOffset` derived from the latest `server_now`. Use it for
   both total and per-question timers.
6. **No simulated progress.** Do not count down from `default_time_seconds`; always use
   `expires_at - serverNow`.
7. **No auto-advance.** The spec only says "lock the question"; do not jump to the next question.
8. **Submit payload.** Send all current answers. The server ignores expired/unopened ones and
   grades what was saved before expiry. Never send a time value.

---

## 12. Implementation order

### Phase 0 — Remote answer saving (prerequisite)

1. `api_endpoints.dart`: add `quizAttemptAnswers(attemptId)`.
2. `quiz_save_result_model.dart`.
3. `LessonTestDataSource.saveAnswers` + `LessonTestRepo.saveAnswers`.
4. Cubit: `_pendingRemoteSaves`, debounce ~1200ms, `_flushRemoteSaves`, extend `flushAnswers`.
5. Tests for payload shape and retry behavior.

### Phase 1 — Models & contract

6. `question_timer_model.dart`, `question_start_model.dart`.
7. Update `TestQuestionModel` (`timer`, `default_time_seconds` fallback).
8. Update `QuizAttemptModel` (`server_now`, `question_timing_enabled`, timer map helper).
9. `api_endpoints.dart`: add `quizAttemptQuestionStart(...)`.
10. `LessonTestDataSource.startQuestion` + `LessonTestRepo.startQuestion`.
11. `QuizErrorMapper` new reasons.
12. Model + mapper tests.

### Phase 2 — Cubit

13. State fields + getters + `copyWith`.
14. `clockOffset` in `startAttempt`.
15. `openQuestion` + calls from `startAttempt`, `_moveTo`, resume.
16. `_tick` per-question expiry only (no submission).
17. Remove the local `questionStartedAt` reset logic.

### Phase 3 — UI

18. `QuestionLockedBanner`.
19. `lesson_test_question_body` locked/opening rendering.
20. `test_question_prompt` urgent/locked timer + no timer when disabled.
21. `lesson_test_screen` resume hook.

### Phase 4 — Localization & tests

22. Add 5 keys to `en.json`, `ar.json`, `LangKeys`.
23. Extend `_FakeRepo` in `lesson_test_cubit_test.dart` with `startQuestion` / `saveAnswers`.
24. Add tests listed below.
25. Run `flutter analyze` and `flutter test test/features/lesson_test`.

---

## 13. Test plan

Cubit tests (`test/features/lesson_test/lesson_test_cubit_test.dart`):

1. `startAttempt` calls `startQuestion` for question 0 and stores its timer.
2. `goNext` / `goPrevious` call `startQuestion` and do **not** reset the previous timer.
3. Server timer expiry sets `isCurrentQuestionLocked` and blocks `selectOption`.
4. Returning to a question hydrates `saved_answer`.
5. Changing an answer calls `saveAnswers` with `{'<id>': {...}}` after the debounce.
6. A failed save keeps the answer and retries before submit.
7. `ignored_question_ids` locks the question and drops it from pending.
8. `server_now` adjusts the countdown (clock offset), not `default_time_seconds`.
9. Expired `start` response locks the question without submitting the quiz.
10. Total timer expiry still submits once (existing test).
11. `question_timing_enabled == false` leaves questions unlocked.

Model tests (`quiz_models_test.dart`): parse `timer`, `server_now`,
`question_timing_enabled`, top-level `default_time_seconds`, `saved_answer`.

Mapper tests (`quiz_error_mapper_test.dart`): Arabic and English 422 reasons map to the new keys.

Verification commands:

```powershell
flutter analyze
flutter test test/features/lesson_test
```

---

## 14. Acceptance criteria

- [x] Every displayed question triggers `POST .../questions/{id}/start` before answers are accepted.
- [x] Countdown is derived from `timer.expires_at` corrected by `server_now`; never from
      `default_time_seconds`.
- [x] Navigating away does not stop or reset any question timer.
- [x] Returning calls `start` again, shows the lower remaining time and restores `saved_answer`.
- [x] Expired question is visually locked, inputs disabled, saved answer still visible.
- [x] Answers are sent to `PUT .../answers` shortly after each edit and retried on failure.
- [x] Submit flushes pending saves then submits the current answers.
- [x] App resume reopens the current question and reflects expiry that happened in the background.
- [x] Old attempts (`question_timing_enabled == false`) behave exactly as before.
- [x] All new UI text uses `LangKeys` and exists in both `ar.json` and `en.json`.
- [x] `flutter analyze` reports no new issues and the lesson_test test suite passes.

---

## 15. Confirmed decisions

1. **Backend is live.** `POST .../questions/{questionId}/start` and `PUT .../answers` are deployed
   on `bilhikma.tech` and use `status_code == 1` like the rest of the API.
2. **Phase 0 is in scope.** Remote answer saving (`PUT .../answers`) ships together with this
   task. It is a hard prerequisite for correct grading of expired questions.

## 16. Remaining assumptions

1. **`question_id` type.** The app keeps string ids; the server example uses integers. Conversion
   in the endpoint helper is `'$attemptId/questions/$questionId/start'`.
2. **Question `timer` field naming.** Assumed exactly as in section 6.10 (`timer.enabled`,
   `started_at`, `expires_at`, `seconds_left`, `has_expired`, `can_answer`).
3. **Calling `start` for untimed questions.** The spec says "افتح كل سؤال عند السيرفر قبل عرضه".
   The plan calls `start` for every question (including untimed) because it also returns
   `saved_answer`; if the backend rejects untimed starts, fall back to calling it only when
   `default_time_seconds != null`.

---

## 17. Implementation status

Implemented. No `build_runner` step is required (no generated code changed).

Verification:

- `flutter analyze`: 11 pre-existing warnings/infos in unrelated files, none in `lesson_test`.
- `flutter test test/features/lesson_test`: **92 tests passed**.

Key files:

- `lib/core/constants/api_endpoints.dart`
- `lib/features/lesson_test/data/models/question_timer_model.dart`
- `lib/features/lesson_test/data/models/question_start_model.dart`
- `lib/features/lesson_test/data/models/quiz_save_result_model.dart`
- `lib/features/lesson_test/data/models/test_question_model.dart`
- `lib/features/lesson_test/data/models/quiz_attempt_model.dart`
- `lib/features/lesson_test/data/data_source/lesson_test_data_source.dart`
- `lib/features/lesson_test/data/repos/lesson_test_repo.dart`
- `lib/features/lesson_test/data/quiz_error_mapper.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_state.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart`
- `lib/features/lesson_test/presentation/refactor/lesson_test_question_body.dart`
- `lib/features/lesson_test/presentation/widgets/question_locked_banner.dart`
- `lib/features/lesson_test/presentation/widgets/test_timer_chip.dart`
- `lib/features/lesson_test/presentation/widgets/test_question_prompt.dart`
- `lib/features/lesson_test/presentation/screens/lesson_test_screen.dart`
- `lib/core/localization/lang_keys.dart`
- `assets/translations/ar.json`, `assets/translations/en.json`
- `test/features/lesson_test/lesson_test_cubit_test.dart`
- `test/features/lesson_test/quiz_models_test.dart`
- `test/features/lesson_test/quiz_error_mapper_test.dart`

Remaining manual check (needs a real account/device): start a timed attempt, background the app
past a question's deadline, resume, and confirm the question opens locked with the saved answer.
