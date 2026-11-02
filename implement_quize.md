# Implementation Plan â€” Lesson Quizzes (Student App)

**Status:** plan only. Do not implement code from this document in the same turn.

**Source of truth:** `queiz.md` in the project root, itself summarized from
`https://bilhikma.tech/guides/11a59d713e63542b/`.

**Scope:** the student/mobile flow only. Admin question-bank, quiz-editor, publishing,
attempt-monitoring, and answer-review screens are out of scope.

---

## 0. Execution Contract

1. Work one phase at a time. Do not mix model refactors with UI changes.
2. Use this exact phase order:
   1. API endpoints, API/session policy, models and parsers.
   2. Data source, repository and error mapping.
   3. Lesson-detail integration and route arguments.
   4. Cubit and state machine.
   5. Question widgets and student UI.
   6. Result integration and localization.
   7. Fixtures, tests, cleanup and final verification.
3. Preserve the existing `lesson_test` feature and migrate it. Do not create a second
   quiz feature.
4. Never grade on the client. The app renders server data and submits IDs.
5. Never depend on `is_correct` or correct options before submission. They are absent
   during an attempt and only appear in `solution` when the server allows it.
6. Keep Cubits free of `BuildContext`, navigation, and localization.
7. Keep screens short. Put section logic in `presentation/refactor` and small widgets
   in `presentation/widgets`.
8. Add every new UI string to `assets/translations/ar.json` and
   `assets/translations/en.json`.
9. After each phase run:
   - `flutter analyze`
   - `flutter test`
10. `build_runner` is not required for this plan unless model annotations are added.
11. First milestone is Phase 1 only. Do not touch the existing quiz UI, Cubit, or mock
    grader in that milestone.
12. Validate parsers and serializers against representative staging fixtures, not one
    response. At minimum capture: quiz overview, attempt with all seven types,
    dropdown blanks, word-bank blanks, successful submission, pending-review
    submission, and a response where `solution` is absent. The guide remains the
    primary contract; staging payloads are the final compatibility check.

---

## 1. Verified Server Contract

### 1.1 Endpoints used by the app

| Purpose | Method | Path | Success |
|---|---|---|---|
| Lesson detail, includes quiz summary | `GET` | `/user/content/{lessonId}` | `200` |
| Quiz overview | `GET` | `/user/content/{lessonId}/quiz` | `200` |
| Start or resume an attempt | `POST` | `/user/quizzes/{quizId}/attempts` | `201` |
| Submit all answers | `POST` | `/user/quiz-attempts/{attemptId}/submit` | `200` |
| Attempt history (optional) | `GET` | `/user/quizzes/{quizId}/my-attempts` | `200` |

Do not call `/admin/...` from the mobile app.

### 1.2 Quiz summary inside lesson detail

```json
"quiz": { "id": 2, "is_blocking": true, "has_passed": true }
```

`quiz` is `null` when the lesson has no published quiz. The â€œGo to quizâ€‌ button must
be shown only when this object exists.

### 1.3 Quiz overview

Key fields:

- `id`, `content_id`, `title`, `instructions`
- `pass_score`, `max_attempts`, `retry_cooldown_minutes`
- `time_limit_minutes` (`null` means no total timer)
- `shuffle_questions`, `is_blocking`, `show_correct_answers`, `is_published`
- `selection_mode`, `question_count`, `total_score`
- `attempts_used`, `attempts_left` (`null` means unlimited)
- `has_passed`, `next_attempt_at` (ISO date or `null`)

`GET /user/content/{id}/quiz` status handling:

- `200`: show start screen.
- `404`: no published quiz / not found for this student.
- `403`: lesson locked, quiz unavailable, or the lesson video is not 100% watched.
- `401`: refresh-token flow / session end.

### 1.4 Attempt response

`POST /user/quizzes/{quizId}/attempts` returns `201` with a full attempt:

- `id`, `quiz_id`, `student_id`, `attempt_no`
- `max_score`, `review_status` (`none` during attempt)
- `started_at`, `expires_at`, `has_expired`
- `policy_snapshot` (`pass_score`, `is_blocking`, `max_attempts`,
  `shuffle_questions`, `time_limit_minutes`, `retry_cooldown_minutes`)
- `answers[]`, one item per question in the server-fixed order.

Each `answers[]` item:

- `question_id`, `question_text`, `question_type`, `score`
- `options` (display data only)
- `selected_option_id`, `selected_boolean`, `answer_text`
- `is_correct`, `awarded_score`, `given_answer` (`null` during attempt)

The `options.details` object contains the type-specific display data:

- choice types: `details.options[]` with `id`, `text`, `image_path`
- choice types also expose `choice_variant` (`standard` / `best_answer`)
- multiple choice: `details.max_selections`
- fill-blank: `details.blanks[]` plus either `details.word_bank[]` or per-blank
  `choices[]`; `details.blank_input_mode` is `word_bank` or `dropdown`
- typed blank: `details.blanks[]` with `id`, `max_length`, `blank_index`,
  `placeholder`, `score_weight`
- matching: `details.pairs.left[]` and `details.pairs.right[]`; right may contain
  distractors
- ordering: `details.items[]`, already shuffled by the server

`options.default_time_seconds` is the optional per-question timer. It is display-only
unless the backend later confirms enforcement. The attempt-level `expires_at` is the
authoritative total timer.

### 1.5 Submit payload

Submit exactly one object keyed by question ID:

```json
{
  "answers": {
    "21": { "option_id": "o_1" },
    "22": { "option_ids": ["o_1", "o_2"] },
    "23": { "boolean": false },
    "14": { "blanks": { "b_1": "c_1" } },
    "15": { "blanks": { "b_1": "ظ†طµ ظ…ظƒطھظˆط¨" } },
    "16": { "matches": { "6j0kdku2": "p_1", "ywmervxe": "p_2" } },
    "17": { "order": ["i_1", "i_2", "i_3", "i_4"] }
  }
}
```

Rules:

- IDs are sent exactly as received from `options.details`.
- `true_false` sends a real JSON boolean, never the strings `"true"` / `"false"`.
- `matching` maps **right ID â†’ left ID**. This is the opposite direction of the
  current mock model.
- `ordering` must include every item exactly once, in the studentâ€™s chosen order.
- Unanswered questions may be omitted. Do not send an empty/invalid object for an
  unanswered question unless it is an ordering question, which always has an order.
- `mcq_multiple` must not exceed `max_selections`.
- Word-bank non-reusable words must not fill two blanks.

### 1.6 Submission result

`POST /user/quiz-attempts/{attemptId}/submit` returns `200` with:

- `score`, `max_score`, `score_percent`, `is_passed`
- `review_status` (`none` / `pending` / `resolved`)
- `attempts_used`, `attempts_left`, `next_attempt_at`
- per-answer `is_correct`, `awarded_score`, `given_answer`
- `blank_results`, `component_results`
- `solution` only when `show_correct_answers = true`

Do not recompute pass/fail or percentages. Use server values directly.

### 1.7 Rules that must shape the state machine

- One quiz per lesson.
- Draft quizzes are invisible to students.
- Structure freezes after the first attempt. The app never edits quiz structure.
- Server grades everything.
- A blocking quiz keeps the next lesson locked until the student passes.
- A pending typed-answer review keeps the result preliminary and the next lesson
  locked when the quiz is blocking.
- Video lessons cannot start a quiz before the video is 100% watched (`403`).
- Re-requesting an open attempt returns the same attempt; question order does not
  change.

---

## 2. Current Code Audit

### 2.1 What already exists

| Area | Current implementation | Decision |
|---|---|---|
| Quiz overview | `LessonTestModel` with mock fields | Keep the file/class where practical, rewrite parsing to the real quiz-overview contract |
| Question model | `TestQuestionModel` built for mock JSON | Rewrite to parse `answers[]` from an attempt |
| Answer model | `TestAnswerModel` with `optionIds`, `blanks`, `pairs`, `order` | Extend with real boolean and API serialization |
| Result model | `TestResultModel` with client-style counts | Replace with server-result fields |
| Data source | mock JSON + local grader | Replace with real API calls; delete local grading |
| Repo | thin wrapper | Extend with fetch quiz, start attempt, submit attempt |
| Cubit | load â†’ start â†’ running â†’ submit with local grading | Replace with server-driven state machine |
| Screen | `LessonTestScreen` creates cubit directly | Keep direct creation; inject repo for tests |
| Lesson detail | does not parse `quiz` | Add quiz summary and conditionally show the button |
| Routing | `LessonTestArgs(lessonId: '${detailArgs.id}')` | Change to `int` and carry lesson context |
| Localization | existing generic test keys | Reuse and add quiz-specific keys |

### 2.2 Existing assets to keep

Keep and adapt:

- `LessonTestScreen` and `LessonTestBody` phase routing.
- `LessonTestIntroBody` layout.
- `LessonTestQuestionBody` and `TestQuestionView` type switch.
- `CustomButton` (already supports `isLoading`).
- `AppErrorView`, `AppEmptyView`, `AppSectionScaffold`.
- Existing timer/result/intro widgets where their API still fits.

### 2.3 What must be removed or stopped

- `LessonTestMock` from production paths. Keep fixture copies under `test/` only.
- `TestAnswerGrader` and all client-side correct-answer logic. Delete after model
  migration and tests pass.
