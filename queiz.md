# Summary — Lesson Quizzes Integration Guide (دليل ربط الاختبارات بعد الدروس)

Source: https://bilhikma.tech/guides/11a59d713e63542b/

This guide documents the end-to-end lifecycle of lesson quizzes: admin setup, question bank, quiz composition, publishing, student attempts, server-side grading, review queue, and unlocking the next lesson.

---

## 1. End-to-End Flow

A quiz belongs to exactly one lesson. It is created as a draft, published later, answered by the student in the app, and graded entirely on the server.

| Step | Actor | Action | API |
|------|-------|--------|-----|
| 1 | Teacher | Create questions in the question bank (7 types) | `POST /admin/questions` |
| 2 | Teacher | Create a quiz on a lesson (always saved as draft) | `POST /admin/quizzes` |
| 3 | Teacher | Attach questions with score & order, or define random-pull rules | `POST /admin/quizzes/{id}/questions` |
| 4 | Teacher | Publish the quiz | `PATCH /admin/quizzes/{id}` |
| 5 | Student | Tap "Go to quiz" under the lesson | `GET /user/content/{lessonId}/quiz` |
| 6 | Student | Tap "Start quiz" | `POST /user/quizzes/{quizId}/attempts` |
| 7 | Student | Answer, then tap "Finish quiz" | `POST /user/quiz-attempts/{id}/submit` |
| 8 | Server | Grades, computes result; unlocks next lesson if blocking quiz passed | `GET /user/content/{nextLessonId}` |
| 9 | Teacher | Monitor attempts and review typed answers that did not match | `GET /admin/quiz-attempts` · `/admin/answer-reviews` |

### Core Rules

- **One quiz per lesson** — a second quiz on the same lesson returns `422`.
- **Drafts are hidden** — new quizzes are always drafts; sending `is_published: true` on create is rejected.
- **Server grades everything** — the app never computes scores and never receives correct answers before submission.
- **Structure freezes after first attempt** — once any student starts an attempt, questions, scores, and order cannot change.
- **Blocking quiz** — if published and `is_blocking = true`, the next lesson stays locked (`403`) until the student passes.
- **Passing a quiz does not affect the subject grade** — result is only pass/fail.
- **Video lessons** — the quiz cannot start before the video is 100% watched (`403`).

---

## 2. Admin Dashboard

### 2.1 Question Bank

Lists all questions for the entity/subject with per-type counters and search filters.

- Cards are built entirely from `GET /admin/questions` → `data.items[]`; no extra request needed to render or edit.
- Card fields: `type`, `difficulty`, `details.choice_variant`, `details.blank_input_mode`, `calculated_difficulty`, `text`, `bank.name`, `tags[].name`, `scoring_policy`, `usage_count`, `id`, `is_active`.
- Actions:
  - Edit → `PUT /admin/questions/{id}`
  - Duplicate → `POST /admin/questions/{id}/duplicate`
  - Activate/Deactivate → `PATCH /admin/questions/{id}/active`
  - Delete (soft) → `DELETE /admin/questions/{id}` (rejected `422` if used in a published quiz)

**Filters:** `entity_id`, `category_subject_id`, `question_bank_id`, `type`, `difficulty`, `tag_id`, `is_active`, `search` (max 255 chars), `per_page` (0–1000, 0 = all), `page`.

### 2.2 Question Editor

Common fields:

| Field | Required | Notes |
|-------|----------|-------|
| `entity_id` | Yes | Owning entity |
| `category_subject_id` | No | Subject |
| `question_bank_id` | No | Bank |
| `type` | Yes | One of the 7 types (`mcq` and `short_answer` are legacy) |
| `text` | Yes | For fill-blank, contains `{{1}}`, `{{2}}` |
| `question_format` | No | `plain` · `rich` |
| `default_score` | No | 0–100 |
| `difficulty` | No | `easy` · `medium` · `hard` (default `medium`) |
| `default_time_seconds` | No | 1–7200 |
| `explanation` | No | Shown after grading if allowed |
| `image_path` / `audio_path` | No | Relative path only |
| `scoring_policy` | No | Defaults per type |
| `tag_ids` | No | Same entity |
| `is_active` | No | Available for use |
| `details` | Yes (except true/false) | Type-specific object |

- Create: `POST /admin/questions` → `201`
- Update: `PUT /admin/questions/{id}` — type cannot be changed (`422`)

### 2.3 Question Types & Creation Models

1. **`mcq_single`** — one correct answer
   - `details.options` 2–8 items, one `is_correct`
   - `choice_variant`: `standard` · `best_answer` ("choose the most correct")
