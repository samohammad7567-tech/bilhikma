# Quiz Test 3 — Implementation Plan

**Status:** plan only. Do not implement code from this document in the same turn.

**Source of truth:** `Quiz_Test3.pdf` (9 pages: 8 student-facing defects + 1 admin-dashboard QA page).

**Baseline:** current `lib/features/lesson_test` feature and the earlier
`implement_quize_update.md` / `Queize_test_updates.md` plans. Where this document and
older notes disagree, this document wins for the 8 PDF defects.

**Scope:** student/mobile only. No admin, question-bank, publishing, or teacher-review
screens. Page 9 of the PDF is QA evidence for the dashboard; it is not a mobile task.

---

## 0. Execution Contract

1. Work one phase at a time. Do not mix model, Cubit, and UI changes in one commit
   unless the phase explicitly groups them.
2. Keep the existing `lesson_test` feature and Cubit. Do not create a second quiz
   feature, a second Cubit, or a `domain/` layer.
3. The Cubit owns loading, answers, pending saves, retry/backoff, resume index, submit,
   timeout, and result state.
4. The data source owns API calls and local persistence. Widgets only render state and
   forward actions.
5. Never grade on the client. Never derive pass/fail or percentages locally.
6. No `BuildContext`, navigation, or localization inside the Cubit.
7. Add every new string to `assets/translations/ar.json` **and**
   `assets/translations/en.json`, plus `lib/core/localization/lang_keys.dart`.
   Never use raw `'key'.tr()`.
8. `build_runner` is **not** required. All models use manual `fromJson`/`toJson`.
9. After each phase run `flutter analyze` and `flutter test`.
10. Reuse `corereusablepackage` and existing `AppTheme` values. Do not add ad-hoc
    colors, spacing, or a new dependency for this work.
11. Do not introduce `flutter_markdown` or `connectivity_plus` unless the project
    already adds them; this plan needs neither (see §4.1 and §4.4).

---

## 1. Issue Map

| # | PDF title | Root cause in current code | Primary fix area | Phase |
|---|---|---|---|---|
| 1 | Answer is not sent after the internet returns | Offline save calls `_failAndStop()` and cancels the remote-save timer; pending answers stay only in memory and the screen is replaced by a failure view | Cubit autosave/retry + screen resume flush | 1 |
| 2 | Review shows no images for image options | `TestGivenAnswers` / `TestSolutionAnswers` return plain `String` lists; `TestOptionModel.imageUrl` and solution `image_path` are ignored by the review | review answer model + review widgets | 2 |
| 3 | Optional per-option feedback is missing in review | Review reads only the global `explanation`; `solution.details.options[].feedback` is never parsed or rendered | solution parser + review card | 3 |
| 4 | Rich question text shows literal `**` | `TestHtmlText` only understands HTML tags/entities; `options.question_format` is not parsed, so Markdown-style bold and `﴿ ﴾` verses are shown raw | question model + prompt renderer | 4 |
| 5 | “Start test” never becomes “Continue” | `LessonTestModel` ignores `has_open_attempt` / `open_attempt`; the intro always renders `start_test` and the start dialog always says a new attempt is consumed | model + intro body + start dialog | 5 |
| 6 | Resume starts from question 1 | `startAttempt()` hard-codes `currentIndex: 0`, even when restored answers exist | Cubit resume index | 6 |
| 7 | “Unlimited” appears with no label on the result screen | `TestRetryNote._message()` returns `quizAttemptsUnlimited` alone when `attemptsLeft == null` | result retry note | 7 |
| 8 | Long matching answer is truncated with “…” | `TestReviewAnswers` joins all correct answers/pairs into one line; long pair text is ellipsized instead of wrapping | review answers rendering | 8 |
| 9 | Admin dashboard test (page 9) | Not a mobile defect; documents backend/admin behavior that is already working | verification only | 9 |

---

## 2. Server Contract Additions

Confirm these exact shapes with the backend before coding the corresponding phase. The
plan already tolerates missing fields.

### 2.1 `GET /user/content/{id}/quiz`

Adds:

