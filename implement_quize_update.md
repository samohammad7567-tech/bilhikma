# Quiz Update Plan — Autosave, Grace Submit, Auto-Submit, and `quiz_result`

**Status:** plan only. Do not implement code from this document in the same turn.

**Baseline:** `implement_quize.md` (already largely implemented) plus the current
`lib/features/lesson_test` code.

**Source of truth:** backend guide
`https://bilhikma.tech/guides/11a59d713e63542b/` — section **6 «حفظ الإجابات والتسليم»**
(anchor `#s20`), read on 2026-11-03. Where this document and `implement_quize.md`
disagree, **this document wins**.

**Scope:** student/mobile only. No admin, question-bank, publishing, monitoring, or
teacher-review screens.

---

## 0. Execution Contract

1. Work one phase at a time; do not mix model changes with UI changes.
2. Keep the existing `lesson_test` feature and migrate it. Do not create a second quiz
   feature and do not fork the Cubit.
3. Never grade on the client. Never derive pass/fail or percentages locally.
4. Cubit owns saving, retrying, timer calibration, submission, and result polling.
5. Data source owns the PUT/GET/POST calls and maps errors to stable keys.
6. No `BuildContext`, navigation, or localization inside the Cubit.
7. Add every new string to `assets/translations/ar.json` **and**
   `assets/translations/en.json` plus `lib/core/localization/lang_keys.dart`.
8. After each phase: `flutter analyze` and `flutter test`.
9. `build_runner` is **not** required (no generated models in this change).
10. Do not invent a new HTTP dependency. `ApiClient.put` and `ApiClient.getObject`
    already exist (`lib/core/network/api_client.dart`).
11. Preserve `ApiClient(endSessionOnForbidden: false)` for all quiz traffic.

---

## 1. What Changed — Delta Summary

| Area | `implement_quize.md` / current code | New backend behavior |
|---|---|---|
| Answer durability | Answers exist only in memory until submit | Every answer must be autosaved with `PUT /user/quiz-attempts/{id}/answers` |
| Save semantics | Not present | Merge, not replace. Send only changed question(s). `null` clears one answer. One or many entries per request |
| Save cadence | Not present | Debounce 1–2 s after the last edit; flush on question change, submit, app background, and reconnect |
| Resume | Start returns the same attempt | Start/fetch returns `saved_answers`; hydrate local answers from it |
| Attempt fetch | Only `my-attempts` list | New `GET /user/quiz-attempts/{attemptId}` |
| Clock | Local `DateTime.now()` vs `expires_at` | Calibrate from `server_now`; recalibrate from every save response and `seconds_left` |
| Submit window | Client blocks/zeroes at `expires_at` | Server accepts submit up to **15 s after** `expires_at`; after that it returns 200 but ignores sent answers and grades saved ones |
| Server auto-submit | None | 15 s after expiry, server submits automatically (timed quizzes, attempts from the last 6 h) |
| New field | None | `auto_submitted` on the attempt |
| Timeout UX | Show `test_time_up` and `pop()` back | Stay on the quiz, submit, then show result or an “awaiting result” state; never pop |
| Leaving | `submitAndLeave()` submits on leave | Leaving must **not** submit. Flush, then leave; the attempt stays open and resumable |
| Result delivery | Only inline after submit | `quiz_result` push (`action=open_quiz_result`) that deep-links to the result by `attempt_id` |
| Pending state | `review_status == pending` only | Two distinct states: **under correction** (`submitted_at == null && has_expired == true`) and **pending review** (`review_status == pending`) |
| Empty submit | Not specified | `{"answers": {}}` or all-`null` answers is valid and scores 0 |

---

## 2. New Server Contract

### 2.1 Endpoints

| Purpose | Method | Path | Success |
|---|---|---|---|
| Start or resume | `POST` | `/user/quizzes/{quizId}/attempts` | `201` |
| Autosave answer(s) | `PUT` | `/user/quiz-attempts/{attemptId}/answers` | `200` |
| Fetch one attempt | `GET` | `/user/quiz-attempts/{attemptId}` | `200` |
| Submit | `POST` | `/user/quiz-attempts/{attemptId}/submit` | `200` |
| Attempt history (fallback only) | `GET` | `/user/quizzes/{quizId}/my-attempts` | `200` |

`my-attempts` is no longer the primary reconciliation path; use the single-attempt
endpoint.

### 2.2 Autosave request

```json
{
  "answers": {
    "21": { "option_id": "o_1" },
    "23": { "boolean": false },
    "22": null
  }
}
```

Rules:

