# Queize Test Updates — Implementation Plan

**Status:** plan only. Do not implement code from this document in the same turn.

**Source of truth:** `Quiz_Test_updates.pdf` (10 pages, 14 reported issues).

**Baseline:** current `lib/features/lesson_test`, `lib/features/lesson_detail`,
notification routing, and the existing `implement_quize_update.md`. Where this
document and older notes disagree, this document wins for the 14 PDF items.

**Scope:** student/mobile only. No admin, question-bank, or teacher-review screens.

---

## 0. Execution Contract

1. Work one phase at a time. Do not mix model changes, Cubit changes, and UI changes
   in one commit unless the phase explicitly groups them.
2. Keep the existing `lesson_test` and `lesson_detail` features. Do not create a
   second quiz feature or a second Cubit.
3. The Cubit owns loading, answers, touched state, persistence triggers, submission,
   timeout, retry, and result state.
4. The data source owns backend calls and local persistence. Widgets only render
   state and forward actions.
5. Never grade on the client. Never derive pass/fail or percentages locally.
6. No `BuildContext`, navigation, or localization inside the Cubit.
7. Add every new string to `assets/translations/ar.json`, `assets/translations/en.json`,
   and `lib/core/localization/lang_keys.dart`. Never use raw `'key'.tr()`.
8. `build_runner` is not required. All models use manual `fromJson`/`toJson`.
9. After each phase run `flutter analyze` and `flutter test`.
10. Reuse existing widgets and theme values; do not add ad-hoc colors, spacing, or
    a new dependency for this work.

---

## 1. Issue Map

| # | Reported issue | Root cause | Primary fix area | Phase |
|---|---|---|---|---|
| 1 | Quiz button enabled before article-read confirmation | `LessonDetailBody` disables only on `detail.isLocked` | `lesson_detail` gating | 1 |
| 2 | Rejection shows generic "unavailable" instead of server reason | `QuizErrorMapper._forbiddenKey` falls back to `quiz_unavailable`; state keeps only a key | error mapping + intro body | 1 |
| 3 | Pass-mark explanation truncated | `TestIntroCardRow` value uses `maxLines: 1` + ellipsis | intro card row | 1 |
| 4 | Unanswered question shows "pending teacher review" | `_statusOf` treats every `isCorrect == null` as pending review | result review card | 3 |
| 5 | True/false and matching solutions not shown | `TestSolutionAnswers` reads only `details.correct_answer`; matching returns empty | solution renderer | 3 |
| 6 | "Exit and submit" returns to article without result | `_confirmLeave` pops after `submitAndLeave()` | test screen leave flow | 2 |
| 7 | Timeout returns to article without result | screen pops on `didTimeOut`; body returns time-up before result | test screen/body | 2 |
| 8 | "Back to lessons" opens article detail | button only calls `Navigator.pop()` | result body labels/navigation | 2 |
| 9 | Notification tap does not open attempt result | payload and destination only handle content/live; no attempt id | notification payload/routing | 5 |
| 10 | Exiting with no answers awards an ordering question | ordering answer is pre-filled and submitted even if untouched | touched-answer tracking | 4 |
| 11 | Passed quiz still shows "Go to test" | detail button ignores `hasPassedQuiz`; no result-only load path | detail button + result-only mode | 2/3 |
| 12 | Fill-blank prompt shows `{{1}}` and repeats the sentence | prompt is raw `question_text`; blank widgets render prompt and body | prompt sanitizer | 4 |
| 13 | Answers lost after app reopen/resume | answers exist only in Cubit memory | persistence + resume | 5 |
| 14 | Video reaches 100% but card still says "lesson in progress" and next stays locked | summary badge uses stale `detail.progress`; lists refresh but detail does not | live lesson status | 6 |

---

## 2. Current-Code Facts To Preserve

- `LessonTestCubit.submit()` builds the payload from local answers and skips a
  question only when `!answer.isAnswered(type) && !question.type.isOrdering`
  (`lesson_test_cubit.dart:349`). Ordering is always sent.
- `_initialAnswers()` pre-fills an ordering answer with the server display order
  (`lesson_test_cubit.dart:587-601`).
- `_confirmLeave()` calls `submitAndLeave()` and then pops the route
  (`lesson_test_screen.dart:89-92`).
- The screen listener pops on the first `didTimeOut == true`
  (`lesson_test_screen.dart:101-105`).
- `LessonTestBody._body()` returns `_timeUp` before checking `status == result`
  (`lesson_test_body.dart:45`).