```json
{
  "has_open_attempt": true,
  "open_attempt": {
    "id": 84,
    "attempt_no": 2,
    "started_at": "2026-11-07T09:00:00+00:00",
    "expires_at": "2026-11-07T09:30:00+00:00"
  }
}
```

- `has_open_attempt` is authoritative for the intro CTA.
- `open_attempt` may be omitted or `null`; parse defensively.

### 2.2 Attempt `answers[]` question object

Adds:

- `options.question_format` — string, `"rich"` for dashboard-formatted questions.
- Each option keeps `image_path` (already parsed by `TestOptionModel`).
- Raw `question_text` is sent unchanged (including `**` and `﴿ ﴾`).

### 2.3 Attempt review payload

`solution` may include:

```json
{
  "details": {
    "options": [
      { "id": "o_1", "image_path": "/storage/q/opt1.png", "feedback": "..." }
    ],
    "pairs": [
      { "left_id": "l_1", "right_id": "r_1", "left_text": "...", "right_text": "..." }
    ]
  }
}
```

- `feedback` exists only on options the teacher annotated.
- Option images may also arrive with `given_answer` option entries; otherwise resolve
  them from `TestQuestionModel.options`.
- `solution.details.pairs` must carry every pair complete; do not shorten on the server.

### 2.4 Result fields

- `attempts_left: null` for unlimited quizzes (already parsed as `int?`).
- `submitted_at` / `is_passed` / `score_percent` unchanged.

---

## 3. Current-Code Facts To Preserve

- `LessonTestCubit._failAndStop()` (`lesson_test_cubit.dart:79`) stops timers and emits
  `LessonTestStatus.failure` with `saveStatus: failed`.
- `_flushRemoteSaves()` (`lesson_test_cubit.dart:1220`) calls `_failAndStop()` when
  `_isOffline(exception)` is true (`~1297`). This is the direct cause of issue 1.
- `_scheduleRemoteSave()` uses a single 1200 ms debounce timer; there is no retry
  backoff for network failures.
- `startAttempt()` emits `currentIndex: 0` unconditionally (`~367`) after
  `_restoredAnswers(attempt)`.
- `_restoredAnswers()` (`~1454`) already merges server `saved_answers` and the local
  `LessonTestLocalDataSource` cache.
- `LessonTestScreen` is a `WidgetsBindingObserver`; on `resumed` it calls
  `cubit.reopenCurrentQuestion()` and on pause it calls `cubit.flushAnswers()`
  (`lesson_test_screen.dart:46-59`).
- `TestProgressHeader` already renders `quiz_saving`, `quiz_saved`, and
  `quiz_save_failed` from `saveStatus` (`test_progress_header.dart:97-123`).
- `TestReviewAnswers._row()` joins answers with `' | '` and renders one
  `TestHtmlText` per row (`test_review_answers.dart:45-50`).
- `TestHtmlText` only detects HTML tags/entities; plain `**bold**` is rendered raw
  (`test_html_text.dart:22-45`).
- `TestOptionModel` and `TestMatchItemModel` already parse `image_path`; the review
  layer drops it.
- `QuizQuestionResultModel.solution` is kept as a raw map; typed helpers must be added.
- `QuizStartDialog.show(context)` always uses
  `quiz_start_confirm_title` / `quiz_start_confirm_message`.
- `/user/quiz-attempts/{attemptId}`, `/answers`, and `/submit` endpoints already exist in
  `api_endpoints.dart:47-56`.

---

## 4. Implementation Phases

### Phase 1 — Resend pending answers after reconnection (Issue 1)

**Problem:** cutting the network while answering shows “تعذر حفظ الإجابات”; when the
network returns, the pending answer is never sent because the Cubit stopped, and it is
lost if the app is closed.

**Files**

- `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_state.dart`
- `lib/features/lesson_test/presentation/screens/lesson_test_screen.dart`
- `lib/features/lesson_test/presentation/widgets/test_progress_header.dart` (only if a
  retry affordance is added)

**Change**

1. Add retry state to the Cubit:
   ```dart
   int _remoteSaveAttempts = 0;
   Timer? _remoteSaveRetry;
   ```
   Reuse `_remoteSaveTimer` for the normal debounce; add a separate retry timer so a
   user edit cancels the debounce, not the backoff.