- The key is the **question ID as a string**, exactly as received in `answers[]`.
- One or many questions per request; server merges.
- Send **only** questions that changed since the last successful save.
- `null` deletes/clears a saved answer for that question.
- The per-question value uses the same matrix as submit (`implement_quize.md` §1.5):
  - `single` / `best_answer`: `{ "option_id": "..." }`
  - `multi`: `{ "option_ids": ["...", "..."] }` (never above `max_selections`)
  - `true_false`: `{ "boolean": true|false }` (a real JSON boolean)
  - `fill_blank` / `typed_blank`: `{ "blanks": { "<blankId>": "<value>" } }`
    (partial blanks allowed)
  - `matching`: `{ "matches": { "<rightId>": "<leftId>" } }`
  - `ordering`: `{ "order": ["...", "..."] }` (complete list, server order otherwise)
- A question that becomes unanswered (toggled off, blank cleared, pair cleared) must
  be sent as `null`, not omitted.

### 2.3 Autosave response

```json
{
  "message": "تم حفظ الإجابات.",
  "status_code": 1,
  "data": {
    "attempt_id": 84,
    "saved": 2,
    "expires_at": "2026-11-03T10:29:45+00:00",
    "server_now": "2026-11-03T10:28:45+00:00",
    "seconds_left": 60,
    "has_expired": false
  }
}
```

- `saved`: number of answers accepted in this request.
- `expires_at`: `null` for untimed quizzes.
- `seconds_left`: `0` at expiry; `null` for untimed quizzes.
- `has_expired: true`: the attempt is over. Stop autosave immediately.
- `server_now`: authoritative clock used to correct the local countdown.

### 2.4 Resume / fetch attempt

`POST /user/quizzes/{quizId}/attempts` returns the open attempt (or the submitted one
when no open attempt remains). Responses now include:

- `server_now` (ISO)
- `auto_submitted` (bool, default `false`)
- `saved_answers` — present **only while unsubmitted**, shape:
  `{ "<questionId>": <answer payload> }`, `{}` when nothing was saved.

`GET /user/quiz-attempts/{attemptId}` returns the full attempt with the same fields.
While unsubmitted, `saved_answers` is included; `submitted_at` is `null`.

### 2.5 Grace submit and server auto-submit

- `POST .../submit` is accepted until `expires_at + 15 s`.
- After `expires_at + 15 s` the server returns `200` but **ignores the sent `answers`**
  and grades only the saved answers.
- Server auto-submits 15 s after `expires_at` for **timed quizzes only**, completing
  within roughly 1 m 15 s, and only for attempts from the last 6 hours.
- Untimed quizzes never auto-submit. An abandoned untimed attempt stays open until the
  student starts a new attempt; the old one is then closed with score 0.
- An empty payload (`{}` / all-`null`) is valid and scores 0.

### 2.6 `quiz_result` notification

- Kind/type: `quiz_result`
- `data`:

```json
{
  "action": "open_quiz_result",
  "attempt_id": "84",
  "quiz_id": "2",
  "content_id": "179",
  "auto_submitted": "1",
  "notification_id": "1680"
}
```

Routing:

1. `action == open_quiz_result` and `attempt_id > 0` → result screen for that attempt.
2. If the attempt cannot be loaded → lesson detail using `content_id`.
3. If neither exists → notifications list.

Deduplicate: if the result screen for that `attempt_id` is already on top, do not push
another copy.

### 2.7 Save error mapping

| Status | Meaning | Required behavior |
|---|---|---|
| `400` | Malformed JSON | App bug. Keep the dirty answer, log, retry once, then show `quiz_answers_invalid` |
| `401` | Unauthenticated | Normal refresh flow. On persistent 401, stop saving and surface the session error |
| `403` | Not the student’s attempt | Stop autosave, show `quiz_unavailable`, do not start a new attempt automatically |
| `422` already submitted | Attempt submitted (often by the server) | Stop autosave → `GET attempt` → show result |
| `422` expired | Attempt time is over | Stop autosave → `GET attempt` → show “awaiting result” or result |
| `422` field errors | Invalid answer shape | App bug. Keep the dirty answer, show `quiz_answers_invalid`, do not discard it |
| `5xx` / network | Transient | Keep the dirty answer; retry with backoff while the attempt is live |

On server auto-submit the `quiz_result` push is a **secondary** channel. The app must
also poll the attempt when it knows the time is up, because notifications may be
disabled.

---

## 3. Sections Superseded in `implement_quize.md`

Mark these sections as superseded by this document when implementing:

| Section | Change |
|---|---|
| §1.1 | Add `PUT .../answers` and `GET /user/quiz-attempts/{attemptId}` |
| §1.4 | Attempt response adds `saved_answers`, `auto_submitted`, `server_now` |
| §1.7 | Add autosave, 15 s grace, auto-submit, leave-without-submit |
| §4.9 | `QuizAttemptModel` gains `serverNow`, `autoSubmitted`, `savedAnswers`, `copyWith` |
| §5.1 | Add `saveAnswer`, `fetchAttempt` |
| §5.2 | Add 422-expired and 400 mapping |
| §6.4 | Refresh after return must also account for a still-open, autosaved attempt |
| §7.1 | Add saving state, server offset, awaiting-result state |
| §7.5 | Timer uses calibrated server time; no submit-and-pop; no zeroing at `expires_at` |
| §7.6 | Timeout shares the grace window; 422-expired reconciliation; never clear dirty answers |
| §7.7 | Result may be “under correction”; add auto-submitted note |
| §8.2 | Start dialog copy: the attempt stays open/resumable; it is not submitted on exit |
| §8.9 | Add awaiting-result body and auto-submitted note |
| §8.11 | Replace `submitAndLeave` with flush-and-leave; leaving never submits |
| §9.1 / §9.3 | New keys and error rows |
| §10.3 / §10.5 | Autosave, grace, auto-submit, notification tests |
| §11 | New acceptance criteria |

---

## 4. Phase 1 — Endpoints and Models

### 4.1 `ApiEndpoints`

Add:

```dart
static String quizAttempt(int attemptId) => '/user/quiz-attempts/$attemptId';

static String quizAttemptAnswers(int attemptId) =>
    '/user/quiz-attempts/$attemptId/answers';
```

Keep the existing `quizAttemptSubmit` and `quizAttempts`.

### 4.2 `QuizSaveResultModel` (new)

`lib/features/lesson_test/data/models/quiz_save_result_model.dart`

```text
attemptId       int
saved           int
expiresAt       DateTime?
serverNow       DateTime?
secondsLeft     int?
hasExpired      bool
```

Parse from `envelope.dataMap`. Use `Json.asOptionalInt` for `seconds_left` because it
is `null` for untimed quizzes.

### 4.3 `QuizAttemptModel`

Add:

- `DateTime? serverNow`
- `bool autoSubmitted` (default `false`)
- `Map<String, Map<String, dynamic>> savedAnswers` (default `{}`)
- `QuizAttemptModel copyWith({...})` — needed to apply a save response’s
  `expires_at`/`server_now` to the live attempt without a refetch.

Parsing:

- `server_now` via `Json.asDateTime`
- `auto_submitted` via `Json.asBool`
- `saved_answers` via `Json.asMap` mapped to
  `Map<String, Map<String, dynamic>>` (skip non-map values)

Add getters:

```dart
bool get isAwaitingCorrection => submittedAt == null && serverHasExpired;

bool get canAcceptAutosave => !isSubmitted && !serverHasExpired;
```

Do not derive `isSubmitted` from `submitted_at` alone; keep the current
`serverIsSubmitted` fallback.

### 4.4 `TestAnswerModel`

Add:

```dart
factory TestAnswerModel.fromSavedJson(
  TestQuestionModel question,
  Map<String, dynamic> json,
)

Map<String, dynamic>? toSaveJson(TestQuestionModel question)
```

- `fromSavedJson` reads `option_id`, `option_ids`, `boolean`, `blanks`, `matches`,
  `order` into the existing fields. Ignore unknown keys. Trim nothing.
- `toSaveJson` returns `null` when `!isAnswered(question.type)` (except ordering,
  which is always answered); otherwise returns `toSubmissionJson(question)`.
- Keep `validateFor` for submit. For autosave, validate structure per question but do
  **not** require every blank/pair; partial answers are legal.
  - Add `toSaveJson` variants that validate only the IDs present.
  - Ordering still requires the complete list.

### 4.5 `LessonTestModel`

No structural change required. Confirm `timeLimitMinutes == null` means untimed and is
used only for the intro row.

---

## 5. Phase 2 — Data Source, Repo, Errors

### 5.1 `LessonTestDataSource`

```dart
Future<QuizSaveResultModel> saveAnswers(
  int attemptId,
  Map<String, dynamic> answers,
) async {
  final ApiEnvelope envelope = await client.put(
    ApiEndpoints.quizAttemptAnswers(attemptId),
    data: <String, dynamic>{'answers': answers},
  );
  return QuizSaveResultModel.fromJson(envelope.dataMap);
}

Future<QuizAttemptModel> fetchAttempt(int attemptId) =>
    client.getObject<QuizAttemptModel>(
      ApiEndpoints.quizAttempt(attemptId),
      QuizAttemptModel.fromJson,
    );
```