- The result screen's only action always pops one route and is labelled
  `back_to_lessons` (`lesson_test_result_body.dart:69-78`,
  `lesson_test_screen.dart:52`).
- `LessonDetailBody` builds the quiz button with
  `onPressed: detail.isLocked ? null : ...` (`lesson_detail_body.dart:167-184`).
- `LessonDetailScreen` already reloads the lesson after returning from the test when
  `onGoToTest` is supplied (`lesson_detail_screen.dart:50-56`).
- Subject-content and lessons-list screens already reload after returning from lesson
  detail (`subject_content_screen.dart:105-114`,
  `lessons_view_all_screen.dart:133-137`).
- `LessonSummaryCard` receives the whole `detail` and badges `detail.status`
  (`lesson_detail_body.dart:76`, `lesson_summary_card.dart:62`), while the live
  progress is held in `LessonDetailState.progress`.
- `TestSolutionAnswers.of()` reads `result.solution['details']`, handles true/false
  only when the value is a real `bool`, and returns an empty list for matching
  (`test_solution_answers.dart:10-38`).
- `TestResultReviewCard` treats `isCorrect == null` as teacher review
  (`test_result_review_card.dart:102-124`).
- `NotificationDestination.fromPushData()` maps `content`, `live`, and generic
  notifications only; `NotificationPayload` has no attempt id.
- `LessonTestModel.showCorrectAnswers` already exists and is already passed to
  `LessonTestResultBody(showReview: ...)` (`lesson_test_body.dart:84`). This must be
  enforced for every result path added below.

---

## 3. Implementation Phases

### Phase 1 — Access gating and messaging (#1, #2, #3)

#### 1.1 Disable the quiz button until reading is confirmed (#1)

**Files**

- `lib/features/lesson_detail/presentation/refactor/lesson_detail_body.dart`
- `lib/features/lesson_detail/presentation/cubit/lesson_detail_state.dart`
- `lib/features/lesson_detail/presentation/cubit/lesson_detail_cubit.dart`
- `lib/features/lesson_detail/presentation/widgets/lesson_summary_card.dart` (if the
  button lives inside the card in the current layout)
- `lib/features/lesson_detail/presentation/widgets/article_read_button.dart`

**Change**

1. Add a computed flag on `LessonDetailState`:

   ```dart
   bool get canStartQuiz {
     if (!detail.hasQuiz || detail.isLocked || isStarting) return false;
     if (detail.isArticle && !isArticleRead) return false;
     return true;
   }
   ```

   Adjust names to the fields already present. If `isArticleRead` is not on the state,
   add it and set it from the detail response and from a successful read save.

2. Keep the button visible. When `canStartQuiz` is false, render it disabled:
   no navigation callback, muted color, no ripple. Match the existing disabled style
   used by `CustomPrimaryButton`; do not hide the row.
3. Show a short helper note below the button only when it is disabled because of
   reading: `LangKeys.quizArticleNotRead`.
4. Ensure `ArticleReadButton` emits `isSavingRead` and only marks the article read after
   the data source confirms the save. Do not optimistically enable the quiz button on
   tap.
5. If the lesson is a video/audio lesson, use the existing completion/progress rule
   instead of the article-read rule. Do not add a second gating rule for non-articles.

**Tests**

- Cubit test: article lesson with `isArticleRead == false` -> `canStartQuiz == false`;
  after a successful read save -> `true`.
- Widget test: disabled button still visible and does not call the navigation callback.

#### 1.2 Surface the server rejection reason (#2)

**Files**

- `lib/features/lesson_test/data/quiz_error_mapper.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_state.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart`
- `lib/features/lesson_test/presentation/refactor/lesson_test_intro_body.dart`
- `lib/core/utils/error_mapper.dart` (read-only reference)

**Change**

1. Add `String? errorMessage` to `LessonTestState` and clear it through
   `copyWith(clearError: true)`.
2. When `loadQuiz()` or `startAttempt()` catches an `AppException`, store both
   `errorKey` and `errorMessage` (`exception.message`). The Cubit still emits a stable
   key; the message is display data only.
3. Extend `QuizErrorMapper._forbiddenKey` to detect reading/article reasons before the
   generic fallback. Check the reason, message, and field errors for:
   `read`, `reading`, `article`, `complete`, `قراء`, `مقال`, `اكمل`, `أكمل`.
   Map to `LangKeys.quizArticleNotRead`.
4. Keep `quiz_unavailable` as the last-resort fallback.
5. In `LessonTestIntroBody`, render the rejection note as
   `state.errorMessage ?? state.errorKey?.tr()`. When the user taps start and the
   attempt is rejected, also show the same text through `AppToast`.