2. **`mcq_multiple`** — multiple correct answers
   - `max_selections` (2–8), at least 2 correct options
3. **`true_false`**
   - `correct_answer` sent at top level (not inside `details`); returned inside `details.correct_answer`
4. **`fill_blank_choice`** — fill blank by choice
   - `blank_input_mode`: `word_bank` (shared word bank) · `dropdown` (per-blank choices)
   - `blanks[].blank_index` matches `{{n}}`; optional `score_weight`
   - Word bank items: `target_blank_index`, `is_distractor`, `is_reusable`
5. **`fill_blank_typed`** — typed answer
   - `blanks[].accepted[]` with `answer_text` and one `is_primary`
   - `max_length`
   - `normalization_flags` for Arabic text unification (10 flags: `ignore_hamza_forms`, `unify_taa_marbuta`, `unify_alef_maqsura`, `ignore_shadda`, `ignore_other_diacritics`, `remove_tatweel`, `ignore_punctuation`, `ignore_latin_case`, `collapse_spaces`, `ignore_definite_article`)
   - Optional `fuzzy_match_enabled` + `fuzzy_threshold` (50–100, UI default 90%)
   - Non-matching typed answers are not marked wrong immediately — they go to review and the attempt becomes `pending`
6. **`matching`** — connect pairs
   - 2–12 real pairs; `is_distractor` items allowed on the right
   - `score_weight` per pair; `allow_one_to_many_matching`
7. **`ordering`** — arrange items
   - 3–12 items sent **in the correct order**; server shuffles them for the student

### 2.4 Scoring Policies

| Policy | Meaning | Allowed for |
|--------|---------|-------------|
| `all_or_nothing` | Full score only if completely correct, else 0 | All types (default for single/TF) |
| `partial_credit` | Proportion of correct parts, no penalty | Multiple, fill-blank, matching |
| `partial_with_penalty` | Partial score minus penalty per wrong choice/match, floored at 0 | Multiple, matching |
| `exact_sequence` | Full only if exact order | Ordering |
| `position_based` | Share of items in correct position (`items_in_place`) | Ordering |
| `pairwise` | Share of pairs in correct relative order (`pairs_in_order`), adjacency not required | Ordering (default) |

Defaults per type: single/TF → `all_or_nothing`; multiple → `partial_with_penalty`; fill-blank → `partial_credit`; matching → `partial_credit`; ordering → `pairwise`.

### 2.5 Quiz Settings

- Create: `POST /admin/quizzes` (always draft, `201`)
- Update: `PATCH /admin/quizzes/{id}` (send only changed fields; `PUT`/`POST` also accepted)
- Read: `GET /admin/quizzes/{id}`, list: `GET /admin/quizzes?content_id={lessonId}`

| Field | Values | Meaning |
|-------|--------|---------|
| `entity_id` | Lesson entity | Must match the lesson (`422` otherwise) |
| `content_id` | Lesson ID | One quiz per lesson |
| `title` | ≤200 chars | Quiz title |
| `instructions` | Text | Shown before start |
| `pass_score` | 0–100 (null = 50) | Pass percentage |
| `max_attempts` | 1–100 (null = unlimited) | Attempt limit |
| `retry_cooldown_minutes` | 0–10080 | Wait between attempts |
| `time_limit_minutes` | 1–600 (null = no timer) | Total attempt time |
| `shuffle_questions` | true/false | Fixed shuffle per attempt |
| `is_blocking` | true/false | Locks next lesson until passed |
| `show_correct_answers` | true/false | Show solutions/breakdown after submit |
| `is_published` | false on create | Publishing |
| `selection_mode` | `manual` · `random` · `hybrid` | Question composition |
| `random_rules` | Array | Random pull rules |

Server-computed: `question_count`, `total_score` (never sent from the dashboard).

### 2.6 Composing Questions, Scores & Order

- Add/update question: `POST /admin/quizzes/{id}/questions` with `{ question_id, score, order_no }`
  - `score` 0–1000 (default `default_score`); applies to this quiz only
  - Re-sending the same question before the first attempt just updates its score
- Remove: `DELETE /admin/quizzes/{id}/questions/{questionId}` (before first attempt only)
- Reorder: `PATCH /admin/quiz-questions/{quizQuestionId}/move` with `{ prev_id, next_id }` (null allowed at edges)
- After the first attempt, add/remove/reorder returns `422` and nothing is saved.

**Random / hybrid selection**