- Wrap both with `QuizErrorMapper.translate`.
- `FormatException` on save → `AppException('quiz_answers_invalid')`; on fetch →
  `AppException('quiz_unavailable')`.
- Keep `ApiClient(endSessionOnForbidden: false)`.

### 5.2 `LessonTestRepo`

Expose `saveAnswers` and `fetchAttempt` as thin delegates.

### 5.3 `QuizErrorMapper`

- Add `quiz_time_expired` and `quiz_attempt_not_found` to `_stableKeys`.
- `422`:
  - Already submitted → `quiz_already_submitted`.
  - Expired → `quiz_time_expired`. Detect via reason/message containing `expire`,
    `expired`, `time`, `وقت`, or `انتهى`, **and** prefer the attempt state when
    available at the call site.
  - Everything else → `quiz_answers_invalid`.
- `400` on save → `quiz_answers_invalid` (app bug).
- Ensure `403` never becomes `session_expired`.

Current code maps any 422 text containing “submit” to already-submitted. Keep that,
but check “expired/time” first so a localized “time is up” message does not get
misclassified.

---

## 6. Phase 3 — Cubit and State Machine

### 6.1 Status and state additions

```text
LessonTestStatus { initial, loading, ready, starting, running, submitting,
                   awaitingResult, result, failure }
```

Add to `LessonTestState`:

```text
Duration serverOffset          // serverNow - localNow, updated on every response
bool isSaving                  // PUT in flight
bool hasUnsavedChanges         // dirty questions exist
bool saveFailed                // last PUT terminally failed (403/422/401)
bool isTimeUp                  // local expires_at reached
String? saveErrorKey           // only for non-blocking toast/inline status
int savedCount                 // last successful save count (display only)
```

Computed:

```dart
DateTime get serverNow => DateTime.now().add(serverOffset);
bool get isAwaitingResult => status == LessonTestStatus.awaitingResult;
bool get canAutosave =>
    attempt != null && !attempt!.isSubmitted && !attempt!.serverHasExpired;
```

Keep `didTimeOut` for compatibility but stop using it to pop.

### 6.2 Save queue

Add private fields in `LessonTestCubit`:

```dart
Timer? _saveDebounce;
Timer? _saveRetry;
bool _saveInFlight = false;
bool _flushAgain = false;
final Map<String, int> _dirtyVersion = <String, int>{}; // questionId -> version
final Map<String, dynamic> _pendingSave = <String, dynamic>{}; // questionId -> json|null
int _versionSeq = 0;
```

`_emitAnswer` and the mutation methods additionally call:

```dart
void _markDirty(String questionId) {
  final TestQuestionModel? q = questionById(questionId);
  if (q == null) return;
  _dirtyVersion[questionId] = ++_versionSeq;
  _pendingSave[questionId] = state.answerOf(questionId).toSaveJson(q);
  _scheduleSave();
}
```

`_scheduleSave()`:

- Cancel `_saveDebounce`; restart with **1500 ms**.
- Emit the current state (do not rebuild answers) with `hasUnsavedChanges = true`,
  `saveFailed = false`, `isSaving = false`.

`flushAnswers({bool immediate = false})`:

1. If `!canAutosave` or `_pendingSave.isEmpty` → return.
2. If `_saveInFlight` → set `_flushAgain = true` and return.
3. Snapshot `_pendingSave` and `_dirtyVersion`.
4. Set `_saveInFlight = true`; emit `isSaving = true`.
5. `repo.saveAnswers(attempt.id, snapshot)`.
6. On success:
   - Remove from `_pendingSave`/`_dirtyVersion` only entries whose version still
     equals the snapshot version (newer edits must survive).
   - Update `state.attempt` via `copyWith(expiresAt: result.expiresAt,
     serverNow: result.serverNow)`.
   - Update `serverOffset = result.serverNow - DateTime.now()`.
   - If `result.hasExpired`: stop timers, emit `isTimeUp = true`, and call
     `submit(timedOut: true)` once.
   - Emit `isSaving = false`, `hasUnsavedChanges = _pendingSave.isNotEmpty`,
     `savedCount = result.saved`.
7. On failure:
   - Never clear `_pendingSave`.
   - `401`: keep dirty; stop retry; surface the session error.
   - `403`: `saveFailed = true`; stop autosave; show `quiz_unavailable`.
   - `422` already submitted / expired: `saveFailed = true`; stop autosave; call
     `_reconcileAttempt()`.
   - `400`/`422` field errors: keep dirty; show `quiz_answers_invalid`; retry once,
     then stop automatic retries.
   - Network/`5xx`: schedule retry with backoff (2 s, 4 s, 8 s, capped at 30 s) while
     `canAutosave`.
