# Plan: Migrate Flutter app from quiz endpoints to assessment endpoints

Source: `change_api_path.pdf` (task **Assessment Type**, status IN PROGRESS).

## 1. Summary of the API change

The backend is renaming the quiz API to a general **assessment** API. The Flutter app must
move from `/api/user/quizzes*` and `/api/user/quiz-attempts*` to
`/api/user/assessments*` and `/api/user/assessment-attempts*`, while keeping the existing
lesson-quiz UI, answer payloads, timer behavior and result handling unchanged.

Scope of this plan: **Flutter mobile app only** (`/api/user/...`). The admin/dashboard
paths (`/api/admin/...`) in the PDF are a separate frontend and are **out of scope** for
this repository.

### User endpoint mapping (Flutter app)

| Method | Current path | New path |
|--------|--------------|----------|
| GET | `/user/content/{id}/quiz` | `/user/content/{id}/assessment` |
| POST | `/user/quizzes/{id}/attempts` | `/user/assessments/{id}/attempts` |
| GET | `/user/quizzes/{id}/my-attempts` | `/user/assessments/{id}/my-attempts` |
| GET | `/user/quiz-attempts/{id}` | `/user/assessment-attempts/{id}` |
| PUT | `/user/quiz-attempts/{id}/answers` | `/user/assessment-attempts/{id}/answers` |
| POST | `/user/quiz-attempts/{id}/submit` | `/user/assessment-attempts/{id}/submit` |
| POST | `/user/quiz-attempts/{id}/questions/{questionId}/start` | `/user/assessment-attempts/{id}/questions/{questionId}/start` |

> The PDF clips the last column of the last four rows (`my-attemp`, `an`, `su`, `qu`).
> The full values above are the only consistent completions. Confirm once with the
> backend before merging.

### Shared contract fields

| Field | Required handling |
|-------|-------------------|
| `type` | Assessment type. Default `lesson_quiz` when absent (old response/cache). Enum: `lesson_quiz`, `midterm`, `final_exam`. Only `lesson_quiz` is enabled in Phase 1. An explicit unknown value must **not** be treated as a supported lesson quiz. |
| `assessment_id` | Attempt-response alias for `quiz_id`. Prefer `assessment_id`, fall back to `quiz_id`. |
| `assessment_question_id` | Question-attachment response alias for `quiz_question_id` (attachment ID). Prefer the new key, fall back to the old one. |
| data / existing fields | Response envelope and existing fields stay available. Unknown fields must not break deserialization. |

---

## 2. Files to change

### 2.1 Endpoint constants — `lib/core/constants/api_endpoints.dart`

Replace lines 43-59 (the 7 quiz methods) with assessment-named methods and new paths:

```dart
static String contentAssessment(int contentId) =>
    '/user/content/$contentId/assessment';

static String assessmentAttempts(int assessmentId) =>
    '/user/assessments/$assessmentId/attempts';

static String assessmentAttempt(int attemptId) =>
    '/user/assessment-attempts/$attemptId';

static String assessmentAttemptSubmit(int attemptId) =>
    '/user/assessment-attempts/$attemptId/submit';

static String assessmentAttemptAnswers(int attemptId) =>
    '/user/assessment-attempts/$attemptId/answers';

static String assessmentAttemptQuestionStart(
  int attemptId,
  String questionId,
) =>
    '/user/assessment-attempts/$attemptId/questions/$questionId/start';

static String assessmentMyAttempts(int assessmentId) =>
    '/user/assessments/$assessmentId/my-attempts';
```

Keep `contentDetail`, `contentAccessToken`, progress, etc. unchanged.

### 2.2 Data source — `lib/features/lesson_test/data/data_source/lesson_test_data_source.dart`

Update the 7 call sites to the new methods:

| Line | Old | New |
|------|-----|-----|
| 22 | `ApiEndpoints.contentQuiz(contentId)` | `ApiEndpoints.contentAssessment(contentId)` |
| 35 | `ApiEndpoints.quizAttempts(quizId)` | `ApiEndpoints.assessmentAttempts(quizId)` |
| 51 | `ApiEndpoints.quizAttemptQuestionStart(...)` | `ApiEndpoints.assessmentAttemptQuestionStart(...)` |
| 67 | `ApiEndpoints.quizAttemptAnswers(...)` | `ApiEndpoints.assessmentAttemptAnswers(...)` |
| 84 | `ApiEndpoints.quizAttemptSubmit(...)` | `ApiEndpoints.assessmentAttemptSubmit(...)` |
| 98 | `ApiEndpoints.quizAttempt(...)` | `ApiEndpoints.assessmentAttempt(...)` |
| 111 | `ApiEndpoints.quizMyAttempts(...)` | `ApiEndpoints.assessmentMyAttempts(...)` |

Optional cleanup: rename the local parameter `quizId` to `assessmentId` in
`startAttempt` / `fetchMyAttempts`. Keep the public repo/cubit naming unchanged in this
phase to keep the diff small; the internal model field can stay `quizId` (see 2.4).

### 2.3 Assessment type enum — new file `lib/core/enums/assessment_type_enum.dart`

Follow the style of `content_type_enum.dart`:

```dart
import '../network/json_reader.dart';

enum AssessmentType {
  lessonQuiz('lesson_quiz'),
  midterm('midterm'),
  finalExam('final_exam'),
  unknown('');

  const AssessmentType(this.key);

  final String key;

  bool get isLessonQuiz => this == AssessmentType.lessonQuiz;

  /// Absent -> lesson_quiz (old responses/caches).
  /// Explicit unknown value -> [unknown], never a supported lesson quiz.
  static AssessmentType fromJson(Object? value) {
    final String? raw = Json.asOptionalString(value)?.toLowerCase();
    if (raw == null) return AssessmentType.lessonQuiz;

    return AssessmentType.values.firstWhere(
      (AssessmentType type) => type.key == raw,
      orElse: () => AssessmentType.unknown,
    );
  }
}
```

### 2.4 Assessment model — `lib/features/lesson_test/data/models/lesson_test_model.dart`

- Import `assessment_type_enum.dart`.
- Add `final AssessmentType type;` with constructor default `AssessmentType.lessonQuiz`.
- Add `bool get isSupported => type.isLessonQuiz;`.
- In `fromJson` (line 68): `type: AssessmentType.fromJson(json['type'])`.
- In `toJson` (line 94): `'type': type.key`.

This satisfies "read type in the assessment model; default to `lesson_quiz` when absent;
handle an unknown explicit value safely".

### 2.5 Attempt model — `lib/features/lesson_test/data/models/quiz_attempt_model.dart`

- In `fromJson` (line 147), prefer the new alias with fallback:
  ```dart
  quizId:
      Json.asOptionalInt(json['assessment_id']) ?? Json.asInt(json['quiz_id']),
  ```
- In `toJson` (line 194), write both keys for forward compatibility:
  ```dart
  'quiz_id': quizId,
  'assessment_id': quizId,
  ```
- Keep the Dart field name `quizId` for now; it is used by the cubit and cache match
  (`cached.quizId == attempt.quizId`). No behavior change needed.

### 2.6 Local cache — `lib/features/lesson_test/data/data_source/lesson_test_local_data_source.dart`

Goal: preserve existing saved progress and open attempts; do **not** clear caches.

- `LessonTestSavedAnswersModel.fromJson` (line 35):
  ```dart
  quizId:
      int.tryParse('${json['assessment_id'] ?? json['quiz_id']}') ?? 0,
  ```
- `toJson` (line 43): keep `'quiz_id'` and add `'assessment_id': quizId`.
- Cache key remains `lesson_test_answers_$attemptId`, so existing entries keep working.
- Do not delete or migrate cache entries.

### 2.7 State gating — `lib/features/lesson_test/presentation/cubit/lesson_test_state.dart`

- Add:
  ```dart
  bool get isUnsupportedAssessment => (quiz?.isSupported ?? true) == false;
  ```
- Extend `canStart` (line 103) with `(quiz?.isSupported ?? false) && ...`.
- `hasQuiz` can stay as-is; the body renders the unsupported state separately.