- `TestQuestionModel.correctOptionIds`, `mostCorrectOptionId`, `correctSentenceIds`,
  and similar grader-only getters from production models.
- `TestShuffle` use for ordering. The server already shuffles ordering items and fixes
  the order for the attempt. Do not shuffle again.
- `TestQuestionType.mostCorrect` as a separate input type. `best_answer` is still
  `mcq_single`; it only changes presentation/copy.
- The local idea that `match_pairs` pairs have a single `id` shared by prompt and match.
  The real API has separate left/right item IDs.

### 2.4 Critical integration risk: `403` must not sign the student out

`ErrorMapper.sessionEndedCodes` currently treats `403` as a session-ending code, and
`ApiClient._send` always calls `SessionGuard.endIfRefused`. Quiz endpoints legitimately
return `403` for:

- locked lesson / quiz unavailable
- video not fully watched
- attempt belonging to another student

**Required change:** add an endpoint/session policy so quiz `403` responses do not
force sign-out.

Critical detail: `AuthInterceptor.onError` also ends the session on `403` before
`ApiClient._send` ever sees the response. Changing only `ApiClient` is insufficient.
Both paths must use the same policy.

Recommended implementation:

1. Add `final bool endSessionOnForbidden;` to `ApiClient` with default `true`
   (preserve existing callers).
2. Add a pure `SessionPolicy` helper, e.g.
   `lib/core/network/session_policy.dart`:
   - `shouldEndStatus(int? statusCode, {required bool endOnForbidden})`
   - `shouldEnd(AppException error, {required bool endOnForbidden})`
   Both return false for `403` when `endOnForbidden == false`; `401` behavior is
   unchanged.
3. Use `SessionPolicy.shouldEnd(...)` in `ApiClient._send` instead of calling
   `SessionGuard.endIfRefused` unconditionally.
4. In `AuthInterceptor.onError`, skip the `403` logout branch when the request was
   marked as quiz traffic. Mark it with request `extra`, not by URL string matching:
   - `ApiClient` passes `extra: {'end_session_on_forbidden': false}` when its flag is
     false.
   - `DioService.get/post/put/patch/delete` must accept and forward
     `Map<String, dynamic>? extra` via `Options(extra: extra)`.
   - `AuthInterceptor` reads
     `requestOptions.extra['end_session_on_forbidden'] != false` before treating
     `403` as session-ending. `401` refresh/retry remains untouched.
5. Construct the quiz data source with
   `const ApiClient(endSessionOnForbidden: false)`.
6. In the quiz data source, translate `403` into a quiz-specific key instead of
   surfacing `session_expired`.
7. Add a focused unit test for `SessionPolicy` before integrating quiz traffic:
   - `403` + `endOnForbidden: true` -> ends session.
   - `403` + `endOnForbidden: false` -> does not end session.
   - `401` -> always follows the normal refresh/session path.

Current `SessionGuard` refusal call sites are `ApiClient._send` and
`AuthInterceptor.onError`; `DeviceInterceptor` and `security_guard.dart` call
`forceSignOut` for device/security reasons and are unrelated. Re-check this search
before implementing. Do not globally remove `403` from `ErrorMapper` without checking
account-state refusals elsewhere in the app. `AppException.errors` is already
`Map<String, List<String>>`, so `errors.values.expand((e) => e)` is valid.

Expected shape:

```dart
class ApiClient {
  const ApiClient({this.endSessionOnForbidden = true});

  final bool endSessionOnForbidden;

  // All request methods forward this request extra when the flag is false:
  // <String, dynamic>{'end_session_on_forbidden': false}
}
```

### 2.5 `packages/lesson_test_kit`

The directory contains only `.dart_tool` state; there is no package source and no
`pubspec.yaml` wiring in the app. Do not depend on it. Either ignore it or remove it
in a separate cleanup task.

---

## 3. Target Architecture

```
LessonDetailModel.quiz (summary)
        â”‚ hasQuiz
        â–¼
LessonDetailBody button
        â”‚ push lesson-test with lesson context
        â–¼
LessonTestScreen
        â”‚ creates
        â–¼
LessonTestCubit â”€â”€> LessonTestRepo â”€â”€> LessonTestDataSource â”€â”€> ApiClient
        â”‚                                      â”‚
        â”‚                                      â”œâ”€ GET  /user/content/{id}/quiz
        â”‚                                      â”œâ”€ POST /user/quizzes/{id}/attempts
        â”‚                                      â””â”€ POST /user/quiz-attempts/{id}/submit
        â–¼
LessonTestState â†’ intro / running / result
```

### 3.1 Planned file map

| Action | File |
|---|---|
| Modify | `lib/core/constants/api_endpoints.dart` |
| Modify | `lib/core/network/api_client.dart` |
| Create | `lib/core/network/session_policy.dart` |
| Modify | `lib/core/services/dio_service.dart` |
| Modify | `lib/core/interceptors/auth_interceptor.dart` |
| Modify | `lib/features/lesson_detail/data/models/lesson_detail_model.dart` |
| Create | `lib/features/lesson_detail/data/models/quiz_summary_model.dart` |
| Modify | `lib/features/lesson_detail/presentation/refactor/lesson_detail_body.dart` |
| Modify | `lib/features/lesson_detail/presentation/screens/lesson_detail_screen.dart` |
| Modify | `lib/core/routing/app_router.dart` |
| Modify | `lib/features/lesson_test/presentation/refactor/lesson_test_args.dart` |
| Rewrite | `lib/features/lesson_test/data/models/lesson_test_model.dart` |
| Rewrite | `lib/features/lesson_test/data/models/test_question_model.dart` |
| Rewrite | `lib/features/lesson_test/data/models/test_option_model.dart` |
| Rewrite | `lib/features/lesson_test/data/models/test_blank_model.dart` |
| Create | `lib/features/lesson_test/data/models/test_match_item_model.dart` |
| Rewrite | `lib/features/lesson_test/data/models/test_sentence_model.dart` |
| Create | `lib/features/lesson_test/data/models/quiz_attempt_model.dart` |
| Create | `lib/features/lesson_test/data/models/quiz_policy_model.dart` |
| Create | `lib/features/lesson_test/data/models/quiz_question_result_model.dart` |
| Rewrite | `lib/features/lesson_test/data/models/test_answer_model.dart` |
| Delete | `lib/features/lesson_test/data/models/test_result_model.dart` after moving result UI to `QuizAttemptModel` |
| Rewrite | `lib/features/lesson_test/data/data_source/lesson_test_data_source.dart` |
| Create | `lib/features/lesson_test/data/quiz_error_mapper.dart` |
| Modify | `lib/features/lesson_test/data/repos/lesson_test_repo.dart` |
| Rewrite | `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart` |
| Rewrite | `lib/features/lesson_test/presentation/cubit/lesson_test_state.dart` |
| Modify | `lib/features/lesson_test/presentation/screens/lesson_test_screen.dart` |
| Modify | `lib/features/lesson_test/presentation/refactor/lesson_test_body.dart` |
| Modify | `lib/features/lesson_test/presentation/refactor/lesson_test_intro_body.dart` |
| Modify | `lib/features/lesson_test/presentation/refactor/lesson_test_question_body.dart` |
| Modify | `lib/features/lesson_test/presentation/refactor/lesson_test_result_body.dart` |
| Modify | `lib/features/lesson_test/presentation/refactor/test_question_view.dart` |
| Modify | `lib/features/lesson_test/presentation/widgets/test_choice_question.dart` |
| Modify | `lib/features/lesson_test/presentation/widgets/test_fill_blanks_question.dart` |
| Create | `lib/features/lesson_test/presentation/widgets/test_dropdown_blanks_question.dart` |
| Modify | `lib/features/lesson_test/presentation/widgets/test_typed_blanks_question.dart` |
| Modify | `lib/features/lesson_test/presentation/widgets/test_match_pairs_question.dart` |
| Modify | `lib/features/lesson_test/presentation/widgets/test_order_sentences_question.dart` |
| Modify | `lib/features/lesson_test/presentation/widgets/test_nav_buttons.dart` |
| Modify | `lib/features/lesson_test/presentation/widgets/test_progress_header.dart` |
| Modify | `lib/features/lesson_test/presentation/widgets/test_result_headline.dart` |
| Modify | `lib/features/lesson_test/presentation/widgets/test_result_score_card.dart` |
| Modify | `lib/features/lesson_test/presentation/widgets/test_retry_note.dart` |
| Create | `lib/core/localization/lang_keys.dart` (quiz keys only) |
| Modify | `assets/translations/ar.json` |
| Modify | `assets/translations/en.json` |
| Delete | `lib/features/lesson_test/data/data_source/lesson_test_mock.dart` |
| Delete | `lib/features/lesson_test/data/data_source/test_answer_grader.dart` |
| Delete | `lib/features/lesson_test/data/models/test_pair_model.dart` after replacing usages |
| Create | `test/features/lesson_test/fixtures/*.json` |
| Create | `test/features/lesson_test/*_test.dart` |

---

## 4. Phase 1 â€” Endpoints and Models

**Milestone rule:** this phase changes endpoints, session policy, and models only. Do
not edit the existing quiz UI, Cubit, or mock grader yet. Finish and test the model
parsers and serializers before starting Phase 2.