2. In `_flushRemoteSaves()`, **do not** call `_failAndStop()` for
   `ErrorMapper.noInternetKey` during autosave. Instead:
   - keep `_pendingRemoteSaves` untouched;
   - emit `isSavingRemote: false`, `saveStatus: LessonTestSaveStatus.failed`, and keep
     `status == running`;
   - call `_scheduleRemoteRetry()`.
3. `_scheduleRemoteRetry()` uses incremental backoff:
   `2 s, 4 s, 8 s, 16 s, 30 s` (cap), resetting `_remoteSaveAttempts` to 0 on any
   successful save, on a new answer edit, or on a new attempt. It must not run when
   `state.isResult`, `state.resultOnly`, `!state.isRunning`, or the attempt has expired.
4. On a successful retry, emit `saveStatus: LessonTestSaveStatus.saved` and clear the
   retry timer. The header then shows “تم حفظ الإجابات”.
5. In `LessonTestScreen.didChangeAppLifecycleState`, on
   `AppLifecycleState.resumed` when running, call both
   `reopenCurrentQuestion()` and `cubit.flushAnswers()`. This is the “connectivity
   returned / app came back” flush and needs no new dependency.
6. Keep the existing hard-stop behavior only for failures that end the attempt
   (`403`, `422 already submitted`, `422 expired`, session `401`). Network failures no
   longer stop the quiz.
7. Do not show the full-screen `AppErrorView` for a transient autosave failure. The
   header status is enough; optionally make the failed status tappable to call
   `flushAnswers()`.
8. Optionally add `onRetrySave` callback to `TestProgressHeader`; keep the row a fixed
   height so the question does not shift.

**Tests**

- Cubit test: save throws `no_internet_connection` → state remains `running`,
  `_pendingRemoteSaves` retained, `saveStatus == failed`.
- Cubit test: after the retry timer fires and the server succeeds → `saveStatus ==
  saved`, pending map empty.
- Cubit test: a new edit during backoff resets the attempt counter and keeps the newest
  payload.
- Widget test: header shows “تعذر حفظ الإجابات” then “تم حفظ الإجابات” after retry.

---

### Phase 2 — Show option images in the answer review (Issue 2)

**Problem:** image-only questions show “إجابة غير صحيحة” with no image for the student’s
choice or the correct choice, so the student cannot tell what they picked. Ordering and
matching with images have the same gap.

**Files**

- `lib/features/lesson_test/presentation/refactor/test_given_answers.dart`
- `lib/features/lesson_test/presentation/refactor/test_solution_answers.dart`
- `lib/features/lesson_test/presentation/widgets/test_review_answers.dart`
- `lib/features/lesson_test/presentation/widgets/test_result_review_card.dart`
- new `lib/features/lesson_test/presentation/refactor/quiz_review_answer.dart`
- `lib/features/lesson_test/data/models/quiz_question_result_model.dart`
  (helper getters only)

**Change**

1. Introduce a renderable review item instead of `List<String>`:
   ```dart
   class QuizReviewAnswer {
     const QuizReviewAnswer({
       this.text = '',
       this.imageUrl,
       this.feedback,
     });
     final String text;
     final String? imageUrl;
     final String? feedback;
     bool get isEmpty => text.trim().isEmpty && imageUrl == null;
   }
   ```
2. Change `TestGivenAnswers.of(...)` and `TestSolutionAnswers.of(...)` to return
   `List<QuizReviewAnswer>`.
3. Resolution rules:
   - Choice: resolve the option ID through `question.optionById(id)`. Take `label` as
     text and `imageUrl` as image.
   - If the server sends an inline option map, read `text`/`label` and
     `image_path`/`image`; prefer the server image, then the question model image.
   - Ordering: resolve each item through `question.sentences`; include
     `imageUrl` when present.
   - Matching: resolve left/right through `question.leftItems` / `rightItems`; attach
     the right item (or left when the right has no image) image to the pair entry.
   - Fill/typed blanks: text only; ignore images.
   - Never drop an entry because it has no text if it has an image.