### 2.8 Cubit guard — `lib/features/lesson_test/presentation/cubit/lesson_test_cubit.dart`

- In `loadQuiz` (line 163) and the resume path, after fetching the assessment, if
  `!quiz.isSupported`, emit a ready/failure state that the body can render as
  "unsupported assessment type" and do not auto-start.
- In the start flow (around `startAttempt`, line 317-352), add an early guard:
  ```dart
  if (!(state.quiz?.isSupported ?? false)) {
    reportMessage(LangKeys.assessmentUnsupportedMessage);
    return;
  }
  ```
  This prevents creating an attempt for `midterm`, `final_exam`, or unknown types.
- Keep timer, answer payload and submit logic untouched.

### 2.9 Body — `lib/features/lesson_test/presentation/refactor/lesson_test_body.dart`

- Before rendering the intro (`LessonTestIntroBody`), branch on
  `state.isUnsupportedAssessment` and render a small dedicated widget/card with the
  localized title + message. No start button, no attempt list.
- Keep the existing empty/error/failure rendering for other cases.
- File must stay under the 150-line UI limit; put the new card in
  `presentation/widgets/assessment_unsupported_view.dart` if needed.

### 2.10 Notifications — keep legacy navigation working

`lib/features/notifications/data/models/notification_payload.dart`
- Line 68: prefer the new alias:
  ```dart
  quizId:
      Json.asOptionalInt(data['assessment_id']) ?? Json.asInt(data['quiz_id']),
  ```
- Keep the `quizId` field name and all legacy keys (`quiz_id`, `quiz_attempt_id`).

`lib/core/routing/notification_destination.dart`
- Line 138: `_firstString(data, const <String>['assessment_id', 'quiz_id'])`.
- Keep the existing `quiz_id` test path working; legacy IDs remain available.
- Attempt ID keys stay `attempt_id` / `quiz_attempt_id`.

### 2.11 Attempt filtering

The Flutter app currently filters attempts by path only (`assessments/{id}/my-attempts`),
so no query change is needed. If query filtering is added later, send `assessment_id`
(`quiz_id` remains accepted by the server). The admin dashboard filtering is out of scope.

### 2.12 `assessment_question_id`

The app currently does not read `quiz_question_id` anywhere (verified). No Phase 1 code
change is required. If a later payload exposes question-attachment IDs, read
`assessment_question_id` first with `quiz_question_id` as fallback. Do not repurpose the
existing `question_id` field.

### 2.13 Unknown fields

All `fromJson` parsers read only known keys, so unknown fields are already ignored and
deserialization will not fail. Add a regression test (see 3.2) instead of changing code.

---

## 3. Tests

### 3.1 Update existing path assertions — `test/features/lesson_test/quiz_error_mapper_test.dart`

| Line | Old expectation | New expectation |
|------|-----------------|-----------------|
| 184 | `/user/content/9/quiz` | `/user/content/9/assessment` |
| 207 | `/user/quizzes/4/attempts` | `/user/assessments/4/attempts` |
| 226 | `/user/quiz-attempts/5/submit` | `/user/assessment-attempts/5/submit` |
| 245 | `/user/quizzes/4/my-attempts` | `/user/assessments/4/my-attempts` |
| 268 | `/user/quiz-attempts/77` | `/user/assessment-attempts/77` |

Add assertions for `answers` and `questions/{id}/start` paths:
- `/user/assessment-attempts/{id}/answers`
- `/user/assessment-attempts/{id}/questions/{questionId}/start`

### 3.2 Model tests — `test/features/lesson_test/quiz_models_test.dart`

- `LessonTestModel.fromJson` with no `type` -> `AssessmentType.lessonQuiz`.
- `type: 'lesson_quiz'` -> supported.
- `type: 'midterm'` / `'final_exam'` -> parsed but `isSupported == false`.
- `type: 'something_new'` -> `AssessmentType.unknown`, `isSupported == false`.
- `QuizAttemptModel.fromJson` with only `assessment_id` -> `quizId` populated.
- `QuizAttemptModel.fromJson` with only `quiz_id` (legacy) -> still populated.
- Both keys present with different values -> `assessment_id` wins.
- A response containing unknown extra keys parses successfully.