### 4.1 Endpoint constants

Add to `ApiEndpoints`:

```dart
static String contentQuiz(int contentId) => '/user/content/$contentId/quiz';

static String quizAttempts(int quizId) => '/user/quizzes/$quizId/attempts';

static String quizAttemptSubmit(int attemptId) =>
    '/user/quiz-attempts/$attemptId/submit';

static String quizMyAttempts(int quizId) =>
    '/user/quizzes/$quizId/my-attempts';
```

### 4.2 `QuizSummaryModel`

Create `lib/features/lesson_detail/data/models/quiz_summary_model.dart`:

```dart
class QuizSummaryModel {
  const QuizSummaryModel({
    required this.id,
    this.isBlocking = false,
    this.hasPassed = false,
  });

  final int id;
  final bool isBlocking;
  final bool hasPassed;

  factory QuizSummaryModel.fromJson(Map<String, dynamic> json) =>
      QuizSummaryModel(
        id: Json.asInt(json['id']),
        isBlocking: Json.asBool(json['is_blocking']),
        hasPassed: Json.asBool(json['has_passed']),
      );
}
```

Modify `LessonDetailModel`:

- import `QuizSummaryModel`
- add `final QuizSummaryModel? quiz;`
- constructor `this.quiz`
- parse with `Json.asOptionalMap(data['quiz'])`
- add `bool get hasQuiz => quiz != null;`
- add `bool get isQuizBlocking => quiz?.isBlocking ?? false;`
- add `bool get hasPassedQuiz => quiz?.hasPassed ?? false;`

Do not parse `quiz` with `Json.asMap` directly; `null` must remain `null`.

### 4.3 `LessonTestModel` (quiz overview)

Rewrite `lesson_test_model.dart` to represent the real overview:

```text
id                 int
contentId          int
title              String
instructions       String?
passScore          int        // server may default to 50 when null
maxAttempts        int?       // null = unlimited
retryCooldownMin   int
timeLimitMinutes   int?       // null = no total timer
shuffleQuestions   bool
isBlocking         bool
showCorrectAnswers bool
isPublished        bool
selectionMode      String
questionCount      int
totalScore         double
attemptsUsed       int
attemptsLeft       int?       // null = unlimited
hasPassed          bool
nextAttemptAt      DateTime?
```

Parsing rules:

- `pass_score`: use `Json.asOptionalInt`, fallback `50` when absent.
- `max_attempts`, `time_limit_minutes`, `attempts_left`: keep `null` as unlimited.
- `next_attempt_at`: `Json.asDateTime`.
- `total_score`: `Json.asDouble`.
- `questionCount` is server-provided; do not derive from a question list that is not
  present in this response.

Add convenience getters:

```text
bool get hasTimeLimit => timeLimitMinutes != null && timeLimitMinutes! > 0;
bool get hasUnlimitedAttempts => attemptsLeft == null;
bool get hasAttemptsLeft => attemptsLeft == null || attemptsLeft! > 0;
bool get isInCooldown => nextAttemptAt?.isAfter(DateTime.now()) ?? false;
```

Remove `questions` from the overview. The questions arrive only from the attempt.

### 4.4 `TestQuestionType`

Update `lib/core/enums/test_question_type_enum.dart` to the API vocabulary:

```dart
enum TestQuestionType {
  singleChoice('mcq_single'),
  multiChoice('mcq_multiple'),
  trueFalse('true_false'),
  fillBlanks('fill_blank_choice'),
  typedBlanks('fill_blank_typed'),
  matchPairs('matching'),
  orderSentences('ordering');

  const TestQuestionType(this.key);

  final String key;

  bool get isMultiSelect => this == multiChoice;

  bool get isTrueFalse => this == trueFalse;

  bool get isOrdering => this == orderSentences;

  static TestQuestionType fromJson(Object? value) {
    final String key = (value ?? '').toString().toLowerCase().trim();

    return TestQuestionType.values.firstWhere(
      (TestQuestionType type) => type.key == key,
      orElse: () => throw const FormatException('unsupported_question_type'),
    );
  }
}
```

Notes:

- Do not silently default to `singleChoice` on an unknown type. A silent default would
  submit the wrong answer shape and produce `422`.
- `choice_variant == 'best_answer'` remains `singleChoice`; expose a separate
  `isBestAnswer` boolean on the question model for copy/presentation.

Add a typed input mode instead of `String? blankInputMode`:

```dart
enum BlankInputMode {
  wordBank('word_bank'),
  dropdown('dropdown');

  const BlankInputMode(this.key);

  final String key;

  static BlankInputMode fromJson(Object? value) {
    final String key = (value ?? '').toString().toLowerCase().trim();

    return BlankInputMode.values.firstWhere(
      (BlankInputMode mode) => mode.key == key,
      orElse: () => throw const FormatException('unsupported_blank_input_mode'),
    );
  }
}
```

Unknown values must throw a controlled parsing error, not silently fall back to
word-bank mode.

### 4.5 `TestQuestionModel` (attempt display model)

Rewrite `TestQuestionModel` to parse one `answers[]` item. Fields:

```text
id                  String     // question_id as string
type                TestQuestionType
prompt              String     // question_text
body                String?    // for fill-blank template, normalized
score               double
timeLimit           Duration? // options.default_time_seconds
isBestAnswer        bool       // choice_variant == best_answer
maxSelections       int?       // mcq_multiple
blankInputMode      BlankInputMode? // word_bank / dropdown
options             List<TestOptionModel>
blanks              List<TestBlankModel>
wordBank            List<TestOptionModel>
leftItems           List<TestMatchItemModel>
rightItems          List<TestMatchItemModel>
sentences           List<TestSentenceModel> // ordering items, display order
```

Type-specific parsing:

- **Choice (`mcq_single`, `mcq_multiple`)**
  - `options = details.options`
  - `isBestAnswer = details.choice_variant == 'best_answer'`
  - `maxSelections = details.max_selections` (only multiple)
- **True/false**
  - `options` is empty. Do not synthesize API option IDs.
  - The UI renders two choices and the answer stores a real `bool`.
- **Fill by choice**
  - `blankInputMode = BlankInputMode.fromJson(details.blank_input_mode)`
  - `blanks = details.blanks`
  - Word bank: `wordBank = details.word_bank`
  - Dropdown: each blank has `choices`; expose them per blank and/or flatten into
    `options` only for lookup.
  - Normalize placeholders:
    - `question_text` often contains `{{1}}`, `{{2}}`, while blank IDs are `b_1`,
      `b_2`.
    - Build `body` by replacing `{{<blank_index>}}` with
      `{{<blank.id>}}` using each blankâ€™s `blank_index`.
    - If the template already contains blank IDs, leave it unchanged.
- **Typed blank**
  - `blanks` from `details.blanks`, including `max_length`.
  - `body` normalization is identical to fill-by-choice.
  - Do not read `accepted` answers here; they are only in the result `solution`.
- **Matching**
  - `leftItems = details.pairs.left`
  - `rightItems = details.pairs.right`
  - Keep the server order. Do not pair them by index and do not assume the right side
    has the same length (distractors).
- **Ordering**
  - `sentences = details.items` in the order received.
  - Do not sort by a `position` field. There is no pre-submit correct position.

Remove grader-only getters. Add display helpers:

```text
TestOptionModel? optionById(String id)
TestBlankModel? blankById(String id)
TestMatchItemModel? leftById(String id)
TestMatchItemModel? rightById(String id)
```

### 4.6 Option, blank, match, and sentence models

`TestOptionModel`:

```text
id        String
label     String     // API text
imageUrl  String?
isCorrect bool?      // only populated from result solution
feedback  String?    // only populated from result solution
```

`TestBlankModel`:

```text
id            String
blankIndex    int?
placeholder   String?
maxLength     int?
scoreWeight   double?
choices       List<TestOptionModel>   // dropdown only
```

`TestMatchItemModel`:

```text
id        String
text      String
imageUrl  String?
```

Replace usages of `TestPairModel` with `TestMatchItemModel` for left/right. Keep
`test_pair_model.dart` only if result solution parsing needs a convenience class;
otherwise delete it after migration.

`TestSentenceModel`:

```text
id    String
text  String
```

Remove `position` from production parsing. Keep an optional `position` only if a
result solution needs it.

### 4.7 `TestAnswerModel` and submission serialization

Rewrite the answer model to match the API:

```dart
class TestAnswerModel {
  const TestAnswerModel({
    this.optionIds = const <String>[],
    this.boolean,
    this.blanks = const <String, String>{},
    this.matches = const <String, String>{}, // rightId -> leftId
    this.order = const <String>[],
  });

  final List<String> optionIds;
  final bool? boolean;
  final Map<String, String> blanks;
  final Map<String, String> matches;
  final List<String> order;

  String? blankValue(String blankId) => blanks[blankId];

  String? leftForRight(String rightId) => matches[rightId];

  TestAnswerModel copyWith({
    List<String>? optionIds,
    bool? boolean,
    bool clearBoolean = false,
    Map<String, String>? blanks,
    Map<String, String>? matches,
    List<String>? order,
  }) { /* ... */ }
}
```

Add a serializer that is owned by the answer/model layer, not the Cubit. It must take
the question so it can validate IDs and limits:

```dart
Map<String, dynamic> toSubmissionJson(TestQuestionModel question) { ... }
```

Exact output matrix:

| Type | Condition | JSON |
|---|---|---|
| `mcq_single` | one `optionId` | `{ "option_id": "o_1" }` |
| `mcq_multiple` | one or more IDs, at most `maxSelections` | `{ "option_ids": ["o_1", "o_2"] }` |
| `true_false` | `boolean != null` | `{ "boolean": true }` |
| `fill_blank_choice` | any blank filled | `{ "blanks": { "b_1": "w_1" } }` |
| `fill_blank_typed` | any blank filled | `{ "blanks": { "b_1": "text" } }` |
| `matching` | any match | `{ "matches": { "right_id": "left_id" } }` |
| `ordering` | always | `{ "order": ["i_1", "i_2", ...] }` |

Add `bool isAnswered(TestQuestionType type)`:

- choice single: `optionIds.length == 1`
- choice multiple: `optionIds.isNotEmpty`
- true/false: `boolean != null`
- fill/typed: `blanks.isNotEmpty`
- matching: `matches.isNotEmpty`
- ordering: `order.isNotEmpty`

Do not send an unanswered question except ordering, which always has a complete order.
The Cubit builds the final `answers` map by filtering `isAnswered`.

Structural validation before serialization is mandatory. These checks validate answer
shape only; they must never determine correctness.

- Single/multiple choice:
  - no duplicate option IDs.
  - selected count is within `1..maxSelections` for multiple, exactly `1` for single.
  - every selected ID belongs to `question.options`.
- Matching:
  - every key is a valid right ID.
  - every value is a valid left ID.
  - a left item is not assigned to more than one right item when the UI rule forbids
    reuse.
- Ordering:
  - every item appears exactly once.
  - no unknown IDs.
  - submitted length equals `question.sentences.length`.
- Fill blanks:
  - every blank ID belongs to `question.blanks`.
  - for word-bank, every value belongs to `question.wordBank`.
  - for dropdown, every value belongs to that blank's `choices`.

Use a small `AnswerValidationException` (or `FormatException` with a stable message)
from the model layer. The Cubit catches it before any network call and emits
`quiz_answers_invalid`; the data source still surfaces server `422` normally. Add
dedicated unit tests for every serializer branch.

### 4.8 `QuizPolicyModel`

Create `quiz_policy_model.dart`:

```text
passScore             int
isBlocking            bool
maxAttempts           int?
shuffleQuestions      bool
timeLimitMinutes      int?
retryCooldownMinutes  int
```

Parse from `policy_snapshot`. Use it as a fallback if the overview is missing a value.

### 4.9 `QuizAttemptModel`

Create `quiz_attempt_model.dart` as the single source for both start and submit
responses:

```text
id                int
quizId            int
studentId         int
attemptNo         int
score             double?   // null during attempt
maxScore          double
scorePercent      int?      // server value
isPassed          bool?     // server value
reviewStatus      String    // none / pending / resolved
attemptsUsed      int?
attemptsLeft      int?      // null = unlimited
nextAttemptAt     DateTime?
startedAt         DateTime?
expiresAt         DateTime?
submittedAt       DateTime?
serverHasExpired  bool
serverIsSubmitted bool
policy            QuizPolicyModel
questions         List<TestQuestionModel>
questionResults   List<QuizQuestionResultModel>
```

`questions` is built from `answers[]` during both start and submit. During submit,
also parse per-answer results into `questionResults`. These are two distinct
representations of the same payload:

- `questions` is display data from `answers[]` and must never include correct-answer
  or solution data.
- `questionResults` is grading/review data from the submitted `answers[]`, including
  `solution` when the server allows it.

Do not merge `solution` into `TestQuestionModel` or `TestOptionModel`, and do not
hydrate the student's local answers from the result response.

Convenience getters:

```text
bool get isSubmitted => serverIsSubmitted || submittedAt != null;
bool get isPendingReview => reviewStatus == 'pending';
bool get hasExpired =>
    serverHasExpired || (expiresAt?.isBefore(DateTime.now()) ?? false);
Duration? get remaining => expiresAt?.difference(DateTime.now());
```

Parse `serverHasExpired` from `has_expired`. Parse `serverIsSubmitted` from the
response's submission signal (`submitted_at != null`, a non-null `score`, a non-null
`is_passed`, or `review_status != 'none'`). Do not assume `submitted_at` is always
present, and do not use `isPassed != null` as the only submission test.

### 4.10 `QuizQuestionResultModel`

Create `quiz_question_result_model.dart`:

```text
questionId       String
questionType     TestQuestionType
score            double
awardedScore     double?
isCorrect        bool?
givenAnswer      Map<String, dynamic>
blankResults     Map<String, dynamic>
componentResults Map<String, dynamic>
solution         Map<String, dynamic>?
explanation      String?
```

The result UI only needs summary fields at first. Keep the per-question result data
for a later review screen; do not build a full review UI in this scope.

### 4.11 `TestResultModel` decision

Delete the old `TestResultModel` and use `QuizAttemptModel` directly in the result UI.
Update `lesson_test_result_body.dart`, `test_result_headline.dart`, and
`test_result_score_card.dart` to read `QuizAttemptModel`. The summary UI reads
`questions` for display and `questionResults` only for review data. Do not keep a
second result model, do not merge `solution` into display models, and do not compute
pass/fail or score locally.

---

## 5. Phase 2 â€” Data Source, Repo, and Errors

### 5.1 Data source

Rewrite `lesson_test_data_source.dart`:

```dart
class LessonTestDataSource {
  const LessonTestDataSource({
    this.client = const ApiClient(endSessionOnForbidden: false),
  });

  final ApiClient client;

  Future<LessonTestModel> fetchQuiz(int contentId) async {
    try {
      return await client.getObject<LessonTestModel>(
        ApiEndpoints.contentQuiz(contentId),
        LessonTestModel.fromJson,
      );
    } on AppException catch (error) {
      throw QuizErrorMapper.translate(error);
    }
  }

  Future<QuizAttemptModel> startAttempt(int quizId) async {
    try {
      final ApiEnvelope envelope = await client.post(
        ApiEndpoints.quizAttempts(quizId),
      );
      return QuizAttemptModel.fromJson(envelope.dataMap);
    } on FormatException {
      throw const AppException('quiz_unsupported_question');
    } on AppException catch (error) {
      throw QuizErrorMapper.translate(error);
    }
  }

  Future<QuizAttemptModel> submitAttempt(
    int attemptId,
    Map<String, Map<String, dynamic>> answers,
  ) async {
    try {
      final ApiEnvelope envelope = await client.post(
        ApiEndpoints.quizAttemptSubmit(attemptId),
        data: <String, dynamic>{'answers': answers},
      );
      return QuizAttemptModel.fromJson(envelope.dataMap);
    } on FormatException {
      throw const AppException('quiz_unavailable');
    } on AppException catch (error) {
      throw QuizErrorMapper.translate(error);
    }
  }

  Future<List<QuizAttemptModel>> fetchMyAttempts(int quizId) async {
    final ApiEnvelope envelope = await client.get(
      ApiEndpoints.quizMyAttempts(quizId),
    );
    final Map<String, dynamic> data = Json.asMap(envelope.data);
    return Json.asMapList(data['items'])
        .map(QuizAttemptModel.fromJson)
        .toList(growable: false);
  }
}
```

Do not use `ErrorMapper.map` as the only translation here. The quiz-specific error
mapper must run first so `403` does not become `session_expired`.

### 5.2 Quiz error mapper

Create `lib/features/lesson_test/data/quiz_error_mapper.dart`:

```dart
class QuizErrorMapper {
  QuizErrorMapper._();

  static AppException translate(AppException error) {
    final int? status = error.statusCode;

    final String key = switch (status) {
      401 => error.key, // let the normal session flow handle it
      403 => _forbiddenKey(error),
      404 => 'quiz_not_found',
      422 => _validationKey(error),
      429 => 'quiz_cooldown',
      _ => error.key,
    };

    return AppException(
      key,
      message: error.message,
      errors: error.errors,
      statusCode: error.statusCode,
      data: error.data,
      endsSession: error.endsSession && status != 403,
    );
  }

  static String _forbiddenKey(AppException error) {
    final String? reason = _serverReason(error);
    if (reason != null) {
      if (reason.contains('video') ||
          reason.contains('watch') ||
          reason.contains('100')) {
        return 'quiz_video_incomplete';
      }
      if (reason.contains('lock') || reason.contains('block')) {
        return 'quiz_locked';
      }
    }

    final String text =
        '${error.message ?? ''} ${error.errors.values.expand((e) => e).join(' ')}';
    final String lower = text.toLowerCase();

    if (lower.contains('video') ||
        lower.contains('watch') ||
        lower.contains('100')) {
      return 'quiz_video_incomplete';
    }
    if (lower.contains('locked') || lower.contains('blocked')) {
      return 'quiz_locked';
    }
    return 'quiz_unavailable';
  }

  static String _validationKey(AppException error) {
    final String? reason = _serverReason(error);
    if (reason != null) {
      if (reason.contains('attempt') &&
          (reason.contains('exhaust') || reason.contains('limit'))) {
        return 'quiz_attempts_exhausted';
      }
      if (reason.contains('submit')) {
        return 'quiz_already_submitted';
      }
    }

    final String text =
        '${error.message ?? ''} ${error.errors.keys.join(' ')} '
        '${error.errors.values.expand((e) => e).join(' ')}';
    final String lower = text.toLowerCase();

    if (lower.contains('attempt') &&
        (lower.contains('exhaust') || lower.contains('limit'))) {
      return 'quiz_attempts_exhausted';
    }
    if (lower.contains('submit')) {
      return 'quiz_already_submitted';
    }
    return 'quiz_answers_invalid';
  }

  /// Stable code first, then a structured reason field, then message fallback.
  static String? _serverReason(AppException error) {
    const List<String> keys = <String>[
      'code',
      'reason',
      'error_code',
      'error',
    ];

    for (final String key in keys) {
      final List<String> values = error.errorsFor(key);
      if (values.isNotEmpty) return values.first.toLowerCase().trim();
    }

    final Object? data = error.data;
    if (data is Map) {
      for (final String key in keys) {
        final Object? value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.toLowerCase().trim();
        }
      }
    }

    return null;
  }
}
```