6. Do not show raw HTML or an untranslated backend enum. If the server message is
   empty, use the mapped key.

**Tests**

- `quiz_error_mapper_test.dart`: 403 with Arabic reading message ->
  `quiz_article_not_read`; 403 with unrelated message -> `quiz_unavailable`.
- Cubit test: `errorMessage` is preserved on start failure.
- Widget test: intro body prefers the server message when present.

#### 1.3 Stop truncating the pass-mark explanation (#3)

**Files**

- `lib/features/lesson_test/presentation/widgets/test_intro_card_row.dart`

**Change**

1. Remove `maxLines: 1` and `overflow: TextOverflow.ellipsis` from the value text.
2. Allow 3 lines or no explicit limit, with `softWrap: true`.
3. Align the row to `CrossAxisAlignment.start`.
4. Keep the label column flexible and the value column expanded so Arabic and English
   both wrap without overflow.
5. Do not shorten the localized string in JSON; fix the layout.

**Tests**

- Widget test with a long Arabic pass-mark sentence: no overflow and the full sentence
  is present in the tree.

---

### Phase 2 — Submit, timeout, and result navigation (#6, #7, #8, #11)

#### 2.1 Show the result after "Exit and submit" (#6)

**Files**

- `lib/features/lesson_test/presentation/screens/lesson_test_screen.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart`
- `lib/features/lesson_test/presentation/refactor/lesson_test_body.dart`

**Change**

1. In `_confirmLeave`, after `cubit.submitAndLeave()` returns `true`, do **not**
   `Navigator.pop()`.
2. The Cubit already emits `status = result` on successful submission. Let the body
   render the result screen in place.
3. Reset `_leaveRequested` after the submission finishes, in all outcomes.
4. If submission fails and the Cubit remains `running`, stay on the question screen and
   surface `messageKey`; do not pop.
5. When the user presses the system back button while the result is visible, pop once to
   the lesson detail. `PopScope.canPop` must allow that on `state.isResult`.
6. Keep the existing leave dialog text unless product decides to rename the action.

**Decision note:** `implement_quize_update.md` later replaces submit-on-leave with
`flushAndLeave()` because the backend keeps attempts resumable. If that contract is
already live in this build, use `flushAndLeave()` instead and show the resumable
question screen; this PDF item only requires that the app never returns to the article
without telling the student what happened. Choose one contract before coding and
document it in the commit.

#### 2.2 Keep timeout on the quiz and show the result (#7)

**Files**

- `lib/features/lesson_test/presentation/screens/lesson_test_screen.dart`
- `lib/features/lesson_test/presentation/refactor/lesson_test_body.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_state.dart`

**Change**

1. Remove the `Navigator.pop()` from the `didTimeOut` branch of `_handleState`. Show the
   timeout toast once, then keep the route alive.
2. In `LessonTestBody._body`, check `state.status == LessonTestStatus.result` **before**
   the `didTimeOut` branch. Preferred order:

   ```text
   failure -> loading -> result -> isTimeUp/running -> intro
   ```

3. While the timeout submission is in flight, render a deliberate time-up state:
   icon, `quiz_time_up`, indeterminate progress, and no fake percentage.
4. If the server accepts the submission, the same screen transitions to the result.
5. If the submission fails, stay on the time-up state with `errorKey` and a refresh or
   retry action. Do not drop the student back to the article.
6. Do not clear local answers on timeout; the submission still needs them.
7. If `implement_quize_update.md`'s `awaitingResult` status exists in this build, route
   timeout to that state and poll/reconcile; otherwise show the result or retry.

**Tests**

- Cubit/screen test: timeout emits result and the route is not popped.
- Body widget test: `status == result && didTimeOut == true` renders the result, not the
  time-up empty view.

#### 2.3 Make the result back action match its destination (#8)

**Files**

- `lib/features/lesson_test/presentation/refactor/lesson_test_result_body.dart`
- `lib/features/lesson_test/presentation/refactor/lesson_test_body.dart`
- `lib/features/lesson_test/presentation/screens/lesson_test_screen.dart`
- `lib/core/localization/lang_keys.dart`
- `assets/translations/ar.json`
- `assets/translations/en.json`

**Change**

1. The current `onBackToLessons` callback only pops one route, so the destination is the
   lesson detail. Rename the callback to `onBackToLesson` and the visible label to
   `back_to_lesson` / "العودة إلى الدرس".
2. Keep a single pop. Do not use `popUntil` to the lessons list unless product explicitly
   wants that behavior; the lesson detail already reloads on return.