8. `finally`: `_saveInFlight = false`; if `_flushAgain`, clear it and call
   `flushAnswers()` again **after** emitting the latest state.

Triggers for immediate flush:

- `goNext`, `goPrevious`, `submit`, leave confirmation.
- App lifecycle `inactive`/`paused`/`detached` — the screen observes with
  `AppLifecycleListener` (or `WidgetsBindingObserver`) and calls
  `cubit.flushAnswers(immediate: true)`.
- Reconnect. If the project already has connectivity handling, hook it; otherwise the
  retry timer is sufficient and no new dependency is allowed.

Do **not** block answer selection on the network. The UI must remain responsive while
saving.

### 6.3 Resume hydration

In `startAttempt()` after building defaults:

1. `_applySavedAnswers(attempt.savedAnswers)`.
2. Ordering: apply saved `order` only when its length equals the question’s item count
   and all IDs are known; otherwise keep the server order.
3. Matching: apply saved `matches` as-is.
4. Choice/boolean/blanks: apply saved values directly.
5. Compute `serverOffset` from `attempt.serverNow` when present, else `Duration.zero`.
6. `remaining = expiresAt - serverNow` (clamped at zero).

Same helper is used by `_reconcileAttempt()` after `GET attempt`.

### 6.4 Timer with `server_now`

Replace `expiresAt.difference(DateTime.now())` with:

```dart
final Duration remaining =
    expiresAt.difference(state.serverNow);
```

Every save response and every attempt fetch updates `serverOffset`:

```dart
serverOffset = serverNow.difference(DateTime.now());
```

Recalibrate from `seconds_left` when `server_now` is missing:

```dart
serverOffset = expiresAt.subtract(Duration(seconds: secondsLeft))
    .difference(DateTime.now());
```

At `remaining <= 0`:

1. Emit `remaining = Duration.zero` and `isTimeUp = true`.
2. Stop autosave and the debounce/retry timers.
3. Call `submit(timedOut: true)` exactly once.
4. Do **not** pop and do **not** zero the local answers.
5. If there are unsaved answers, submit sends them; the server applies the 15 s grace.

### 6.5 Submission

`submit({bool timedOut = false})`:

1. Guard as today (`_submitRequested`, `isSubmitting`, `submitting`, `result`,
   `awaitingResult`).
2. `await flushAnswers(immediate: true)` when `_pendingSave.isNotEmpty`; if the flush
   hits `422 expired/already submitted`, go to `_reconcileAttempt()` and return.
3. Build the payload exactly as today (full local answers). Do not omit ordering.
4. `repo.submitAttempt(...)`.
5. Success → `_emitResult(result, timedOut: timedOut)`; stop everything; clear dirty
   maps.
6. `422 already submitted` → `_reconcileAttempt()`.
7. `422 expired` → `_reconcileAttempt()`; do not show `quiz_answers_invalid`.
8. `401` → normal session flow; keep dirty; stop retry timers.
9. `403` → `quiz_unavailable`; remain running; do not sign out.
10. Network / `5xx` → remain running, preserve answers, restart the ticker only while
    `remaining > 0`; keep the retry timer for autosave.
11. Never clear `_submitRequested` on success.
12. In `finally`, clear `isSubmitting`; clear `_submitRequested` only when no result
    was reached and a retry is allowed.

### 6.6 `_reconcileAttempt()`

Used by timeout, 422-expired, 422-already-submitted, and result recovery:

1. `repo.fetchAttempt(attemptId)`.
2. `_applySavedAnswers(attempt.savedAnswers)` (only if unsubmitted).
3. Update `serverOffset` and `remaining`.
4. If `attempt.isSubmitted` → `_emitResult(attempt)`.
5. Else if `attempt.isAwaitingCorrection` → status `awaitingResult`; start a poll timer
   every **3 s**, max 20 attempts (~60 s); each poll refetches and re-checks.
6. Else if `attempt.serverHasExpired` and still unsubmitted after grace → keep
   `awaitingResult` and allow manual “Refresh”.
7. Else → `quiz_time_expired` message and remain on the awaiting/time-up screen.
8. On fetch failure → status `awaitingResult` with `errorKey = quiz_unavailable` and a
   retry action (`_reconcileAttempt` again).

Polling belongs to the Cubit; the widget only renders the state and forwards “retry”.

### 6.7 Leaving