- `selection_mode`: `manual` (default) · `random` (all pulled) · `hybrid` (manual always shown + random added)
- Rule fields: `count` (1–100), `score` (0.01–999.99), optional `tag_slug`, optional `difficulty`
- Limits: 20 rules, 100 questions, total score ≤ 9999.99; invalid rules return `422`
- Questions are pulled once per attempt and fixed for that attempt; no duplicates; insufficient bank → start rejected (`422`)

### 2.7 Publishing

`PATCH /admin/quizzes/{id}` with `{ "is_published": true }`

Requirements:
- At least one valid question, all active/complete/gradeable
- Total score > 0 and < 9999.99
- All questions from the quiz entity and subject

Otherwise `422` with `errors.is_published`. Unpublishing returns the quiz to a hidden draft.

### 2.8 Attempts Monitoring

- List: `GET /admin/quiz-attempts?quiz_id=&student_id=` (up to 200, newest first)
- Details: `GET /admin/quiz-attempts/{id}` — same structure as the submit response with grading fields
- Shows `score` / `max_score`, `is_passed`, `review_status`, `policy_snapshot`, student and quiz info

### 2.9 Answer Review Queue

Typed answers that match no accepted form go to review; the attempt becomes `pending` and cannot unlock the next lesson.

- List: `GET /admin/answer-reviews?status=pending&per_page=`
- Details: `GET /admin/answer-reviews/{id}` — includes `impact` (`pending_with_same_answer`, `attempts_affected`, `accepted_forms_in_blank`)
- Decide: `POST /admin/answer-reviews/{id}/decision`

| Decision | Meaning | `reason` |
|----------|---------|----------|
| `approve_for_student` | Accept for this student only | Optional |
| `approve_for_everyone` | Add as accepted form globally; similar pending reviews resolved | Required |
| `reject` | Keep wrong | Optional |

After a decision, the answer and attempt scores are recalculated once (no double counting) and the attempt's `review_status` becomes `resolved`.

---

## 3. Student App

### 3.1 "Go to Quiz" Button

The lesson response already tells the app whether a quiz exists — no extra request.

- `GET /user/content/{lessonId}` includes `quiz` (`null` or `{ id, is_blocking, has_passed }`)
- Button is shown when `quiz != null`; on tap calls `GET /user/content/{lessonId}/quiz`

Lesson quiz response (`200`) includes `id`, `content_id`, `title`, `instructions`, `pass_score`, `max_attempts`, `retry_cooldown_minutes`, `time_limit_minutes`, `shuffle_questions`, `is_blocking`, `show_correct_answers`, `is_published`, `selection_mode`, `question_count`, `total_score`, `attempts_used`, `attempts_left`, `has_passed`, `next_attempt_at`.

Status handling: `200` → start screen; `404` → no published quiz; `403` → locked lesson / not available to student; `401` → refresh token.

### 3.2 Quiz Start Screen

Displays `title`, `question_count`, `time_limit_minutes` (hidden if null), pass message from `pass_score`, `instructions`.

- `attempts_left` — `null` = unlimited; `0` disables start
- `has_passed` — show "Quiz passed"
- `next_attempt_at` — cooldown time; disable retry and show "You can retry after…"
- Start button → `POST /user/quizzes/{quizId}/attempts`

### 3.3 Starting an Attempt

`POST /user/quizzes/{quizId}/attempts` → `201`, returns the full attempt with all questions ready.

- Includes `id`, `attempt_no`, `expires_at`, `policy_snapshot`, and `answers[]`
- `answers[].options.details` contains display data only — **no correct answers**
- `is_correct` / `awarded_score` are `null` during the attempt
- Re-requesting while an attempt is open returns the same attempt; question order does not change

Errors: `422` quiz not published / attempts exhausted; `429` cooldown; `403` video not 100% watched / quiz not available.

### 3.4 Question Screens & Answer Formats

All answers are submitted together at the end, keyed by question ID:

```json
{ "answers": {
  "21": { "option_id": "o_1" },
  "22": { "option_ids": ["o_1", "o_2"] },
  "23": { "boolean": false },
  "14": { "blanks": { "b_1": "c_1" } },
  "15": { "blanks": { "b_1": "الشهادتان" } },
  "16": { "matches": { "6j0kdku2": "p_1", "ywmervxe": "p_2" } },
  "17": { "order": ["i_1", "i_2", "i_3", "i_4"] } } }
```

- Unanswered questions may be omitted or sent empty; counted as unanswered (0).
- IDs are sent exactly as received in `options.details`; labels or display order are not accepted.