Catch `AppException` in the data source methods and `throw QuizErrorMapper.translate(error)`.
Keep the original message/errors for diagnostics. Avoid showing raw server messages in
the UI unless the product explicitly allows it. String matching is a fallback only:
use the backend's stable code or structured reason first and return
`quiz_unavailable` when the reason cannot be determined.

### 5.3 Repo

Extend `LessonTestRepo`:

```dart
Future<LessonTestModel> fetchQuiz(int contentId) =>
    dataSource.fetchQuiz(contentId);

Future<QuizAttemptModel> startAttempt(int quizId) =>
    dataSource.startAttempt(quizId);

Future<QuizAttemptModel> submitAttempt(
  int attemptId,
  Map<String, Map<String, dynamic>> answers,
) => dataSource.submitAttempt(attemptId, answers);

Future<List<QuizAttemptModel>> fetchMyAttempts(int quizId) =>
    dataSource.fetchMyAttempts(quizId);
```

The repo stays a thin delegate. Validation and payload construction belong in the
model/data-source boundary, not the Cubit.

### 5.4 DI

No mandatory `get_it` registration is needed because `LessonTestScreen` currently
constructs `LessonTestCubit` directly. If the team wants consistency with other
features:

- register `LessonTestDataSource`
- register `LessonTestRepo`
- register a `LessonTestCubit` factory parameterized by lesson context

Do not break existing screen-level construction just to add DI.

---

## 6. Phase 3 â€” Lesson Detail Integration

### 6.1 Model

Add `quiz` parsing as described in 4.2.

### 6.2 Button visibility

In `lesson_detail_body.dart`, replace the current `if (!detail.isArticle)` block with:

```dart
if (detail.hasQuiz) ...<Widget>[
  SizedBox(height: 20.h),
  LessonDetailInset(
    child: Column(
      children: <Widget>[
        if (detail.hasPassedQuiz) ...<Widget>[/* passed badge */],
        CustomButton(
          onPressed: () => onGoToTest?.call(detail),
          text: 'go_to_test'.tr(),
          ...
        ),
      ],
    ),
  ),
]
```

Important:

- Show the button for articles too. The guideâ€™s example lesson is an article with a
  quiz.
- Do not call `ComingSoonSheet` when the quiz is real. Keep `onGoToTest == null`
  fallback only for previews/tests.
- For video lessons that are not completed, keep the button visible. The server
  enforces `403`; show the mapped `quiz_video_incomplete` message after start.
- If `detail.isLocked`, do not navigate.

### 6.3 Route arguments

Change `LessonTestArgs`:

```dart
class LessonTestArgs {
  const LessonTestArgs({
    required this.lessonId,
    this.lessonTitle,
    this.categorySubjectId,
    this.lessonOrder,
  });

  final int lessonId;
  final String? lessonTitle;
  final int? categorySubjectId;
  final int? lessonOrder;

  factory LessonTestArgs.fromRoute(Object? arguments) { ... }
}
```

Route construction:

```dart
onGoToTest: (LessonDetailModel detail) => _push(
  AppRoutes.lessonTest,
  LessonTestArgs(
    lessonId: detail.id,
    lessonTitle: detail.title,
    categorySubjectId: detail.categorySubjectId,
  ),
),
```

Change `LessonDetailScreen` and `LessonDetailBody` callback type to accept the loaded
detail:

```dart
final void Function(LessonDetailModel detail)? onGoToTest;
```

### 6.4 Refresh after return

`LessonTestScreen` pops with `true` after a submitted result. The lesson detail route
must reload so `quiz.has_passed` and any lock state are fresh.

Recommended flow:

1. Change `_push` in `AppRouter` to return the `Future` from `pushNamed`.
2. Change `LessonDetailScreen.onGoToTest` to an async wrapper:

```dart
onGoToTest: (LessonDetailModel detail) async {
  await widget.onGoToTest?.call(detail);
  if (!mounted) return;
  await context.read<LessonDetailCubit>().loadLesson();
},
```

3. In `LessonTestScreen`, when the result is reached, allow popping with `true` from
   â€œBack to lessonsâ€‌ and from the system back button after submission.

If the student abandons an attempt without submitting, do not pop with `true`; the
attempt remains open on the server and will be resumed on the next start.

---

## 7. Phase 4 â€” Cubit and State Machine

### 7.1 State

Replace `LessonTestState` with:

```text
LessonTestStatus { initial, loading, ready, starting, running, submitting, result, failure }

LessonTestState
  status
  quiz            LessonTestModel?
  attempt         QuizAttemptModel?
  answers         Map<String, TestAnswerModel>
  rightOrder      Map<String, List<String>>
  currentIndex    int
  remaining       Duration       // from attempt.expiresAt
  questionStartedAt DateTime?
  questionTick    int             // rebuild signal for display-only question timer
  selectedBlankId String?
  selectedPromptId String?
  errorKey        String?
  messageKey      String?
  validationErrors Map<String, List<String>>
  nextLessonId    int?
  nextLessonTitle String?
  nextLessonLocked bool
  isStarting      bool
  isSubmitting    bool
  result          QuizAttemptModel?
```

Computed:

```text
bool get isLoading => status == loading || status == initial;
bool get isRunning => status == running;
bool get isResult => status == result;
bool get hasQuiz => quiz != null;
bool get hasQuestions => attempt?.questions.isNotEmpty ?? false;
bool get hasTimeLimit => attempt?.expiresAt != null || quiz?.hasTimeLimit == true;
bool get canStart => ...
bool get isFirstQuestion => currentIndex == 0;
bool get isLastQuestion => ...
double get progress => ...
Duration get questionElapsed =>
    questionStartedAt == null
        ? Duration.zero
        : DateTime.now().difference(questionStartedAt!);
Duration? get questionRemaining => ...
TestQuestionModel? get currentQuestion => ...
TestAnswerModel get currentAnswer => ...
```

`canStart`:

- quiz exists
- attempt not already running
- `quiz.hasAttemptsLeft`
- `!quiz.isInCooldown`
- `quiz.questionCount > 0`
- not currently starting

`hasPassed` does not necessarily block a retake. Show the passed state, but allow a
retake while attempts remain, unless product decides otherwise.

### 7.2 Loading

`loadQuiz()`:

1. Emit `loading`, clear errors/messages.
2. `repo.fetchQuiz(lessonId)`.
3. Emit `ready` with the overview.
4. On `AppException`, emit `failure` with the translated key.
5. On `404`, emit `failure` with `quiz_not_found` (or a dedicated empty state).
6. On `403`, emit `failure` with `quiz_locked` / `quiz_unavailable`; never sign out.

Do not start an attempt automatically. The student must tap the start button, and the
intro must show a confirmation dialog first (see 8.2) because starting consumes an
attempt even if the student leaves immediately.

### 7.3 Starting an attempt

`startAttempt()`:

1. Guard `_startRequested` / `state.isStarting` / `canStart`.
2. Emit `starting`.
3. `repo.startAttempt(quiz.id)`.
4. Initialize local answers:

   - ordering: `order = question.sentences.map((item) => item.id)` in server order.
     Do not shuffle.
   - matching: `rightOrder[question.id] = question.rightItems.map((item) => item.id)`
     in server order. Do not shuffle.
   - choice/multi/true-false/fill/typed: empty.

5. Emit `running` with `attempt`, `remaining` from `attempt.expiresAt`, index `0`,
   and `questionStartedAt = DateTime.now()`.
6. Start a 1-second timer.

On `403`: map `quiz_video_incomplete` / `quiz_locked`; remain in `ready`.
On `422`: map `quiz_attempts_exhausted` or `quiz_unavailable`; remain in `ready`.
On `429`: map `quiz_cooldown`; remain in `ready`; use `data.next_attempt_at` if present.

Re-requesting while an attempt is open returns the same attempt; the Cubit should
accept that as a normal resume. Do not assume a fresh `attempt_no`.

### 7.4 Answer mutations

Implement:

```text
selectOption(String optionId)          // single replaces; multiple toggles up to max
selectBoolean(bool value)              // true/false
selectBlank(String blankId)
clearBlank(String blankId)
assignWord(String optionId)            // word bank; removes the word from other blanks
typeBlank({blankId, value})            // trims empty values out
selectPrompt(String leftItemId)
linkMatch(String rightItemId)          // stores matches[rightId] = selectedLeftId
clearPair(String rightItemId)
reorderSentences(int oldIndex, int newIndex)
```

Rules:

- Multiple choice: ignore selection beyond `maxSelections`; show a message key if the
  product wants feedback.
- Matching: one right item maps to one left item; selecting a left then a right
  overwrites any previous right for that left. Store right â†’ left.
- Word bank: a non-reusable word cannot fill two blanks; existing `assignWord`
  behavior is close, but update it to the new answer field.
- Typed: respect `maxLength` in the widget; do not normalize Arabic locally.
- Ordering: use the existing `ReorderableListView` 0-based indices.

### 7.5 Timer

`_tick()`:

```dart
final DateTime? expiresAt = state.attempt?.expiresAt;
final bool hasQuestionTimer = state.currentQuestion?.timeLimit != null;
if (expiresAt == null && !hasQuestionTimer) return;

if (expiresAt != null) {
  final Duration remaining = expiresAt.difference(DateTime.now());
  if (remaining <= Duration.zero) {
    emit(state.copyWith(remaining: Duration.zero));
    submit(timedOut: true);
    return;
  }

  emit(state.copyWith(
    remaining: remaining,
    questionTick: state.questionTick + 1,
  ));
  return;
}

emit(state.copyWith(questionTick: state.questionTick + 1));
```

Why recompute from `expiresAt`:

- the app may be backgrounded
- the student may take time on another screen
- timer drift must not extend the attempt

Question-level timer:

- `questionElapsed` is derived from `questionStartedAt`, not incremented by the ticker.
  This stays accurate across backgrounding and dropped ticks.
- Reset `questionStartedAt = DateTime.now()` whenever `currentIndex` changes, and on
  start/resume. The backend does not expose per-question elapsed time, so a resumed
  attempt resets the question timer.
- `questionRemaining = question.timeLimit - questionElapsed`
- display it beside the question prompt only when `default_time_seconds` is non-null;
  empty `options` (true/false) and `null` both mean "no question timer"
- do not auto-submit when a question timer reaches zero unless the backend explicitly
  requires it; the attempt-level `expires_at` is authoritative

On timeout submit:

- call `submit(timedOut: true)` exactly once and set `didTimeOut` on the state; the
  ticker must return early while `didTimeOut` is true so it cannot re-trigger
- guard against duplicate submissions with `_submitRequested`
- do not show the result screen for a timed-out attempt: notify the UI through
  `didTimeOut`, show `test_time_up`, and pop back to the lesson screen once
- the submission itself consumes the attempt, so `attempts_left` decreases on the
  server even though the result is not displayed
- if submission fails, do not restart the ticker (the attempt has already expired);
  surface the error and let the attempt be submitted the next time it is opened

### 7.6 Submission

`submit({bool timedOut = false})`:

1. Guard `_submitRequested`, `state.isSubmitting`, `state.attempt == null`,
   `state.status == submitting`, and `state.status == result`. The timeout path and
   the manual path share this guard, so only one request can be in flight.
2. Set `_submitRequested = true`; emit `submitting`; stop the ticker.
3. Build `answers`:

   ```dart
   final Map<String, Map<String, dynamic>> payload = {};

   for (final TestQuestionModel question in attempt.questions) {
     final TestAnswerModel answer =
         state.answers[question.id] ?? const TestAnswerModel();

     if (!answer.isAnswered(question.type) && !question.type.isOrdering) {
       continue;
     }

     payload[question.id] = answer.toSubmissionJson(question);
   }
   ```

   Catch serialization/validation errors before the network call, remain `running`,
   preserve answers, emit `quiz_answers_invalid`, and allow correction.
4. Call `repo.submitAttempt(attempt.id, payload)`.
5. On success, emit `result` with the returned `QuizAttemptModel`, preserve the
   attempt, and clear `messageKey` or set `test_time_up`. Stop the ticker for good.
6. On `422`, keep all local answers and remain `running`; map field errors into
   `validationErrors` and show `quiz_answers_invalid`. Restart the ticker if
   `expiresAt` is still in the future.
7. On recoverable network errors, remain `running`, preserve answers, show the mapped
   error, and allow retry. Restart the ticker if the attempt is still live.
8. On `401`, allow the normal session-end/refresh flow. Do not restart the ticker.
9. On `403`, translate to a quiz key and remain `running`; do not sign out. Restart
   the ticker if the attempt is still live.
10. On `429`, show `quiz_cooldown`; remain `running`. Restart the ticker if the
    attempt is still live.
11. On a duplicate-submission response (`422`/`409` indicating the attempt was already
    submitted), do not leave the student stuck in `running`:
    - call `repo.fetchMyAttempts(quiz.id)`;
    - find the attempt with the matching `id`;
    - if it is submitted, emit `result` with it;
    - otherwise show `quiz_already_submitted`.
12. In `finally`, clear `isSubmitting`; only clear `_submitRequested` when the result
    was not reached and the student is allowed to retry. Never clear
    `_submitRequested` on success.

The ticker must never stay permanently stopped after a failed submission while the
attempt is still live. The server may accept a late submission after `expires_at` and
score it `0`. Do not block submission client-side solely on expiry; let the server
return the result and show it.

### 7.7 Result and next lesson

After a successful submit (except a timed-out attempt, which pops back to the lesson
screen with `test_time_up`):

- `result.isPassed` is the only pass/fail source.
- `result.scorePercent`, `score`, `maxScore` are server values.
- `result.reviewStatus == 'pending'` shows a preliminary-result badge.
- `attemptsLeft == null` means unlimited; `0` means no more attempts.
- `nextAttemptAt` comes from the result.

Next lesson:

- The result screen should offer â€œNext lessonâ€‌ only when progression is allowed:
  - passed and not pending review, or
  - the quiz is non-blocking (a fail does not lock the next lesson).
- If `isBlocking` and `reviewStatus == 'pending'`, show the pending note and keep
  â€œNext lessonâ€‌ disabled.
- Implement `resolveNextLesson()` in the Cubit using `LessonsRepo.fetchAllLessons`
  with the current `categorySubjectId`, sort by `LessonModel.order`, find the current
  id, and choose the next item.
- If the next lesson is still locked, emit `nextLessonLocked = true` and show
  `next_lesson_locked`; do not push a locked detail route.
- If resolution fails, keep â€œBack to lessonsâ€‌ as the safe action.

If scope must stay minimal, hide the â€œNext lessonâ€‌ button and rely on returning to the
lesson list. Do not leave a button that only shows `coming_soon_test`.

---

## 8. Phase 5 â€” UI Changes

### 8.1 `LessonTestBody`

- Show a skeleton that mirrors the intro card while loading, not a bare
  `CircularProgressIndicator`.
- Keep `AppErrorView` with retry calling `loadQuiz`.
- Show `AppEmptyView` when `quiz.questionCount == 0` or the quiz has no questions.
- Route:
  - `ready` â†’ intro
  - `running` â†’ question
  - `result` â†’ result
  - `failure` â†’ error view

### 8.2 Intro body

Display:

- title
- question count
- time limit only when `quiz.hasTimeLimit`; hide the row entirely when `null`
- pass score note using `pass_score`
- `instructions` when present
- attempts remaining:
  - `null` â†’ â€œunlimitedâ€‌
  - `0` â†’ disabled start + exhausted note
  - `> 0` â†’ count
- passed status when `quiz.hasPassed`
- cooldown:
  - if `nextAttemptAt` is in the future, disable start and show the date/time
- start button:
  - disabled when `!canStart`
  - `isLoading: state.isStarting`
  - inline loading only; do not block the whole screen
  - before calling `startAttempt()`, show `AppConfirmDialog` with
    `quiz_start_confirm_title` / `quiz_start_confirm_message` (`QuizStartDialog` in
    `presentation/widgets/quiz_start_dialog.dart`) explaining that one attempt is used
    immediately even if the student exits before answering all questions; start only
    on confirmation

### 8.3 Choice questions

- Single choice: one selected tile.
- Multiple choice: toggle; enforce `maxSelections`.
- True/false: render two dedicated choices (â€œTrueâ€‌ / â€œFalseâ€‌) and call
  `selectBoolean`. Do not use option IDs for this type.
- `best_answer` (`isBestAnswer`): same input as single choice; optionally show a
  â€œchoose the best answerâ€‌ helper key.

### 8.4 Fill-by-choice questions

Two modes:

- `word_bank`: existing word-bank UI.
- `dropdown`: create `test_dropdown_blanks_question.dart`.
  - each blank opens its own choices
  - choices come from `blank.choices`
  - selected label resolves from that blankâ€™s choices, not a global option list

Both submit the same `{ "blanks": { blankId: choiceId } }`.

### 8.5 Typed blanks

- Keep the current text-field approach.
- Use `max_length` from the blank as `maxLength`.
- Do not show accepted answers before submission.
- Do not implement Arabic normalization in the app; the server owns it.

### 8.6 Matching

Update the widget to use:

- `question.leftItems` for the prompt column
- `question.rightItems` for the match column
- `state.rightOrderOf(question.id)` for the right column order
- `answer.leftForRight(rightId)` for badge lookup