Replace `submitAndLeave()` with:

```dart
Future<bool> flushAndLeave() async
```

- `await flushAnswers(immediate: true)`; return `false` only when the data source
  reports a terminal error (401/403/422). Network failures still allow leaving: the
  pending answers stay dirty in memory, and the attempt remains resumable on the
  server with whatever was saved.
- Do **not** call `submit`.
- Emit `status = ready`? No — keep `running` until the screen pops; the screen is
  responsible for popping on `true`.

Rationale: leaving no longer consumes the attempt. For timed quizzes the attempt stays
open until `expires_at`; for untimed quizzes it stays open until a new attempt is
started.

### 6.8 Result-only mode (notifications)

Add a named constructor or a separate flag:

```dart
LessonTestCubit.resultOnly({required this.attemptId, this.repo = const LessonTestRepo()})
```

- `loadAttemptResult()`: fetch the attempt and emit `result`, or
  `awaitingResult`, or `failure`.
- Do not fetch the quiz overview and do not start an attempt.
- `lessonId` is optional in this mode and is used only for “Back to lesson”.

Keep a single Cubit class; add `int? attemptId` and branch in `load()`.

---

## 7. Phase 4 — UI Changes

### 7.1 Autosave indicator

Add a small status row/chip in the running header (not a full-screen overlay):

- `isSaving` → spinner + `quiz_saving`
- `saveFailed` → warning icon + `quiz_save_failed` + retry tap
- `hasUnsavedChanges` → `quiz_unsaved`
- otherwise → check icon + `quiz_saved`

Use existing `AppTheme` colors/typography; no ad-hoc values. It must not shift the
question layout (fixed-height row, `AnimatedSwitcher`).

### 7.2 Timer

- Render `remaining` from the Cubit (already calibrated).
- Do not compute `expiresAt - DateTime.now()` in the widget.
- When `isTimeUp`, replace the countdown with a static “time is up” label; do not hide
  the question immediately.

### 7.3 Time-up / awaiting result

Add to `LessonTestBody` a case for `awaitingResult`:

- Illustration/icon + `quiz_time_up_submitting` or `quiz_awaiting_result`.
- Indeterminate progress (no fake percentage).
- `quiz_result_pending_refresh` action button that calls `_reconcileAttempt`.
- If `errorKey != null`, show `AppErrorView` with retry.
- Never `Navigator.pop()` from the state listener on `didTimeOut`.

`LessonTestScreen._handleState`:

- Remove the `Navigator.of(context).pop()` for `didTimeOut`.
- Show a toast once, then let the body switch to `awaitingResult`.

### 7.4 Leave dialog and flow

- Update copy:
  - `quiz_leave_confirm_message`: “Your answers are saved automatically. You can leave
    now and resume this attempt before it expires.”
  - `quiz_leave_confirm_action`: “Leave”.
- On confirm: `flushAndLeave()`; pop only on `true`.
- `PopScope(canPop: !state.isRunning)` stays.
- While `isSubmitting` disable back/leave.
- After timeout, back should be allowed (the attempt is over) and should not submit.

### 7.5 Start dialog

Update copy to match autosave:

- “Starting now consumes one attempt. If you leave, your answers are saved and you can
  resume until the time runs out.”

For untimed quizzes, say the attempt stays open until a new attempt is started.

### 7.6 Result body

- Keep current server fields.
- Add an `auto_submitted` note when `result.autoSubmitted`:
  `quiz_auto_submitted_note`.
- Add an “under correction” state when `result.isAwaitingCorrection`; but the preferred
  path is to keep the user on `awaitingResult` until `submitted_at != null`.
- `review_status == pending` keeps the existing preliminary badge.
- If opened from a notification (`resultOnly`), show “Back to lesson” using
  `contentId`/`lessonId` when available, otherwise “Back to notifications”.

### 7.7 Result route for notifications

Add:

- `AppRoutes.quizResult = 'quiz-result'`.
- `QuizResultArgs { int attemptId; int? contentId; int? lessonId; bool autoSubmitted; }`
  in `lib/features/lesson_test/presentation/refactor/quiz_result_args.dart`.
- Route registration in the app router that builds `LessonTestScreen` in result-only
  mode.
- `LessonTestArgs` gains `int? attemptId` (or a separate body route); keep
  `LessonTestArgs.fromRoute` backward compatible for `lessonId`.

`NotificationDestination.fromPushData`:

```dart
if (_firstString(data, const ['action']) == 'open_quiz_result') {
  final int attemptId = _firstId([_firstString(data, const ['attempt_id'])]);
  if (attemptId > 0) {
    return NotificationDestination(
      AppRoutes.quizResult,
      arguments: QuizResultArgs(
        attemptId: attemptId,
        contentId: _firstId([...content_id...]),
        autoSubmitted: data['auto_submitted'] == '1' || data['auto_submitted'] == true,
      ),
    );
  }
}
```

Place this branch **before** the content/lesson fallback so the result wins.

`NotificationPayload` gains `attemptId`, `quizId`, `autoSubmitted` (parsed from
`attempt_id`, `quiz_id`, `auto_submitted`). Keep it backward compatible.

`NotificationKind` gains `quizResult('quiz_result')` with a label key and an existing
asset (reuse the lesson/approval asset if no dedicated one exists). Without this the
notification list falls back to `custom`, which is acceptable but less precise.

---

## 8. Phase 5 — Localization

Add to both JSON files and `LangKeys` (Arabic is primary):

| Key | English | Arabic |
|---|---|---|
| `quiz_saving` | Saving… | جارٍ حفظ الإجابات… |
| `quiz_saved` | All answers saved | تم حفظ جميع الإجابات |
| `quiz_unsaved` | Unsaved changes | توجد إجابات غير محفوظة |
| `quiz_save_failed` | Could not save. Tap to retry. | تعذّر حفظ الإجابات. اضغط لإعادة المحاولة. |
| `quiz_time_expired` | The attempt time is over. | انتهى وقت المحاولة. |
| `quiz_time_up_submitting` | Time is up. Submitting your saved answers… | انتهى الوقت. جارٍ تسليم الإجابات المحفوظة… |
| `quiz_awaiting_result` | Your quiz is being corrected. This may take a moment. | يتم تصحيح اختبارك الآن. قد يستغرق ذلك لحظات. |
| `quiz_result_pending_refresh` | Refresh result | تحديث النتيجة |
| `quiz_auto_submitted_note` | The time ran out, so this attempt was submitted automatically. | انتهى الوقت، وتم تسليم المحاولة تلقائيًا. |
| `quiz_attempt_not_found` | This attempt could not be found. | تعذّر العثور على هذه المحاولة. |
| `quiz_saved_and_left` | Your answers were saved. You can resume this attempt before it expires. | تم حفظ إجاباتك. يمكنك متابعة هذه المحاولة قبل انتهاء وقتها. |
| `notification_kind_quiz_result` | Quiz result | نتيجة اختبار |

Update existing copy:

- `quiz_leave_confirm_message` → no submission, resumable.
- `quiz_leave_confirm_action` → “Leave” / «مغادرة».
- `quiz_start_confirm_message` → attempt is consumed, but leaving keeps it open.

Do not reuse `test_time_up` for the new awaiting state; keep it for backward
compatibility but stop showing it as a pop-and-leave message.

---

## 9. Phase 6 — Tests and Verification

### 9.1 Fixtures

Add under `test/features/lesson_test/fixtures/`:

- `attempt_save_response.json` — timed, `seconds_left`, `has_expired: false`
- `attempt_save_expired.json` — `has_expired: true`, `seconds_left: 0`
- `attempt_resume_saved_answers.json` — all 7 types in `saved_answers`
- `attempt_fetch_submitted.json` — `auto_submitted: true`, `submitted_at` set
- `attempt_fetch_awaiting.json` — `submitted_at: null`, `has_expired: true`
- `attempt_fetch_untimed.json` — `expires_at: null`, `seconds_left: null`
- `quiz_result_push.json` — the notification data map

### 9.2 Model tests

- `QuizAttemptModel` parses `server_now`, `auto_submitted`, `saved_answers`.
- `saved_answers` `{}` leaves all answers empty.
- `isAwaitingCorrection` true only when `submitted_at == null && has_expired`.
- `TestAnswerModel.fromSavedJson` round-trips every type.
- `toSaveJson` returns `null` for cleared choice/boolean/blanks/matches; ordering is
  always a list.
- Partial blanks and partial matches are accepted by the save validator.
- `QuizSaveResultModel` handles `null` `expires_at`/`seconds_left`.

### 9.3 Cubit tests

- Two rapid edits to the same question produce **one** PUT after 1.5 s.
- Edits to two questions coalesce into one PUT.
- Edit during an in-flight PUT is not lost: a second PUT follows with the newer value.
- Clearing an answer sends `null`.
- Save failure keeps the answer and retries with backoff.
- `403` stops autosave and maps to `quiz_unavailable` without session end.
- `422 expired` stops autosave and reconciles the attempt.
- `422 already submitted` reconciles and emits `result`.
- Resume hydrates `saved_answers` for all seven types; a bad ordering array falls back
  to server order.