### 3.3 Cache test

- Save an old cache entry containing only `quiz_id`; verify it is still read.
- Save a new entry containing `assessment_id`; verify `quizId` is populated.
- Verify the cache key (`lesson_test_answers_$attemptId`) is unchanged.

### 3.4 Notification test — `test/notification_destination_test.dart`

- Keep the existing `quiz_id` payload test (legacy).
- Add a payload with `assessment_id` only -> same quiz-result destination.
- Add a payload with both -> `assessment_id` wins.

### 3.5 Cubit test — `test/features/lesson_test/lesson_test_cubit_test.dart`

- Assessment with `type: 'midterm'` -> `canStart == false`, start does not call the
  start-attempt endpoint, unsupported message emitted.
- `lesson_quiz` -> existing start/resume behavior unchanged.

---

## 4. Localization keys

Add to **both** `assets/translations/ar.json` and `assets/translations/en.json`, and add
constants to `lib/core/localization/lang_keys.dart`:

| Key | English | Arabic (suggested) |
|-----|---------|--------------------|
| `assessment_unsupported_title` | `Assessment not available` | `الاختبار غير متاح` |
| `assessment_unsupported_message` | `This assessment type is not supported in the app yet.` | `نوع هذا الاختبار غير مدعوم في التطبيق حالياً.` |

Use `context.translate(LangKeys.assessmentUnsupportedTitle)` /
`LangKeys.assessmentUnsupportedMessage.tr()`. No raw translation strings.

---

## 5. Backward-compatibility / migration rules

- **Do not** clear student data, saved answers, caches or open attempts.
- **Do not** create a replacement attempt during migration. Attempt IDs are unchanged.
- Existing cache entries (keyed by attempt ID) must keep loading; `quiz_id` remains a
  readable alias.
- Notification payloads that still carry only `quiz_id` / `quiz_attempt_id` must continue
  to navigate correctly.
- Explicit `midterm` / `final_exam` / unknown types must be blocked in the UI, not
  silently treated as lesson quizzes.

---

## 6. Verification

1. `flutter analyze` — must be clean.
2. `flutter test` — update/add the tests in section 3; all must pass.
3. Manual smoke test against the new API:
   - Open a lesson with a lesson quiz -> overview loads from
     `/user/content/{id}/assessment`.
   - Start -> `POST /user/assessments/{id}/attempts`.
   - Resume an open attempt -> same attempt ID, saved answers restored.
   - Save answers -> `PUT /user/assessment-attempts/{id}/answers`.
   - Submit -> `POST /user/assessment-attempts/{id}/submit`; result review loads.
   - Question timer start -> `POST /user/assessment-attempts/{id}/questions/{questionId}/start`.
   - Notification with `quiz_id` only and with `assessment_id` only both open the result.
4. No `build_runner` needed (no code generation in this change).

---

## 7. Checklist

- [ ] `api_endpoints.dart` user quiz paths replaced with assessment paths.
- [ ] `lesson_test_data_source.dart` calls the new endpoint methods.
- [ ] `AssessmentType` enum added with absent -> `lesson_quiz`, unknown -> unsupported.
- [ ] `LessonTestModel` reads `type` and exposes `isSupported`.
- [ ] `QuizAttemptModel` prefers `assessment_id`, falls back to `quiz_id`.
- [ ] Local cache reads/writes both aliases without clearing data.
- [ ] `canStart` and cubit start guard block unsupported types.
- [ ] Unsupported-assessment UI state added.
- [ ] Notification payload + destination prefer `assessment_id`, keep legacy keys.
- [ ] Existing path assertions and new alias/type tests updated.
- [ ] Localization keys added to `ar.json`, `en.json`, `LangKeys`.
- [ ] `flutter analyze` and `flutter test` pass.
- [ ] Confirm the clipped new paths and the `final_exam` enum value with the backend.