3. The result screen must not show two competing back actions. The scaffold back arrow
   and this button do the same thing.

**Tests**

- Widget test: the visible label is the lesson label and tapping invokes the callback
  once.

#### 2.4 Passed quiz opens the result instead of starting again (#11)

**Files**

- `lib/features/lesson_detail/presentation/refactor/lesson_detail_body.dart`
- `lib/features/lesson_detail/presentation/widgets/lesson_test_button.dart`
  (or the current inline button)
- `lib/features/lesson_test/presentation/refactor/lesson_test_args.dart`
- `lib/features/lesson_test/presentation/screens/lesson_test_screen.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart`
- `lib/features/lesson_test/data/data_source/lesson_test_data_source.dart`
- `lib/features/lesson_test/data/repos/lesson_test_repo.dart`
- `lib/core/routing/app_router.dart`

**Change**

1. When `detail.hasPassedQuiz` is true, the detail button label becomes
   `view_result_and_review` ("عرض النتيجة ومراجعة الإجابات").
2. Add an explicit argument mode to `LessonTestArgs`:

   ```text
   LessonTestArgs(lessonId, quizId, attemptId?, resultOnly)
   ```

3. In the router, pass `resultOnly: detail.hasPassedQuiz` together with
   `quizId: detail.quiz!.id` and any attempt id available from `QuizSummaryModel`
   (add `latestAttemptId` if the backend returns it).
4. In the Cubit, add a result-only load path:

   ```text
   Future<void> loadLatestResult()
   ```

   - If `attemptId` is provided and `fetchAttempt` exists, fetch it.
   - Otherwise call `fetchMyAttempts(quizId)` and pick the latest submitted attempt.
   - Emit `result` with the same `quiz` settings so `showCorrectAnswers` still gates the
     review.
   - If no submitted attempt exists, fall back to the normal intro/start flow rather
     than showing an empty result.

5. The button must never start a new attempt when a passed/submitted attempt exists.
6. If the result is still under review, show the result with the pending-review note; do
   not start a new attempt.
7. Guard review rendering with `showCorrectAnswers`. If the quiz settings are unavailable
   in result-only mode, default to `false` and hide solutions rather than leaking them.

**Tests**

- Detail widget test: passed quiz shows the new label and routes in result-only mode.
- Cubit test: result-only mode does not call `startAttempt`; it fetches `my-attempts`
  and emits `result`.
- Negative test: `showCorrectAnswers == false` never renders solution text.

---

### Phase 3 — Result review correctness (#4, #5, and the review half of #11)

#### 3.1 Distinguish "not answered" from "pending teacher review" (#4)

**Files**

- `lib/features/lesson_test/data/models/quiz_question_result_model.dart`
- `lib/features/lesson_test/presentation/widgets/test_result_review_card.dart`
- `lib/features/lesson_test/presentation/refactor/lesson_test_result_body.dart`
- localization files

**Change**

1. Add a model getter, not a widget-only check:

   ```dart
   bool get hasGivenAnswer {
     if (givenAnswer.isNotEmpty) return true;
     if (componentResults.isNotEmpty) return true;
     if (blankResults.isNotEmpty) return true;
     return false;
   }
   ```

   A `false` boolean answer is still a valid given answer because the map is not empty.
2. In `_statusOf`, check in this order:
   1. `isCorrect == true` -> correct.
   2. `isCorrect == false` -> incorrect.
   3. `!hasGivenAnswer` -> not answered (`quiz_not_answered`, muted/outline style).
   4. otherwise -> pending review.
3. Do not treat `isCorrect == null` alone as pending review. Pending review is a
   server-grade state; it may also be inferred from `reviewStatus == 'pending'` on the
   attempt, but unanswered always wins for display.
4. Show the awarded score as `-` or zero for unanswered questions, never as a pending
   score. Do not invent a value.
5. Keep the pending-review banner on the result body tied to
   `result.isPendingReview`, not to individual rows.

**Tests**

- Model test: empty `given_answer` + `is_correct == null` -> `hasGivenAnswer == false`.
- Model test: `given_answer: {'boolean': false}` -> `hasGivenAnswer == true`.
- Widget test: unanswered row shows `quiz_not_answered`; a null-correct answered row
  shows pending review.

#### 3.2 Render true/false and matching solutions (#5)

**Files**

- `lib/features/lesson_test/presentation/refactor/test_solution_answers.dart`
- `lib/features/lesson_test/presentation/widgets/test_result_review_card.dart`
- `lib/features/lesson_test/presentation/widgets/test_result_review.dart`
- `lib/features/lesson_test/data/models/quiz_question_result_model.dart`
- `test/features/lesson_test/`