4. `TestReviewAnswers` renders each `QuizReviewAnswer` as a row: optional
   `TestMediaImage` thumbnail (reuse the existing widget, 48–56 px) plus the text.
   When `text` is empty and only an image exists, render the image alone.
5. Keep the existing localization labels (`quiz_your_answer`, `quiz_correct_answer`,
   `quiz_explanation`).
6. Pass `question` into both renderers everywhere (`TestResultReviewCard` already
   receives it).
7. Do not change the running quiz widgets; they already render images correctly.

**Tests**

- Model/helper test: single-choice with image options returns the chosen option image
  and the correct option image.
- Helper test: ordering and matching return image URLs when the question model has them.
- Widget test: review card renders `TestMediaImage` for image-only options.
- Negative test: text-only questions render exactly as before.

---

### Phase 3 — Show optional per-option feedback in review (Issue 3)

**Problem:** the dashboard allows an optional “لماذا هذا الخيار خطأ؟” per option. The
review shows only the general explanation even when the chosen option has feedback.

**Files**

- `lib/features/lesson_test/data/models/test_option_model.dart`
- `lib/features/lesson_test/data/models/quiz_question_result_model.dart`
- `lib/features/lesson_test/presentation/refactor/test_solution_answers.dart`
- `lib/features/lesson_test/presentation/refactor/test_given_answers.dart`
- `lib/features/lesson_test/presentation/widgets/test_review_answers.dart`
- localization files

**Change**

1. Add optional `feedback` to `TestOptionModel`:
   ```dart
   this.feedback,
   final String? feedback;
   ```
   Parse `json['feedback'] ?? json['comment']`; keep `null` when empty.
2. Add helpers to `QuizQuestionResultModel`:
   ```dart
   List<String> get selectedOptionIds;
   List<TestOptionModel> get solutionOptions;
   String? feedbackFor(String optionId);
   ```
   - `selectedOptionIds` reads `given_answer.option_id`, `given_answer.option_ids`,
     and the existing flat `selected_option_id` fallback added in `fromJson`.
   - `solutionOptions` parses `solution['details']['options']` with
     `TestOptionModel.fromJson`, skipping malformed entries.
   - `feedbackFor` returns the trimmed feedback for the matching option id.
3. In `TestGivenAnswers`, when building the student’s chosen option entry, attach
   `feedbackFor(optionId)` to the `QuizReviewAnswer`.
4. In `TestReviewAnswers`, render the feedback under the “Your answer” row only when it
   is non-null and non-empty. Use a new key `quiz_option_feedback`.
   - No placeholder and no “no feedback” text when absent.
   - Keep the general explanation row unchanged and independent.
5. Multi-select: show feedback for every chosen option that has one, in selection order,
   each on its own line.
6. Do not show feedback for options the student did not choose.

**Tests**

- Model test: solution options parse `feedback`; missing field yields `null`.
- Widget test: chosen option with feedback shows the feedback under “Your answer”.
- Widget test: chosen option without feedback shows no feedback row.
- Widget test: non-chosen option feedback is never shown.

---

### Phase 4 — Render formatted question text (Issue 4)

**Problem:** a question saved in the dashboard as formatted text
`اختر ما هو من أركان الإسلام: **الصلاة**` with a verse between `﴿ ﴾` shows the literal
`**` in the app, while the dashboard preview renders bold.

**Files**

- `lib/features/lesson_test/data/models/test_question_model.dart`
- new `lib/features/lesson_test/presentation/widgets/test_rich_prompt.dart`
- `lib/features/lesson_test/presentation/widgets/test_question_prompt.dart`
- all question widgets that pass `question.prompt` (they can keep passing the prompt;
  the renderer decides)
- `lib/features/lesson_test/presentation/refactor/test_review_prompt.dart`
- `lib/features/lesson_test/presentation/widgets/test_result_review_card.dart`

**Change**

1. Parse the format flag in `TestQuestionModel.fromJson`:
   ```dart
   final String questionFormat =
       Json.asOptionalString(options['question_format']) ??
       Json.asOptionalString(details['question_format']) ??
       '';
   ```
   Add `final String questionFormat;` and
   `bool get isRichPrompt => questionFormat.toLowerCase() == 'rich';`.
   Preserve the raw `prompt` exactly as received.