- `server_now` offset is applied; a 5-minute device clock skew still yields the correct
  `remaining`.
- `seconds_left` recalibrates when `server_now` is absent.
- Timer reaches zero → exactly one submit; no pop; state becomes `result` or
  `awaitingResult`.
- Grace success at `expires_at + 5 s` shows the real result, not zero.
- Awaiting result polls until `submitted_at` appears, then emits `result`.
- Polling stops after the cap and shows a manual retry.
- Leaving calls no submit and preserves dirty answers.
- Manual submit + timeout race → exactly one request.
- `flushAndLeave` on network failure still returns `true` (allow leaving).
- 401 during save keeps dirty answers and surfaces the session error.

### 9.4 Widget tests

- Autosave row shows saving → saved.
- Autosave row shows failed + retry.
- Time-up keeps the quiz screen and shows `awaitingResult`.
- Result shows the auto-submitted note.
- Leave dialog copy no longer says “submits”.
- `open_quiz_result` push routes to the result screen with the right `attemptId`.
- Unknown/missing `attempt_id` falls back to lesson detail.

### 9.5 Manual QA

- Answer → kill the app → reopen → start returns the same attempt with the saved
  answer selected.
- Answer, disable the network, answer again, re-enable → both saves eventually land
  (second overwrites).
- Device clock set 10 minutes ahead/behind → countdown matches `seconds_left`.
- Let the timer hit zero → app stays on the quiz, submits, shows result; server marks
  `auto_submitted = true` when the client submit misses the grace window.
- Tap the `quiz_result` push while the app is closed → result screen for that attempt.
- Tap the same push twice → no duplicate route.
- Leave mid-attempt → no submission; return → same attempt with saved answers.
- Untimed quiz → leave for a day → start a new attempt → old attempt is closed with 0.
- Empty submit → result with 0, no crash.
- Pending review → preliminary badge; blocking quiz keeps the next lesson locked.
- Arabic RTL and English LTR.
- No quiz `403` signs the student out.

### 9.6 Commands

```powershell
flutter analyze
flutter test
```

---

## 10. Acceptance Criteria (additive)

- [ ] Every answer change is persisted within ~2 s, and on leave/background/submit.
- [ ] Only changed questions are sent; clearing sends `null`; merge never wipes other
      answers.
- [ ] Resume hydrates `saved_answers` for all seven types.
- [ ] The countdown is based on `server_now`, not the device clock.
- [ ] Submit is attempted at `expires_at` and succeeds inside the 15 s grace window.
- [ ] After the grace window the app reconciles with `GET attempt` and shows the result
      or “awaiting result”; it never shows a client-calculated zero.
- [ ] Leaving never submits and never ends the attempt.
- [ ] `auto_submitted` is displayed when true.
- [ ] `quiz_result` push opens the correct attempt result; missing attempt falls back
      to the lesson.
- [ ] Waiting for correction polls and stops with a manual retry.
- [ ] No duplicate submit from timer + manual tap.
- [ ] No new hardcoded UI text; all keys exist in Arabic and English.
- [ ] `flutter analyze` and `flutter test` pass.

---

## 11. Suggested Commit Sequence

1. `feat(quiz): add attempt autosave and fetch endpoints`
2. `feat(quiz): parse saved answers, server clock, and auto submission`
3. `feat(quiz): autosave queue, retries, and resume hydration in cubit`
4. `feat(quiz): grace submit, awaiting-result polling, and leave without submit`
5. `feat(quiz): result-only route and quiz_result push handling`
6. `feat(quiz): autosave/time-up/auto-submit UI and localization`
7. `test(quiz): fixtures and coverage for autosave, grace, and notifications`

No commit should include unrelated features.

---

## 12. Open Questions (confirm before coding)

1. Does `POST /user/quizzes/{quizId}/attempts` include `server_now` on the **start**
   response, or only on save/fetch? Plan assumes “if present”, with save/fetch as the
   primary calibration points.
2. Is a `null` question value in autosave accepted for **every** type (including
   ordering), or only for the types that can be cleared? Plan sends `null` only for
   clearable types and keeps ordering complete.
3. Does the backend return `422` with a stable machine code for “expired” vs “already
   submitted”, or only a localized message? Plan uses status + attempt state + string
   heuristics; a stable code is preferred.
4. Should an untimed attempt be resumable indefinitely, or is there a maximum age the
   app should display? Guide says it stays open until a new attempt starts.
5. Is `saved_answers` omitted or `{}` when nothing was saved? Plan treats both as
   empty.