**Change**

1. Resolve the solution map tolerantly:

   ```text
   solution = result.solution
   details = solution['details'] is Map ? solution['details'] : solution
   ```

   Read values from `details`, then fall back to the top-level `solution` map.
2. True/false:
   - Accept a real `bool`.
   - Accept `'true'`, `'false'`, `'1'`, `'0'`, `1`, `0`.
   - Check `correct_answer`, then `answer`, `value`, `correct_option`, and
     `boolean`.
   - Return the localized `quiz_true` / `quiz_false` label.
3. Matching:
   - Parse `details['pairs']` when it is a list. Each pair may use
     `left`/`right`, `left_text`/`right_text`, `left_id`/`right_id`,
     `source`/`target`, or `item`/`match`.
   - Parse `details['matches']` when it is a map of `rightId -> leftId`.
   - Resolve IDs to display labels through the corresponding `TestQuestionModel`
     (`leftItems`, `rightItems`). If the question is not available, show the raw
     label/id rather than dropping the pair.
   - Render one line per pair, e.g. `left • right`, and de-duplicate.
4. Pass the question into the solution renderer:
   - `TestResultReview` already builds a prompt map; also build a
     `Map<String, TestQuestionModel>` from `result.questions`.
   - `TestResultReviewCard` receives `question` (nullable) and passes it to
     `TestSolutionAnswers.of(result, question: question)`.
5. If `showCorrectAnswers == false`, do not call the renderer at all. The existing
   `showReview` flag is the single gate; keep it authoritative.
6. If the solution shape is unknown, return an empty list and log only in debug. Do not
   throw and do not hide the rest of the review.
7. Add fixtures for at least these shapes:
   - true/false with `details.correct_answer: false`
   - true/false with top-level `correct_answer: 'true'`
   - matching with `details.pairs` labels
   - matching with `details.matches` ID map

**Open item to confirm with the backend:** the exact production `solution` payload for
matching. The parser above is intentionally tolerant, but the fixture must be copied
from a real response before release.

---

### Phase 4 — Answer integrity and prompt rendering (#10, #12)

#### 4.1 Do not submit an untouched ordering question (#10)

**Files**

- `lib/features/lesson_test/data/models/test_answer_model.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_state.dart`
- `lib/features/lesson_test/presentation/widgets/test_order_sentences_question.dart`
- tests

**Change**

1. Add a `bool isTouched` flag to `TestAnswerModel` (default `false`).
2. Mark it `true` only on a real user interaction:
   - option selected/toggled
   - boolean selected
   - blank changed
   - match changed
   - ordering reordered
3. Keep the pre-filled ordering list for display, but do not treat it as an answer.
4. In `submit()`, skip ordering questions when `!answer.isTouched`. Keep the existing
   `isAnswered` rule for all other types.
5. For autosave, send `null` for an untouched ordering answer and for any answer that
   becomes empty. Do not send the display order.
6. On resume, mark restored server/cached answers as touched so a resumed answer is not
   dropped.
7. The "exit and submit" path uses the same touched filter. Exiting without touching any
   question must submit an empty payload and score 0.
8. Remove the `&& !question.type.isOrdering` exception at
   `lesson_test_cubit.dart:349`; replace it with the touched check.

**Tests**

- Cubit test: open an ordering quiz, submit immediately -> payload has no ordering
  answer.
- Cubit test: reorder one item -> payload contains the complete order.
- Cubit test: resume with a server-saved order -> payload contains it and it is marked
  touched.

#### 4.2 Remove `{{n}}` tokens and duplicate prompts from blank questions (#12)

**Files**

- `lib/features/lesson_test/data/models/test_question_model.dart`
- `lib/features/lesson_test/presentation/widgets/test_question_prompt.dart`
- `lib/features/lesson_test/presentation/widgets/test_fill_blanks_question.dart`
- `lib/features/lesson_test/presentation/widgets/test_typed_blanks_question.dart`
- `lib/features/lesson_test/presentation/widgets/test_dropdown_blanks_question.dart`
- `lib/features/lesson_test/presentation/refactor/test_blank_segments.dart`
- tests

**Change**

1. Add display-only getters on `TestQuestionModel`:

   ```dart
   bool get hasBlankTokens => RegExp(r'\{\{\s*\d+\s*\}\}').hasMatch(prompt);
   String get displayPrompt => sanitized prompt;
   ```

   `displayPrompt` removes `{{n}}` tokens, collapses repeated whitespace, and trims.