2. Add `TestRichPrompt` (no new package):
   - Split on `**...**` and render bold `TextSpan`s.
   - Detect `﴿...﴾` runs and render them with a distinct font/`FontStyle` and a
     slightly different color from `AppTheme` (a dedicated Quran style, not an ad-hoc
     widget).
   - Preserve `\n` as line breaks (`softWrap: true`).
   - If the text contains no `**` and no `﴿`, fall back to the existing
     `TestHtmlText` so HTML content keeps working.
   - Never render raw `**` markers.
3. `TestQuestionPrompt` gains `bool rich = false` (or `TestQuestionModel? question`).
   When `rich` is true, use `TestRichPrompt` for the prompt; otherwise keep
   `TestHtmlText`.
4. Pass `rich: question.isRichPrompt` from `TestChoiceQuestion`,
   `TestFillBlanksQuestion`, `TestDropdownBlanksQuestion`,
   `TestTypedBlanksQuestion`, `TestMatchPairsQuestion`, and
   `TestOrderSentencesQuestion`.
5. Review prompt: `TestReviewPrompt.of` already returns the question prompt/body. Make
   `TestResultReviewCard` render it through `TestRichPrompt` when the question is rich,
   so review matches the attempt screen.
6. Do not strip `**` from stored/sent data; formatting is display-only.
7. Do not treat a literal `**` that is escaped or inside an HTML attribute as bold; the
   parser only handles the simple dashboard contract.

**Tests**

- Model test: `options.question_format == 'rich'` sets `isRichPrompt`.
- Widget test: `**الصلاة**` renders `الصلاة` with a bold span and no `*` characters.
- Widget test: `﴿ ... ﴾` renders with the Quran style.
- Widget test: non-rich questions still render HTML and plain text exactly as before.
- Widget test: newlines are preserved.

---

### Phase 5 — “Continue test” when an attempt is open (Issue 5)

**Problem:** with an open attempt, the start screen still says “بدء الاختبار” and the
confirmation says starting consumes an attempt, although the action resumes the open
attempt.

**Files**

- new `lib/features/lesson_test/data/models/quiz_open_attempt_model.dart`
- `lib/features/lesson_test/data/models/lesson_test_model.dart`
- `lib/features/lesson_test/presentation/refactor/lesson_test_intro_body.dart`
- `lib/features/lesson_test/presentation/widgets/quiz_start_dialog.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_state.dart`
- localization files

**Change**

1. Add `QuizOpenAttemptModel`:
   ```dart
   class QuizOpenAttemptModel {
     final int id;
     final int attemptNo;
     final DateTime? startedAt;
     final DateTime? expiresAt;
   }
   ```
   Parse `id`, `attempt_no`, `started_at`, `expires_at` defensively.
2. Add to `LessonTestModel`:
   ```dart
   final bool hasOpenAttempt;
   final QuizOpenAttemptModel? openAttempt;
   ```
   Parse `has_open_attempt`; also infer `hasOpenAttempt == true` when an `open_attempt`
   map with `id > 0` is present. Add both to `toJson`.
3. Add `bool get isResuming => quiz?.hasOpenAttempt ?? false;` to
   `LessonTestState`.
4. Update `canStart` so an open attempt is resumable even when
   `hasAttemptsLeft == false` or the quiz is in cooldown:
   ```dart
   (quiz?.hasOpenAttempt == true) ||
   ((quiz?.hasAttemptsLeft ?? false) && !(quiz?.isInCooldown ?? true))
   ```
   Keep the existing `questionCount > 0` guard.
5. `LessonTestIntroBody`:
   - Button label: `quiz.hasOpenAttempt ? quiz_continue_test : start_test`.
   - Keep the same `onStart` callback; the server `POST /attempts` returns the open
     attempt.
   - The attempts row may still show the server value; do not invent a new count.
6. `QuizStartDialog.show(context, {bool resuming = false})`:
   - `resuming == false` → existing title/message/confirm.
   - `resuming == true` → `quiz_continue_confirm_title`,
     `quiz_continue_confirm_message`, confirm `quiz_continue_test`.
   - Do not say “يستهلك محاولة” when resuming.