Interaction:

1. tap a left item â†’ `selectPrompt(leftId)`
2. tap a right item â†’ `linkMatch(rightId)`
3. store `matches[rightId] = leftId`
4. show a badge number next to the matched left and right items

Distractors are normal right items; do not hide them and do not pre-pair them.

### 8.7 Ordering

- Render `question.sentences` in the received order.
- Initialize `answer.order` from that same order.
- Reorder locally and submit the resulting list.
- Do not sort by a position and do not shuffle again.

### 8.8 Navigation buttons

- `TestNavButtons` needs `isSubmitting`.
- Disable both buttons while submitting.
- â€œFinish testâ€‌ uses inline loading.
- Prevent double taps; the Cubit also guards.
- Optionally confirm finish with a dialog; if added, localize it.

### 8.9 Result body

Display only:

- `result.isPassed` for headline
- `score` / `maxScore`
- `scorePercent`
- `attemptsLeft` and `nextAttemptAt`
- pending-review badge when `reviewStatus == 'pending'`
- â€œNext lessonâ€‌ gating as in 7.7
- â€œBack to lessonsâ€‌ always available

Remove `retryAfterDays` and any client-calculated percentage. Use `nextAttemptAt` for
retry copy; format it with the existing date/time helpers or a localized date format.

### 8.10 Loading behavior

- Intro/quiz loading: skeleton matching the intro card and button.
- Start button: inline loading.
- Finish button: inline loading.
- Error: `AppErrorView` with retry.
- Empty: `AppEmptyView`.
- Do not replace existing content with a full-screen spinner during submit.

### 8.11 Leaving an in-progress attempt

- While `running`, block the route with `PopScope(canPop: false)` and route the top-bar
  back through the same handler (`AppSectionScaffold.onBack`); intro and result states
  pop normally.
- Show `QuizLeaveDialog` (`presentation/widgets/quiz_leave_dialog.dart`) with
  `quiz_leave_confirm_title`, `quiz_leave_confirm_message`, and
  `quiz_leave_confirm_action`, warning that leaving submits the current answers and
  uses one attempt.
- On confirm, call `submitAndLeave()`, which submits only the answers given so far and
  returns `true` only on success, then pop back to the lesson screen. The server
  decrements `attempts_left` on submit, so the count drops without any local faking.
- On failure (network, `422`, `5xx`), stay `running`, keep the answers, surface the
  mapped error, and leave the attempt open so it can be resumed or submitted again.
- Do not decrement the count locally: the next overview fetch would overwrite it and
  the open attempt would still be resumable.
- iOS swipe-back is disabled while `running`; the confirmation flow is reached through
  the top-bar back button.


---

## 9. Phase 6 â€” Localization and Error Copy

### 9.1 Keys to add

Add to both `assets/translations/ar.json` and `assets/translations/en.json`.

| Key | English | Arabic |
|---|---|---|
| `quiz_not_found` | No published quiz for this lesson. | ظ„ط§ ظٹظˆط¬ط¯ ط§ط®طھط¨ط§ط± ظ…ظ†ط´ظˆط± ظ„ظ‡ط°ط§ ط§ظ„ط¯ط±ط³. |
| `quiz_unavailable` | This quiz is not available right now. | ظ‡ط°ط§ ط§ظ„ط§ط®طھط¨ط§ط± ط؛ظٹط± ظ…طھط§ط­ ط­ط§ظ„ظٹط§ظ‹. |
| `quiz_locked` | This quiz is locked. | ظ‡ط°ط§ ط§ظ„ط§ط®طھط¨ط§ط± ظ…ظ‚ظپظ„. |
| `quiz_video_incomplete` | Watch the video to the end before starting the quiz. | ط£ظƒظ…ظ„ ظ…ط´ط§ظ‡ط¯ط© ط§ظ„ظپظٹط¯ظٹظˆ ط¨ط§ظ„ظƒط§ظ…ظ„ ظ„ط¨ط¯ط، ط§ظ„ط§ط®طھط¨ط§ط±. |
| `quiz_attempts_exhausted` | You have used all attempts for this quiz. | ظ„ظ‚ط¯ ط§ط³طھظ†ظپط¯طھ ط¬ظ…ظٹط¹ ظ…ط­ط§ظˆظ„ط§طھ ظ‡ط°ط§ ط§ظ„ط§ط®طھط¨ط§ط±. |
| `quiz_cooldown` | You can try again later. | ظٹظ…ظƒظ†ظƒ ط¥ط¹ط§ط¯ط© ط§ظ„ظ…ط­ط§ظˆظ„ط© ظ„ط§ط­ظ‚ط§ظ‹. |
| `quiz_already_submitted` | This attempt has already been submitted. | طھظ… طھط³ظ„ظٹظ… ظ‡ط°ظ‡ ط§ظ„ظ…ط­ط§ظˆظ„ط© ط¨ط§ظ„ظپط¹ظ„. |
| `quiz_answers_invalid` | Check your answers and try again. | ط±ط§ط¬ط¹ ط¥ط¬ط§ط¨ط§طھظƒ ط«ظ… ط­ط§ظˆظ„ ظ…ط±ط© ط£ط®ط±ظ‰. |
| `quiz_pending_review` | Your result is preliminary and awaiting teacher review. | ظ†طھظٹط¬طھظƒ ط£ظˆظ„ظٹط© ط¨ط§ظ†طھط¸ط§ط± ظ…ط±ط§ط¬ط¹ط© ط§ظ„ظ…ط¹ظ„ظ…. |
| `quiz_passed` | You have passed this quiz. | ظ„ظ‚ط¯ ط§ط¬طھط²طھ ظ‡ط°ط§ ط§ظ„ط§ط®طھط¨ط§ط±. |
| `quiz_attempts_left` | Attempts left | ط§ظ„ظ…ط­ط§ظˆظ„ط§طھ ط§ظ„ظ…طھط¨ظ‚ظٹط© |
| `quiz_attempts_unlimited` | Unlimited | ط؛ظٹط± ظ…ط­ط¯ظˆط¯ |
| `quiz_no_attempts_left` | No attempts left | ظ„ط§ طھظˆط¬ط¯ ظ…ط­ط§ظˆظ„ط§طھ ظ…طھط¨ظ‚ظٹط© |
| `quiz_next_attempt_at` | Next attempt | ط§ظ„ظ…ط­ط§ظˆظ„ط© ط§ظ„ظ‚ط§ط¯ظ…ط© |
| `quiz_instructions` | Instructions | ط§ظ„طھط¹ظ„ظٹظ…ط§طھ |
| `quiz_total_score` | Total score | ط§ظ„ط¯ط±ط¬ط© ط§ظ„ظƒظ„ظٹط© |
| `quiz_score_value` | {score} / {max} | {score} / {max} |
| `quiz_best_answer` | Choose the best answer | ط§ط®طھط± ط§ظ„ط¥ط¬ط§ط¨ط© ط§ظ„ط£ظپط¶ظ„ |
| `quiz_max_selections` | You can select up to {count} answers | ظٹظ…ظƒظ†ظƒ ط§ط®طھظٹط§ط± {count} ط¥ط¬ط§ط¨ط§طھ ظƒط­ط¯ ط£ظ‚طµظ‰ |
| `next_lesson_locked` | Pass the quiz to unlock the next lesson. | ط§ط¬طھط² ط§ظ„ط§ط®طھط¨ط§ط± ظ„ظپطھط­ ط§ظ„ط¯ط±ط³ ط§ظ„طھط§ظ„ظٹ. |
| `quiz_unsupported_question` | This question type is not supported yet. | ظ†ظˆط¹ ظ‡ط°ط§ ط§ظ„ط³ط¤ط§ظ„ ط؛ظٹط± ظ…ط¯ط¹ظˆظ… ط­ط§ظ„ظٹط§ظ‹. |

Reuse existing keys where they already fit:

- `go_to_test`
- `test_start`
- `lesson_test`
- `test_result`
- `questions_count`
- `questions_value`
- `test_duration`
- `minute_count`
- `pass_threshold_note`
- `start_test`
- `finish_test`
- `result_label`
- `test_failed`
- `test_failed_note`
- `test_time_up`
- `no_test_questions`
- `next_lesson`
- `back_to_lessons`

### 9.2 `LangKeys`

The repo currently has no `lib/core/localization/lang_keys.dart`. Create it with the
new quiz keys only and use:

```dart
LangKeys.quizNotFound.tr()
```

Do not migrate unrelated existing keys in this task. If the team prefers the current
raw-string style, use it consistently for this feature and record the decision; the
important requirement is that no new hardcoded UI text is introduced.

### 9.3 Error mapping behavior

| Status | Key | UI behavior |
|---|---|---|
| `401` | normal session flow | sign out/refresh |
| `403` locked | `quiz_locked` | stay on intro; do not sign out |
| `403` video incomplete | `quiz_video_incomplete` | stay on intro; show note |
| `403` another student's attempt | `quiz_unavailable` | stay on intro |
| `404` | `quiz_not_found` | empty/error state |
| `422` start attempts exhausted | `quiz_attempts_exhausted` | disable start |
| `422` submit shape | `quiz_answers_invalid` | stay running; show field errors |
| `422` already submitted | `quiz_already_submitted` | reload quiz/result |
| `429` | `quiz_cooldown` | stay on intro; show next attempt if present |
| `5xx` | `server_error` | retry |