2. For `fillBlanks` and `typedBlanks`, render the prompt only when:
   - `displayPrompt` is not empty, and
   - the normalized prompt is not equal to the normalized body (ignoring tokens).
3. If the prompt is only the templated sentence, suppress it and let
   `TestBlankText` render the sentence once. Optionally show a static
   "complete the blanks" instruction from localization.
4. Keep the body untouched; `TestBlankSegments.parse(question.body)` remains the source
   of the sentence with blanks.
5. Apply the same rule to dropdown blanks.
6. Do not strip tokens from the body; the body needs them to create blanks.

**Tests**

- Model test: `prompt = 'أكمل: {{1}}'` -> `displayPrompt == 'أكمل:'`.
- Widget test: fill-blank question does not render `{{` in the visible text.
- Widget test: prompt equal to the body is rendered once, not twice.

---

### Phase 5 — Persistence, resume, and notification result (#13, #9)

#### 5.1 Persist answers and restore them on resume (#13)

**Files**

- `lib/features/lesson_test/data/data_source/lesson_test_local_data_source.dart` (new)
- `lib/features/lesson_test/data/models/quiz_attempt_model.dart`
- `lib/features/lesson_test/data/models/test_answer_model.dart`
- `lib/features/lesson_test/data/repos/lesson_test_repo.dart`
- `lib/features/lesson_test/data/data_source/lesson_test_data_source.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart`
- `lib/features/lesson_test/presentation/screens/lesson_test_screen.dart`
- `lib/core/cache/cache_util.dart` (read-only reference)

**Change**

1. Use the server contract from `implement_quize_update.md` first:
   - `PUT /user/quiz-attempts/{attemptId}/answers` on a 1-2 second debounce.
   - Hydrate from `saved_answers` returned by start/fetch.
   - Clear dirty state on success; keep dirty answers on failure.
2. Add a local write-through cache as a safety net so a kill/restart before the next
   autosave does not lose the latest edit:
   - New `LessonTestLocalDataSource` using `CacheUtil`.
   - Key: `lesson_test_answers_<attemptId>`.
   - Value: JSON `{attemptId, quizId, updatedAt, answers: {questionId: payload}}`.
   - Save after every answer change (debounced) and on app pause.
   - Clear on successful submit and when a new attempt starts.
3. Restore order:
   1. Build defaults/display state from the attempt.
   2. Apply the server `saved_answers`.
   3. If the local cache has the same attempt id and a newer `updatedAt`, overlay it and
      mark those answers touched.
   4. Validate restored ordering: keep the saved order only if its length matches and
      every id is known; otherwise keep the server display order untouched.
4. Add `AppLifecycleListener` (or the existing lifecycle observer) in the screen, not the
   Cubit, to call `cubit.flushAnswers()` on pause/inactive. The Cubit remains context
   free.
5. If the autosave endpoint is not deployed yet, ship the local cache first and leave a
   TODO-free comment in the code documenting that server `saved_answers` takes
   precedence when present. Do not silently drop server answers.
6. Show a small saving/saved/unsaved indicator in the running header, following
   `implement_quize_update.md` §7.1. Use a fixed-height row so the question does not
   shift.

**Tests**

- Local data source round-trip test.
- Cubit test: start, answer, simulate dispose/recreate with same attempt id, answers
  restored.
- Cubit test: a corrupt cache entry is ignored, not thrown.
- Cubit test: successful submit clears both dirty state and the local cache.

#### 5.2 Open the attempt result from a notification (#9)

**Files**

- `lib/features/notifications/data/models/notification_payload.dart`
- `lib/features/notifications/data/models/notification_model.dart` (if payload is
  embedded there)
- `lib/core/routing/notification_destination.dart`
- `lib/core/services/notification_launcher.dart`
- `lib/core/routing/app_router.dart`
- `lib/core/routing/app_routes.dart`
- `lib/features/lesson_test/presentation/refactor/lesson_test_args.dart`
- `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart`
- `lib/features/lesson_test/data/data_source/lesson_test_data_source.dart`

**Change**

1. Extend `NotificationPayload` with:
   - `action`
   - `attemptId`
   - `quizId`
   - `contentId`
   - `autoSubmitted`
   - `notificationId`
2. Parse both string and numeric JSON values. Do not depend on key order or `data` being
   a nested map only.
3. Add a `quizResult` destination kind. Routing rules:
   1. `action == 'open_quiz_result'` and `attemptId > 0` -> open the test screen in
      result-only mode for that attempt.
   2. If the attempt cannot be loaded -> open lesson detail with `contentId`.
   3. Otherwise -> notifications list.