7. Pass `resuming: quiz.hasOpenAttempt` from `LessonTestIntroBody._confirmStart`.
8. Keep the dialog component and `AppConfirmDialog` usage; do not build a second dialog.

**Tests**

- Model test: `has_open_attempt` and `open_attempt` parse correctly; missing fields
  default to `false`/`null`.
- Widget test: intro with `hasOpenAttempt == true` shows “متابعة الاختبار”.
- Widget test: start dialog in resume mode does not contain the “consumes an attempt”
  copy.
- Cubit test: start is allowed with an open attempt even when `attemptsLeft == 0`.

---

### Phase 6 — Resume at the first unanswered question (Issue 6)

**Problem:** a student on question 2 closes and reopens the app; answers are restored
but the screen opens at question 1.

**Files**

- `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_state.dart`

**Change**

1. Add a private helper:
   ```dart
   int _resumeIndex(QuizAttemptModel attempt, Map<String, TestAnswerModel> answers);
   ```
   Rules:
   - Iterate `attempt.questions` in order.
   - Return the first index whose answer is not answered by
     `answer.isAnswered(question.type)`, treating an untouched ordering answer as
     unanswered.
   - If every question is answered, return the index of the last answered question.
   - If no answers exist, return `0`.
2. In `startAttempt()`, after `answers: _restoredAnswers(attempt)`, compute
   `startIndex = _resumeIndex(attempt, answers)` and emit
   `currentIndex: startIndex` instead of `0`.
3. Call `openQuestion(startIndex)` instead of `openQuestion(0)`.
4. Keep `_restoredAnswers()` as the single source for both server and local-cache
   answers. Do not add a second restore path.
5. Result-only mode and a fresh attempt with no saved answers still start at 0.
6. Do not skip questions that were opened but unanswered; “first unanswered” is the
   contract, not “last opened”.
7. If the saved index is out of range after a question-list change, clamp to `0` and do
   not crash.

**Tests**

- Cubit test: saved answer on question 0 only → resume index `1`.
- Cubit test: answers on 0 and 1, none after → resume index `2`.
- Cubit test: all answered → resume at the last answered question.
- Cubit test: untouched ordering answer is not counted as answered.
- Cubit test: no saved answers → index `0`.

---

### Phase 7 — Label unlimited attempts on the result screen (Issue 7)

**Problem:** the result screen shows “غير محدودة” alone, so the student does not know
it means remaining attempts.

**Files**

- `lib/features/lesson_test/presentation/widgets/test_retry_note.dart`
- localization files

**Change**

1. In `TestRetryNote._message`, change the `left == null` branch from
   `LangKeys.quizAttemptsUnlimited.tr()` to a labeled string:
   ```dart
   return LangKeys.quizAttemptsLeftUnlimited.tr();
   ```
   with value “المحاولات المتبقية: غير محدودة” / “Attempts left: Unlimited”.
2. Keep `attemptsLeft <= 0` → `quizNoAttemptsLeft` and `attemptsLeft > 0` →
   `"${quizAttemptsLeft.tr()}: $left"`.
3. Do not change the intro row; it already renders a label and value pair.
4. Do not change the `QuizAttemptModel.attemptsLeft` parsing; `null` already means
   unlimited.

**Tests**

- Widget test: `attemptsLeft == null` renders “المحاولات المتبقية: غير محدودة”.
- Widget test: `attemptsLeft == 0` renders “لا توجد محاولات متبقية”.
- Widget test: `attemptsLeft == 2` renders “المحاولات المتبقية: 2”.

---

### Phase 8 — Wrap long matching answers in review (Issue 8)

**Problem:** in a one-to-many matching question, the correct answer is truncated with
“…” at the end, so the student cannot see every pair.

**Files**

- `lib/features/lesson_test/presentation/widgets/test_review_answers.dart`
- `lib/features/lesson_test/presentation/refactor/test_solution_answers.dart`
- `lib/features/lesson_test/presentation/refactor/test_given_answers.dart`
- `lib/features/lesson_test/presentation/widgets/test_result_review_card.dart`