Do not show raw `errors` maps to the student.

---

## 10. Phase 7 â€” Tests and Verification

### 10.1 Fixtures

Create JSON fixtures from the guide examples, then replace/verify them with real
staging payloads:

- `quiz_overview.json`
- `attempt_start_all_types.json` (all 7 types)
- `attempt_start_dropdown.json` (dropdown blanks)
- `attempt_start_word_bank.json` (word-bank blanks)
- `attempt_submit.json` (passed, `review_status: none`)
- `attempt_submit_pending.json` (`review_status: pending`, provisional result)
- `attempt_submit_no_solution.json` (`show_correct_answers == false`)
- `quiz_summary.json` (`null` and present cases)
- `quiz_summary_article.json` (article lesson with quiz)

Place under `test/features/lesson_test/fixtures/`.

Before freezing parsers, capture and compare at least one real response for each
fixture category above. One response is not enough to validate seven question types
and both blank input modes.

### 10.2 Model and policy tests

Verify `SessionPolicy` first:

- `403` + `endOnForbidden: true` ends the session.
- `403` + `endOnForbidden: false` does not end the session.
- `401` is unchanged and still follows refresh/session handling.

Then verify:

- `LessonDetailModel` parses `quiz` and leaves it `null` when absent.
- `QuizSummaryModel` parses `id`, `is_blocking`, `has_passed`.
- `LessonTestModel` keeps `null` for unlimited attempts/time and uses server values.
- `QuizAttemptModel` parses all 7 question types.
- Fill-blank body normalization converts `{{1}}` to the actual blank ID.
- Word-bank and dropdown choices parse into the right structures.
- Matching parses separate left/right lists, including distractors.
- Ordering preserves the received order.
- Unknown question type fails loudly instead of defaulting to single choice.
- Unknown blank input mode fails loudly instead of defaulting to word bank.
- `serverHasExpired` and `serverIsSubmitted` parse independently of clock time.
- `solution` stays only in `QuizQuestionResultModel`, never in `TestQuestionModel`.
- `TestAnswerModel.toSubmissionJson` matches the exact matrix in 4.7.
- Serializer validation rejects: duplicate option IDs, over-limit selections,
  unknown option/blank/match/order IDs, reused left items, wrong ordering length.

### 10.3 Cubit tests

Use a fake repo; no network.

- load success â†’ `ready`
- load `404` â†’ `quiz_not_found`
- load `403` â†’ quiz-specific key and no session end
- start success â†’ `running`, questions loaded, timer present
- start exhausted â†’ stay `ready`
- start cooldown â†’ stay `ready` with message
- answer mutations for every type
- multiple selection cap
- matching right â†’ left canonical storage
- ordering reorder and submit order
- submit success â†’ `result`, server pass/fail used
- submit timeout â†’ result/zero-score handling
- timer reaches `expires_at` â†’ submit once, no duplicate requests
- start while already starting â†’ one request
- question timer uses `questionStartedAt` and resets on index change
- resumed attempt resets question timer but keeps total `expires_at` timer
- submit duplicate/already-submitted â†’ reload authoritative result or show key
- submit recoverable network failure â†’ stay `running`, retry allowed, ticker restarted
- submit `422` â†’ stay `running`, answers preserved, ticker restarted
- manual submit + timeout race â†’ exactly one request

### 10.4 Widget tests

- Quiz button hidden when `detail.quiz == null`.
- Quiz button visible for an article with a quiz.
- Start disabled when `attemptsLeft == 0`.
- Start disabled during cooldown.
- Time row hidden when `timeLimitMinutes == null`.
- Pending-review badge shown on result.
- Result uses server score and percent.
- Next lesson disabled when blocking + pending.

### 10.5 Manual QA

- Video lesson below 100% watched â†’ start returns `403`; student stays signed in and
  sees `quiz_video_incomplete`.
- Attempt with 0 left â†’ start disabled.
- Cooldown â†’ start disabled, next attempt shown.
- Submit with an incomplete ordering â†’ server `422`; answers preserved; can correct.
- Submit with a typed answer that does not match â†’ result `pending`; next lesson
  remains locked.
- Pass a blocking quiz â†’ return to lesson detail; detail reloads and `has_passed`
  updates; next lesson unlocks.
- Fail a blocking quiz â†’ next lesson remains locked.
- Non-blocking quiz fail â†’ next lesson remains accessible.
- Kill/reopen the app during an attempt â†’ start returns the same open attempt.
- Timer reaches zero â†’ one submit; no duplicate submission.
- Arabic RTL and English LTR layouts.
- No `403` quiz response signs the student out.

### 10.6 Commands

```powershell
flutter analyze
flutter test
```

If tests are added under a new folder, run the whole suite, not just the new tests.

---

## 11. Acceptance Criteria

- [ ] Lesson detail parses `quiz` and shows the quiz button only when it exists.
- [ ] Quiz button is available for both article and media lessons when a quiz exists.
- [ ] Quiz overview loads from `GET /user/content/{lessonId}/quiz`.
- [ ] Start calls `POST /user/quizzes/{quizId}/attempts` and renders all 7 types.
- [ ] All answer payloads match the server matrix exactly.
- [ ] Serializers reject duplicate, unknown, over-limit, or incomplete answer IDs
      without ever judging correctness.
- [ ] No client-side grading, score calculation, or pass/fail computation remains.
- [ ] `true_false` submits a real boolean.
- [ ] `matching` submits right ID �?? left ID.
- [ ] `ordering` submits the complete local order once.
- [ ] Attempt progress resumes from `expires_at`, not a decrement-only timer.
- [ ] Question elapsed time derives from `questionStartedAt` and stays correct after
      backgrounding; a resumed attempt resets only the question timer.
- [ ] Time-limit rows and timers are hidden when the server value is `null`.
- [ ] Attempts left = 0 disables start; cooldown disables start.
- [ ] `403` quiz responses do not end the session in either `ApiClient` or
      `AuthInterceptor`.
- [ ] `401` still follows the normal refresh/session path.
- [ ] `422` submit errors keep the attempt open and preserve answers.
- [ ] A failed submission restarts the ticker when the attempt is still live.
- [ ] Result screen uses server `score`, `max_score`, `score_percent`, and `is_passed`.
- [ ] Pending typed-answer review is shown and blocks next-lesson progression for
      blocking quizzes.
- [ ] Lesson detail reloads after quiz completion so `has_passed` and locks refresh.
- [ ] All new strings exist in both translation files.
- [ ] Loading uses skeleton/inline states; no unnecessary full-screen spinner.
- [ ] `flutter analyze` is clean.
- [ ] `flutter test` passes.
- [ ] No `build_runner` requirement unless code generation is introduced.

---

## 12. Open Questions to Confirm Before Coding

1. **Exact `403` reason codes**: The guide uses `403` for several cases. Confirm whether
   the backend includes a stable machine-readable reason or only a message. If only a
   message, keep the string-matching fallback in `QuizErrorMapper` and always show a
   generic `quiz_unavailable` when uncertain.
2. **Retake after passing**: `attempts_left` may still allow a retake after `has_passed`.
   Confirm whether the product wants to allow it. This plan allows it while attempts
   remain.
3. **Next-lesson resolution**: `LessonModel.order` exists, but confirm that
   `GET /user/content` filtered by `categorySubjectId` returns the same order and
   includes locked lessons. If not, hide â€œNext lessonâ€‌ and return to the lesson list.
4. **Per-question timer enforcement**: The guide exposes
   `answers[].options.default_time_seconds` but does not state that the server enforces
   it. This plan treats it as display-only. Confirm before auto-advancing or
   auto-submitting on question timeout.
5. **Word-bank versus dropdown**: The guide provides both shapes. Confirm the current
   production quizzes use `word_bank` and `dropdown` as documented, and verify a real
   payload for each.
6. **Result `solution` exposure**: It is only present when `show_correct_answers` is
   true. Do not build a review UI that assumes it always exists.
7. **Real environment fixtures**: Capture representative staging/production responses
   before merging parser changes: overview, all seven types, dropdown blanks,
   word-bank blanks, successful submit, pending-review submit, no-solution submit.
8. **Backend reason shape**: Confirm whether quiz `403`/`422` responses expose a stable
   `code`/`reason` field or only `message`/`errors`. `QuizErrorMapper` uses stable
   fields first and message matching only as a fallback.

---

## 13. Suggested Commit Sequence

1. `chore(quiz): add quiz endpoints and 403 session policy` (Phase 1)
2. `refactor(quiz): replace mock models with API attempt models` (Phase 1)
3. `feat(quiz): add quiz data source, repo, and error mapping` (Phase 2)
4. `feat(quiz): add quiz summary and lesson-detail integration` (Phase 3)
5. `feat(quiz): add quiz Cubit state machine` (Phase 4)
6. `feat(quiz): support all question types and server submissions` (Phase 5)
7. `feat(quiz): render server results, next lesson, and localization` (Phase 6)
8. `test(quiz): add fixtures, model, serializer, cubit, and widget tests` (Phase 7)
9. `chore(quiz): remove mock data source and client grader` (Phase 7)

Do not commit until the user explicitly asks.