4. Pass the notification destination through the existing push handling; do not add a
   second notification service.
5. In `LessonTestArgs`, support:
   - `attemptId`
   - `quizId`
   - `resultOnly`
   - optional `lessonId` for the fallback back action
6. `LessonTestCubit` result-only contract:
   - `GET /user/quiz-attempts/{attemptId}` if the endpoint exists.
   - Otherwise `fetchMyAttempts(quizId)` and match `attemptId`.
   - If matched, emit `result`.
   - If not matched, show `failure` with `quiz_unavailable` and a retry; do not start a
     new attempt.
7. Deduplicate: if the same attempt result is already the top route, do not push another
   copy.
8. If `show_correct_answers` is unavailable in the notification payload, fetch the quiz
   overview or default to hiding solutions. Never show solutions by default.

**Tests**

- `notification_destination_test.dart`: quiz-result payload -> result route; missing
  attempt id -> lesson fallback; unknown action -> notifications.
- Cubit test: result-only load does not start an attempt.
- Router test: duplicate attempt push is suppressed.

---

### Phase 6 — Live lesson status and unlock (#14)

**Files**

- `lib/features/lesson_detail/presentation/refactor/lesson_detail_body.dart`
- `lib/features/lesson_detail/presentation/widgets/lesson_summary_card.dart`
- `lib/features/lesson_detail/presentation/cubit/lesson_detail_state.dart`
- `lib/features/lesson_detail/presentation/cubit/lesson_detail_cubit.dart`
- `lib/features/lesson_detail/data/models/lesson_detail_model.dart`
- `lib/features/lessons/presentation/screens/lessons_view_all_screen.dart`
- `lib/features/subject_content/presentation/screens/subject_content_screen.dart`
- tests

**Change**

1. `LessonSummaryCard` must take live display values, not a stale `LessonDetailModel`
   status. Pass:
   - `status: LessonStatus.resolve(...)` built from `state.progress` and
     `state.isArticleRead`
   - `progressPercent` from `state.progress`
2. Replace `detail.status` usage in the card with the passed status. The card remains a
   dumb widget; the screen/body computes the status from Cubit state.
3. When video progress reaches 100%, the Cubit must update `state.progress` immediately
   from the completion/report response. The card then rebuilds to completed without a
   reload.
4. On returning from the test, `LessonDetailScreen` already calls `loadLesson()` when
   `onGoToTest` is supplied. Keep that. Ensure the reload also updates `quiz.hasPassed`
   and `isLocked`.
5. On returning from lesson detail, subject-content and lessons-list already reload
   (`subject_content_screen.dart:105-114`, `lessons_view_all_screen.dart:133-137`).
   Verify both are used for every entry point; do not add a second refresh mechanism.
6. The next lesson's lock is server-owned. Do not unlock it locally. After a passing
   blocking quiz, refresh the list/detail and let the server return the new `is_locked`.
7. If the completion call is still in flight, show the existing inline loading state; do
   not flip the badge optimistically.

**Tests**

- Cubit test: progress update to 100% recomputes `LessonStatus.completed`.
- Widget test: summary card receives live completed status and does not read
  `detail.status`.
- Integration/manual test: finish a video, return to subject content, next lesson is
  unlocked after refresh.

---

### Phase 7 — Localization, tests, and verification

#### 7.1 Localization keys

Add to `lib/core/localization/lang_keys.dart` and both JSON files. Arabic first.

| Key | Arabic | English |
|---|---|---|
| `quiz_article_not_read` | `أكّد الانتهاء من قراءة المقالة قبل بدء الاختبار.` | `Confirm you finished reading the article before starting the quiz.` |
| `quiz_not_answered` | `لم تتم الإجابة` | `Not answered` |
| `back_to_lesson` | `العودة إلى الدرس` | `Back to lesson` |
| `view_result_and_review` | `عرض النتيجة ومراجعة الإجابات` | `View result and review answers` |
| `quiz_saving` | `جارٍ حفظ الإجابات...` | `Saving answers...` |
| `quiz_saved` | `تم حفظ الإجابات` | `Answers saved` |
| `quiz_unsaved` | `تغييرات غير محفوظة` | `Unsaved changes` |
| `quiz_save_failed` | `تعذر حفظ الإجابات` | `Could not save answers` |
| `quiz_time_up` | existing | existing |
| `quiz_awaiting_result` | `جارٍ تجهيز النتيجة...` | `Preparing your result...` |
| `quiz_result_pending_refresh` | `تحديث النتيجة` | `Refresh result` |
| `quiz_result_unavailable` | `تعذر تحميل نتيجة المحاولة` | `Could not load the attempt result` |