| Type | Submitted answer | Constraint |
|------|------------------|------------|
| `mcq_single` | `{ "option_id": "o_1" }` | One option ID |
| `mcq_multiple` | `{ "option_ids": [...] }` | Unique IDs, up to `max_selections` |
| `true_false` | `{ "boolean": true }` | Real boolean; string `"false"` rejected (`422`) |
| `fill_blank_choice` (word bank) | `{ "blanks": { "b_1": "w_1" } }` | blank ID → word ID; non-reusable word cannot fill two blanks |
| `fill_blank_choice` (dropdown) | `{ "blanks": { "b_1": "c_1" } }` | blank ID → its own choice ID |
| `fill_blank_typed` | `{ "blanks": { "b_1": "text" } }` | Up to `max_length`; normalized Arabic comparison |
| `matching` | `{ "matches": { "<right_id>": "<left_id>" } }` | Each right item matched once; distractors count wrong |
| `ordering` | `{ "order": ["i_1", ...] }` | Every ID exactly once, in chosen order; missing/duplicate/unknown → `422` |

Notes:
- Display order for ordering is shuffled and fixed for the attempt; the app keeps the student's order and submits once.
- A typed answer with no accepted match goes to the review queue, making the result preliminary (`review_status = pending`).

### 3.5 Submission & Result

`POST /user/quiz-attempts/{attemptId}/submit` → `200`

Response includes:
- `score`, `max_score`, `score_percent`, `is_passed`, `review_status`
- `attempts_used`, `attempts_left`, `next_attempt_at`
- Per answer: `is_correct`, `awarded_score`, `given_answer`, `blank_results[]`, `component_results`
- `solution` (correct options/items + explanation) only when `show_correct_answers = true` and only after submission

Result screen uses:
- `is_passed` → "Passed" / "Not passed"
- `score` / `max_score` and `score_percent`
- Retry info directly from `attempts_left` and `next_attempt_at` (no extra request)
- `review_status = pending` → preliminary result, next lesson stays locked

**Submission errors:**
- `422` with `errors` — invalid ID/shape, missing/duplicate ordering, duplicate left match, text instead of ID; attempt not submitted and can be corrected
- `422` "already submitted"
- `403` — attempt belongs to another student
- After `expires_at` — submission is accepted but scores 0 (late answers not counted)

### 3.6 Unlocking the Next Lesson

After submit, the app reloads `GET /user/content` and reads `is_locked` on the next lesson (or calls `GET /user/content/{nextLessonId}`).

| Outcome | Next lesson |
|---------|-------------|
| Fail | `is_locked = true`; direct open → `403` |
| Pass | `is_locked = false`; opens (`200`) |
| Pass pending review | Still locked until resolved |
| Non-blocking quiz or draft | Never locks the next lesson |

Also: `GET /user/quizzes/{quizId}/my-attempts` returns all the student's attempts, newest first.

---

## 4. Appendix — Values & Errors

### Question Types
`mcq_single`, `mcq_multiple`, `true_false`, `fill_blank_choice`, `fill_blank_typed`, `matching`, `ordering`.

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| `200` / `201` | Success / created |
| `401` | Missing or expired token — refresh |
| `403` | Forbidden: permission, locked lesson, another student's attempt, incomplete video |
| `404` | Not found (e.g., lesson has no published quiz) |
| `422` | Validation or business-rule violation; details under `errors`; nothing saved |
| `429` | Wait before retrying |

### Shared Values

| Field | Values |
|-------|--------|
| `difficulty` | `easy` · `medium` · `hard` |
| `question_format` | `plain` · `rich` |
| `selection_mode` | `manual` · `random` · `hybrid` |
| `choice_variant` | `standard` · `best_answer` |
| `blank_input_mode` | `word_bank` · `dropdown` |
| Review decisions | `approve_for_student` · `approve_for_everyone` · `reject` |
| Review statuses | `pending` · `approved_student` · `approved_global` · `rejected` |
| Attempt review status | `none` · `pending` · `resolved` |

---

## Key Implementation Takeaways

1. **The dashboard and app must mirror server rules** — never allow creating a second quiz per lesson, publishing an invalid quiz, or editing questions after the first attempt.
2. **The app is a dumb renderer of attempt data** — send only IDs, keep display state locally (ordering), and never expect correct answers before submit.
3. **Model every state** — draft/published, attempts left, cooldown, expiry, pass/fail, pending review, locked next lesson.
4. **Handle `422` field-level errors** and show localized messages; nothing is saved on failure.
5. **Arabic typed answers need normalization** — use the provided `normalization_flags`; unmatched answers go to teacher review instead of being auto-failed.
6. **Blocking quizzes gate progression** — reload lesson lock state after every submission and respect `review_status = pending`.