**Change**

1. Stop joining all values with `' | '`. Render one `QuizReviewAnswer` per line inside
   the answer block:
   ```dart
   Column(
     crossAxisAlignment: CrossAxisAlignment.stretch,
     children: [
       for (final answer in answers) _answerRow(answer),
     ],
   )
   ```
2. Each row must allow multi-line text:
   - `softWrap: true`;
   - no `maxLines` and no `TextOverflow.ellipsis` on review answers;
   - the text is in an `Expanded`/flexible slot next to an optional thumbnail.
3. For matching, return one `QuizReviewAnswer` per pair (`left → right`), not one
   combined string. The card then naturally shows one pair per line.
4. Ensure `TestHtmlText` does not truncate in review:
   - when `maxLines == null`, do not pass an ellipsis overflow;
   - if `HtmlWidget` is used, it already wraps; keep the caller from constraining it.
5. Keep the same labels and order: “إجابتك”, “الإجابة الصحيحة”, “التوضيح”.
6. Do not change the running question layout (the option tile keeps its own
   `maxLines: 3` for the quiz body).
7. Arabic RTL: use `CrossAxisAlignment.stretch` and `textAlign` from the locale; do not
   use a fixed `Row` that clips.

**Tests**

- Widget test: five long matching pairs are all present in the tree and none is
  ellipsized.
- Widget test: a single pair longer than the card width wraps to multiple lines.
- Widget test: review still shows thumbnails when the pair has images (Phase 2).
- Golden/manual: Arabic RTL and English LTR both show every pair.

---

### Phase 9 — Admin dashboard QA page (PDF page 9)

**Status:** no mobile code change. Page 9 lists dashboard-side capabilities that were
tested successfully:

- quiz settings (pass, attempts, wait, time limit, shuffle, blocking, show answers,
  publish);
- question types and their options (feedback, best answer, selection limit, word bank
  and distractors, one-to-many matching, ordering policy, accepted forms and
  normalization);
- question/option image upload and audio upload;
- editor and bank buttons, filters, search, export;
- attempt filters/details/export, review decisions, and their effect on score/status.

**Action:** verify the mobile app consumes the resulting fields correctly. The only
mobile gaps in this document are the 8 defects above; do not build admin or
question-bank UI here.

**Parity checks**

- `show_correct_answers`, `is_blocking`, `shuffle_questions`, `time_limit_minutes`,
  `pass_score`, `attempts_left`, and `retry_cooldown_minutes` keep their current
  behavior.
- A rejected non-matching bank question (`422`) must not sign the student out; keep the
  existing `QuizErrorMapper` behavior.
- Winner: if page 9 reveals a field the mobile app does not read (for example
  `question_format`), handle it in the matching phase above.

---

## 5. Localization Keys

Add to `lib/core/localization/lang_keys.dart` and both JSON files. Arabic is primary.

| Key | Arabic | English |
|---|---|---|
| `quiz_continue_test` | متابعة الاختبار | Continue test |
| `quiz_continue_confirm_title` | لديك محاولة مفتوحة | You have an open attempt |
| `quiz_continue_confirm_message` | سيتم استئناف محاولتك المفتوحة من حيث توقفت، ولن تستهلك محاولة جديدة. | Your open attempt will resume where you left off. This will not use a new attempt. |
| `quiz_option_feedback` | تعليق على اختيارك | Note on your choice |
| `quiz_attempts_left_unlimited` | المحاولات المتبقية: غير محدودة | Attempts left: Unlimited |

Existing keys to keep and reuse:

- `quiz_saving`, `quiz_saved`, `quiz_save_failed`
- `quiz_your_answer`, `quiz_correct_answer`, `quiz_explanation`
- `quiz_attempts_left`, `quiz_attempts_unlimited`, `quiz_no_attempts_left`
- `quiz_start_confirm_title`, `quiz_start_confirm_message`
- `start_test`

Rules:

- Add the `LangKeys` constant before using the key.
- Do not use a server message as a translation key; display-only server text is fine in
  `errorMessage`.
- Do not reuse `quiz_attempts_unlimited` alone on the result screen after Phase 7.
- Keep `quiz_attempts_unlimited` for the intro value column.