Rules:

- Add the `LangKeys` constant before using the key.
- Do not use the server message as a translation key. `errorMessage` is display-only.
- Keep `back_to_lessons` only if another screen still uses it; otherwise remove it from
  the quiz result usage and leave the shared key untouched.

#### 7.2 Tests to add or update

- `test/features/lesson_test/quiz_error_mapper_test.dart`
  - reading rejection mapping
  - generic 403 fallback
- `test/features/lesson_test/quiz_models_test.dart`
  - `hasGivenAnswer` for empty/non-empty answers
  - true/false solution variants
  - matching solution variants
  - `displayPrompt` token stripping
- `test/features/lesson_test/lesson_test_cubit_test.dart`
  - ordering untouched -> empty payload
  - ordering touched -> complete payload
  - timeout -> result, no pop
  - submit-and-leave -> result state
  - result-only load does not start an attempt
  - answer restore from saved/local data
  - submit clears cache
- Widget tests
  - disabled quiz button before article read
  - pass-mark wrapping
  - unanswered status row
  - matching solution rows
  - blank prompt renders once and has no `{{`
  - result back label
- `test/notification_destination_test.dart`
  - quiz-result notification routing and fallbacks

#### 7.3 Commands

```text
flutter analyze
flutter test
```

State both results in the delivery note. `build_runner` is not required.

---

## 4. Recommended Commit Sequence

1. `fix(quiz): gate start on article read and show rejection reason` (#1, #2)
2. `fix(quiz): wrap pass-mark note` (#3)
3. `fix(quiz): keep result visible after submit and timeout` (#6, #7)
4. `fix(quiz): correct result back action and passed-quiz entry` (#8, #11)
5. `fix(quiz): distinguish unanswered from pending review` (#4)
6. `fix(quiz): render true/false and matching solutions` (#5)
7. `fix(quiz): stop submitting untouched ordering answers` (#10)
8. `fix(quiz): sanitize blank prompts` (#12)
9. `feat(quiz): persist and restore in-progress answers` (#13)
10. `feat(notifications): open quiz result attempts` (#9)
11. `fix(lesson): use live completion status` (#14)
12. `chore(quiz): localization and regression tests`

---

## 5. Acceptance Criteria

- [ ] Article quiz button is visible, disabled before read confirmation, and enabled only
      after a confirmed save.
- [ ] A rejected start shows the server reason, including the article-read message.
- [ ] The pass-mark explanation wraps and is fully readable in Arabic and English.
- [ ] Unanswered questions show "not answered"; only genuinely reviewed answers show
      "pending review".
- [ ] True/false and matching correct answers appear when review is enabled.
- [ ] "Exit and submit" never returns to the article without a result or a clear
      pending/failure state.
- [ ] Timeout never pops to the article; it submits/reconciles and shows the result or a
      retry state.
- [ ] The result button label matches the lesson detail destination.
- [ ] Notification taps open the specific attempt result, with a lesson fallback.
- [ ] Exiting without touching any question does not award an ordering question.
- [ ] A passed quiz opens its result and review, not a new attempt.
- [ ] Fill-blank screens do not display `{{n}}` and do not repeat the sentence.
- [ ] Answers survive app restart/resume for the same attempt.
- [ ] A completed video immediately shows completed, and the next lesson unlocks after
      the server refresh.
- [ ] `show_correct_answers == false` never renders solution text on any result path.
- [ ] `flutter analyze` and `flutter test` pass.

---

## 6. Open Questions To Confirm Before Coding

1. **Leave contract:** keep the current "Exit and submit" behavior and show the result,
   or adopt `implement_quize_update.md`'s `flushAndLeave()` and leave the attempt
   resumable? The PDF expects a result, while the newer plan expects no submission on
   leave. Pick one before Phase 2.
2. **Matching solution payload:** confirm whether the backend sends `details.pairs`,
   `details.matches`, or another shape. The tolerant parser handles common shapes, but
   the fixture must be real.
3. **Attempt-by-id endpoint:** `implement_quize_update.md` specifies
   `GET /user/quiz-attempts/{attemptId}`. If it is not deployed, result-only mode must
   use `fetchMyAttempts(quizId)` and match the id.
4. **Result back target:** confirm "Back to lesson" is acceptable for the PDF item, rather
   than popping to the lessons list.
5. **Notification settings source:** in result-only mode, where should
   `show_correct_answers` come from if the notification payload omits it? Recommended:
   fetch the quiz overview and default to hidden on failure.