---

## 6. Tests And Commands

### 6.1 New or updated tests

- `test/features/lesson_test/lesson_test_cubit_test.dart`
  - offline save keeps the attempt running and retries with backoff;
  - retry success clears pending saves and sets `saved`;
  - resume index picks the first unanswered / last answered;
  - open attempt allows start with `attemptsLeft == 0`.
- `test/features/lesson_test/quiz_models_test.dart`
  - `has_open_attempt` + `open_attempt` parsing;
  - `question_format == 'rich'`;
  - solution option `feedback` and `image_path` parsing;
  - `selectedOptionIds` for single and multi;
  - unlimited `attempts_left: null`.
- `test/features/lesson_test/quiz_review_answers_test.dart` (new)
  - option/ordering/matching images resolve;
  - per-option feedback attaches to the chosen option only;
  - long matching pairs are returned one per entry.
- Widget tests
  - review card renders image-only answers;
  - feedback row appears only when present;
  - rich prompt renders bold and verse without `**` or `﴿` raw markers;
  - intro shows “متابعة الاختبار” for an open attempt;
  - resume dialog copy;
  - result note shows “المحاولات المتبقية: غير محدودة”;
  - long matching pairs wrap with no ellipsis.
- Existing `test/features/lesson_test/quiz_error_mapper_test.dart` stays green.

### 6.2 Fixtures (copy from real responses before release)

- quiz overview with `has_open_attempt: true` and `open_attempt`;
- attempt answers with image options, ordering images, matching images;
- review payload with `solution.details.options[].feedback` and image paths;
- rich question with `**` and `﴿ ﴾`;
- result with `attempts_left: null`;
- long one-to-many matching `solution.details.pairs`.

### 6.3 Commands

```powershell
flutter analyze
flutter test
```

State both results in the delivery note. `build_runner` is not required.

---

## 7. Acceptance Criteria

- [ ] After reconnecting, pending answers are sent automatically; the status changes to
      “تم حفظ الإجابات”; closing the app mid-outage does not lose the answer on the
      server once connectivity returns.
- [ ] A transient offline autosave no longer replaces the quiz with a failure screen.
- [ ] Image-only questions show the student’s chosen image and the correct image in
      review; ordering and matching with images do the same.
- [ ] Per-option feedback appears under “إجابتك” only when the chosen option has
      feedback; options without feedback show nothing.
- [ ] Rich question text renders bold and Quran verses; no literal `**` or `﴿ ﴾`
      markers are shown, and raw text is preserved in storage.
- [ ] With an open attempt, the intro CTA reads “متابعة الاختبار” and the confirmation
      no longer says a new attempt is consumed.
- [ ] Reopening after answering question 2 resumes at the first unanswered question, not
      question 1.
- [ ] The result screen shows a labeled “المحاولات المتبقية: غير محدودة” for unlimited
      quizzes.
- [ ] Long matching answers wrap and every pair is visible; no ellipsis truncation.
- [ ] `show_correct_answers == false` still hides solutions on every result path.
- [ ] Arabic RTL and English LTR both render without overflow.
- [ ] No hardcoded UI text; all new keys exist in both JSON files and `LangKeys`.
- [ ] `flutter analyze` and `flutter test` pass.

---

## 8. Out Of Scope

- Admin/dashboard changes from PDF page 9.
- New quiz question types.
- Client-side grading or attempt counting.
- New state-management or networking dependencies.
- Notification/result-routing work already covered by `implement_quize_update.md`.

---

## 9. Suggested Commit Sequence

1. `fix(quiz): retry pending answer saves after reconnection` (Issue 1)
2. `fix(quiz): show option images in review` (Issue 2)
3. `fix(quiz): show per-option feedback in review` (Issue 3)
4. `fix(quiz): render rich question text` (Issue 4)
5. `feat(quiz): continue an open attempt` (Issue 5)
6. `fix(quiz): resume at the first unanswered question` (Issue 6)
7. `fix(quiz): label unlimited attempts on result` (Issue 7)
8. `fix(quiz): wrap long matching answers` (Issue 8)
9. `chore(quiz): localization and regression tests`
