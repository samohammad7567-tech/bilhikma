# خطة تنفيذ المهمة الأولى — قفل الدروس وتقارير نقاط التفتيش (Checkpoints)

> المرجع: `first_task.md` + عقد الـ API المحدَّث `Bilhikma Platform API.openapi.json`
> تاريخ التنفيذ: 2026-08-25
> **الحالة: مكتملة.** `flutter analyze` = لا أخطاء جديدة (9 تنبيهات قائمة مسبقاً في ملفات غير متعلّقة بالمهمة).

---

## 0. ما تغيّر في الباك-إند (من ملف OpenAPI) وأثره على التطبيق

قرأتُ عقد الـ API المحدَّث وقارنتُه بنماذج التطبيق. النتائج:

| ما ينصّ عليه العقد | حالة التطبيق | الإجراء |
|---|---|---|
| `POST /user/content/{content}/progress` — الحقل **`watched_delta_seconds` مطلوب** في جسم الطلب (`required: [position_seconds, watched_delta_seconds]`) | ❌ كان يُحذف من الـ JSON عندما تكون قيمته `null`، وزر «تمت قراءة المقال» كان يرسل `position_seconds` فقط | ✅ **أُصلح** — الحقل يُرسَل دائماً |
| حدّ أقصى لـ `watched_delta_seconds` = **3600** | ❌ لا يوجد تقييد | ✅ **أُصلح** — قصّ عند 3600 |
| استجابة **422** تُعيد كائن `data` كاملاً: `allowed_position_seconds` + `max_position_seconds` + `watched_seconds` + `progress_percent` + `is_completed` | ⚠️ كان يُقرأ منها `allowed_position_seconds` فقط | ✅ **أُصلح** — تُقرأ كاملة وتُحدَّث بها حالة التقدّم |
| استجابة **403** جسمها `{message, status_code: 0}` بلا `data`، والرسالة **مُترجَمة من السيرفر** | ✅ `ErrorMapper` يحفظ `message` و`AppErrorView` يفضّلها | ✅ سليم |
| `progress` في القائمة **nullable** (يعود `null` للدرس المقفل) | ✅ `Json.asMap(null)` تُعيد `{}` والقيم الافتراضية تعمل | ✅ سليم |
| `duration_seconds` في القائمة **nullable** | ✅ `Json.asInt(null)` تُعيد 0 | ✅ سليم |
| `progress` في القائمة والتفاصيل لم يعد يحمل `watched_seconds` ولا `allowed_position_seconds` | ✅ الحقلان اختياريان في `LessonProgressModel` بقيم افتراضية | ✅ سليم |
| `article_body` يعود من endpoint التفاصيل فقط ولدرس مفتوح فقط | ✅ `LessonModel` لا يقرأه إطلاقاً | ✅ سليم |
| `checkpoints` تعود مصفوفة فارغة `[]` للمقالات والدروس المقفلة | ✅ `Json.asIntList` + `nextCheckpointSeconds` تُعيد `null` | ✅ سليم |
| مسارات الـ endpoints (`/user/content`, `/{content}`, `/access-token`, `/progress`, `/attachments/{attachment}/access-token`) | ✅ مطابقة لـ `ApiEndpoints` | ✅ سليم |

> **الخلاصة:** التعارض الوحيد الفعلي مع الباك-إند الجديد كان `watched_delta_seconds` المطلوب —
> وكان سيؤدّي إلى فشل زر «تمت قراءة المقال» بـ 422 وبالتالي عدم فتح الدرس التالي إطلاقاً.

---

## 1. التعديلات المنفَّذة

### ✅ التعديل 1 — `watched_delta_seconds` مطلوب دائماً ومقصوص عند 3600

**الملف:** `lib/core/models/lesson_progress_model.dart`

كان الحقل `int?` ويُحذف من الـ JSON عند `null`، وهو ما يخالف العقد الجديد.
صار `int` بقيمة افتراضية `0`، ويُرسَل دائماً، مع قصّ القيم السالبة إلى 0 والقيم فوق 3600 إلى 3600.

```dart
class ProgressHeartbeatRequestModel {
  const ProgressHeartbeatRequestModel({
    required this.positionSeconds,
    this.watchedDeltaSeconds = 0,
  });

  static const int maxWatchedDeltaSeconds = 3600;

  final int positionSeconds;
  final int watchedDeltaSeconds;

  int get _position => positionSeconds < 0 ? 0 : positionSeconds;

  int get _delta {
    if (watchedDeltaSeconds < 0) return 0;
    if (watchedDeltaSeconds > maxWatchedDeltaSeconds) {
      return maxWatchedDeltaSeconds;
    }
    return watchedDeltaSeconds;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'position_seconds': _position,
    'watched_delta_seconds': _delta,
  };
}
```

**الأثر:** `markArticleRead` الذي يرسل `ProgressHeartbeatRequestModel(positionSeconds: 0)`
صار يُرسِل `{"position_seconds": 0, "watched_delta_seconds": 0}` — مطابق للعقد.

---

### ✅ التعديل 2 — قراءة جسم 422 كاملاً

**الملف:** `lib/features/lesson_detail/data/data_source/lesson_detail_data_source.dart`

استجابة 422 تحمل كائن تقدّم كامل، لا `allowed_position_seconds` فقط. صار يُقرأ كاملاً
حتى تُحدَّث شريحة التقدّم في الواجهة من قيم السيرفر لا من العدّاد المحلي.

```dart
} on AppException catch (error) {
  if (error.statusCode != 422) rethrow;

  final Map<String, dynamic> body = Json.asMap(error.data);

  return ProgressResult(
    progress: body.isEmpty ? null : LessonProgressModel.fromJson(body),
    allowedPositionSeconds: Json.asOptionalInt(
      body['allowed_position_seconds'],
    ),
    seekRejected: true,
  );
}
```

---

### ✅ التعديل 3 — إصلاح ضياع الثواني أثناء إرسال نقطة التفتيش (خطأ فعلي)

**الملف:** `lib/features/lesson_detail/presentation/cubit/lesson_detail_cubit.dart`

**المشكلة:** كان يتم تصفير `watchedDeltaSeconds` إلى 0 بعد نجاح الإرسال، لكن نبضات
الثانية تستمرّ أثناء انتظار الاستجابة. التصفير كان يبتلع تلك الثواني فيصل الربع التالي
بحضور ناقص، والسيرفر يحتسبه كذلك.

**الحل:** التقاط القيمة المُرسَلة قبل `await` وطرحها بدل التصفير:

```dart
final int sentDelta = state.watchedDeltaSeconds;   // قبل الـ await
...
final int carried = state.watchedDeltaSeconds - sentDelta;

emit(
  state.copyWith(
    progress: result.progress,
    checkpointIndex: state.checkpointIndex + 1,
    watchedDeltaSeconds: carried < 0 ? 0 : carried,
  ),
);
```

---

### ✅ التعديل 4 — حارس ضد إعادة إرسال نفس نقطة التفتيش بعد 422

**الملف:** نفس الـ Cubit

العقد ينصّ صراحةً: «report the checkpoints in order and never two back to back:
each one is measured against how much wall-clock time has actually passed».
بعد رفض 422 كنّا نُرجع المشغّل إلى `allowed_position_seconds` دون رفع `checkpointIndex`،
فلو كانت القيمة المسموحة ≥ نقطة التفتيش تُعاد نفس القيمة في النبضة التالية مباشرة.

```dart
static const Duration _correctionCooldown = Duration(seconds: 5);

DateTime? _correctedAt;

bool get _isCoolingDown {
  final DateTime? correctedAt = _correctedAt;
  if (correctedAt == null) return false;

  return DateTime.now().difference(correctedAt) < _correctionCooldown;
}
```

يُفحَص داخل `_reportDueCheckpoint`، ويُضبط `_correctedAt` داخل `_applyCorrection`
التي صارت تستقبل أيضاً كائن التقدّم القادم من جسم 422 وتُحدّث به الحالة.

---

### ✅ التعديل 5 — تحديث حالة القفل بعد الإكمال في كل الشاشات (البند 2.11)

`is_locked` غير قابلة للتخزين المؤقّت، فأي قائمة معروضة يجب أن تُعاد قراءتها بعد الرجوع من الدرس.

| الشاشة | قبل | بعد |
|---|---|---|
| `subject_content_screen.dart` | ✅ `reloadAfterLesson()` | بلا تغيير |
| `lessons_view_all_screen.dart` | ✅ `cubit.refresh()` | بلا تغيير |
| `archive_screen.dart` | ❌ لا تُحدّث | ✅ `await cubit.silentRefresh()` بعد `pushNamed` |
| `home_screen.dart` (متابعة الدرس) | ❌ لا تُحدّث | ✅ `await cubit.refresh()` بعد `pushNamed` |

في الشاشتين تُلتقَط الـ Cubit **قبل** الانتقال ولا يُستخدم `context` بعد `await`.
في `home_screen.dart` استُخرِج المُعالِج إلى دالة `_openLesson` مستقلّة بدل التعبير المباشر.

---

### ✅ التعديل 6 — شاشة قفل مخصّصة بدل شاشة الخطأ (حالة الرابط العميق)

**ملف جديد:** `lib/features/lesson_detail/presentation/widgets/lesson_locked_view.dart` (75 سطراً)
**ملف معدَّل:** `lib/features/lesson_detail/presentation/refactor/lesson_detail_body.dart`

كان أي فشل — بما فيه 403 — يعرض `AppErrorView` بزرّ «إعادة المحاولة»، وإعادة المحاولة
على درس مقفل لا يمكن أن تنجح أبداً. صار التمييز عبر `state.isLocked`:

```dart
if (state.hasFailed && state.isLocked) {
  return LessonLockedView(
    message: state.errorMessage,
    onBack: () => Navigator.of(context).maybePop(),
  );
}

if (state.hasFailed) {
  return AppErrorView(
    errorKey: state.errorKey,
    message: state.errorMessage,
    onRetry: cubit.loadLesson,
  );
}
```

الويدجت تعرض أيقونة قفل + `message` القادمة من السيرفر (مُترجَمة مسبقاً كما ينصّ العقد)
وتسقط إلى مفتاح محلّي فقط إن لم يُرسِل السيرفر رسالة، وزرّ رجوع بدل إعادة المحاولة.

---

### ✅ التعديل 7 — دقّة عدّاد المشاهدة أثناء التخزين المؤقّت

**الملف:** `lib/features/lesson_detail/presentation/refactor/lesson_playback_reporter.dart`

العقد ينصّ أن `watched_delta_seconds` «is validated, never trusted: claiming more playback
than wall-clock time allows is capped silently». احتساب ثواني الـ buffering كان يضخّم
الرقم بلا فائدة ويعرّضه للقصّ.

```dart
final bool hasPlayedASecond = isPlaying && !playback.isBuffering;

_lastPositionSeconds = seconds;

onTick(seconds, hasPlayedASecond ? 1 : 0);
```

---

### ✅ التعديل 8 — مفاتيح الترجمة الجديدة

أُضيفت إلى `assets/translations/ar.json` و `en.json` (نفس الموضع في الملفَّين):

| المفتاح | العربية | الإنجليزية |
|---|---|---|
| `lesson_locked_title` | هذا الدرس مقفل | This lesson is locked |
| `lesson_locked_hint` | أكمل الدرس السابق في نفس المادة لفتحه | Finish the previous lesson in the same subject to unlock it |
| `back_to_lessons` | العودة إلى الدروس | Back to lessons |

المفاتيح القائمة مسبقاً ولم تحتج تغييراً: `lesson_locked` · `mark_article_read` ·
`article_read` · `article_read_done` · `video_no_skip_note` · `access_denied`.

---

### ✅ التعديل 9 — تنظيف استيراد مخالف

`lib/core/widgets/lesson_lock_scrim.dart` كان يستورد `package:bilhikma/core/...`
داخل `lib/` وهو مخالف لقاعدة المشروع. حُوِّل إلى استيراد نسبي.

---

## 2. قرار معماري: التخزين المحلي بقي على SharedPreferences

البند 2.2 في المهمة يذكر «صندوق Hive». **القرار المتَّخذ: الإبقاء على `CacheUtil`
(SharedPreferences)** الذي يستخدمه المشروع بالفعل، للأسباب التالية:

- السلوك المطلوب مطابق تماماً: مفتاح لكل `content_id` يحمل `position_seconds` و
  `watched_delta_seconds` و `next_checkpoint_index`، كتابة عند كل نبضة، ولا شيء بينها.
- لا يُضيف اعتمادية جديدة ولا خطوة تهيئة إضافية في `main.dart`.
- `LessonPlaybackDataSource` يعزل التخزين خلف واجهة واحدة (`read` / `write` / `clear`)،
  فالانتقال إلى Hive لاحقاً يمسّ هذا الملف وحده دون أي تغيير في الـ Cubit.

الملف المعني: `lib/features/lesson_detail/data/data_source/lesson_playback_data_source.dart` (بلا تغيير).

---

## 3. الملفات المتأثّرة

**معدَّلة (8):**
1. `lib/core/models/lesson_progress_model.dart`
2. `lib/core/widgets/lesson_lock_scrim.dart`
3. `lib/features/lesson_detail/data/data_source/lesson_detail_data_source.dart`
4. `lib/features/lesson_detail/presentation/cubit/lesson_detail_cubit.dart`
5. `lib/features/lesson_detail/presentation/refactor/lesson_playback_reporter.dart`
6. `lib/features/lesson_detail/presentation/refactor/lesson_detail_body.dart`
7. `lib/features/archive/presentation/screens/archive_screen.dart`
8. `lib/features/home/presentation/screens/home_screen.dart`

**جديدة (1):**
9. `lib/features/lesson_detail/presentation/widgets/lesson_locked_view.dart`

**بيانات (2):** `assets/translations/ar.json` · `assets/translations/en.json`

---

## 4. حالة التسليم

- **`build_runner`:** **غير مطلوب.** لا توجد نماذج مولَّدة في المشروع؛ كل النماذج مكتوبة
  يدوياً بـ `fromJson` / `toJson`.
- **`flutter analyze`:** **لا أخطاء ولا تنبيهات جديدة.** التنبيهات التسعة الظاهرة
  كلها قائمة قبل هذه المهمة وفي ملفات لا علاقة لها بها
  (`cache_keys.dart`, `drawer_brand_header.dart`, `lesson_category_enum.dart`,
  `audio_player_handler.dart`, `main_shell_view.dart`, `search_results.dart`,
  `settings_choice_card.dart`, `main.dart`).
- **`dart format`:** طُبِّق على كل الملفات المعدَّلة.
- **حجم الملفات:** الويدجت الجديدة 75 سطراً (الحدّ 150). `lesson_detail_cubit.dart`
  هو Cubit فلا سقف لحجمه.
- **الاستيرادات:** لا يوجد أي `package:bilhikma/...` في أي من ملفات هذه المهمة.
  لكن **13 ملفاً آخر خارج نطاق المهمة ما زالت مخالفة** (قائمة قبل هذه المهمة ولم تُمَس):
  `bilhikma_app.dart` · `drawer_brand_header.dart` · `drawer_profile_card.dart` ·
  `drawer_profile_initials.dart` · `settings_action_enum.dart` · `current_user.dart` ·
  `login_data_source.dart` · `login_repo.dart` · `home_tab.dart` ·
  `settings_language_card.dart` · `settings_theme_card.dart`.
  تنظيفها عمل مستقلّ يمسّ ميزات أخرى (Drawer, Settings, Auth, MainShell).

---

## 5. خطة الاختبار على البيانات المزروعة

البيانات تحت `category_subject_id = 20`:

| المحتوى | النوع | الحالة الابتدائية |
|---|---|---|
| 10 | فيديو 10 ثوانٍ، `checkpoints [2,5,7,10]` | مفتوح |
| 11 | مقال | مقفل حتى إكمال 10 |
| 12 | صوت 12 ثانية، `checkpoints [3,6,9,12]` | مقفل حتى قراءة 11 |

1. افتح المادة 20 — يظهر 11 و 12 بأيقونة القفل، والنقر عليهما يُظهر `lesson_locked`
   ولا يفتح شاشة التفاصيل.
2. شغّل الدرس 10 كاملاً بلا لمس — راقب الشبكة: **أربع طلبات فقط** على
   `POST /user/content/10/progress` عند الثواني 2 و 5 و 7 و 10، ولا شيء بينها.
3. تحقّق أن **كل** طلب يحمل `watched_delta_seconds` (التعديل 1) وأن آخر استجابة
   تحمل `is_completed: true` و `progress_percent: 100`.
4. بعد الرجوع تُعاد قراءة قائمة الدروس ويصبح 11 مفتوحاً.
5. افتح 11 واضغط «تمت قراءة المقال» — طلب واحد بجسم
   `{"position_seconds": 0, "watched_delta_seconds": 0}` يعود بـ 200 لا 422
   (هذا هو الإصلاح الأهم مقابل الباك-إند الجديد)، ثم يتحوّل الزر إلى مؤشّر
   «تمت القراءة»، وبعد الرجوع يصبح 12 مفتوحاً.
6. في الدرس 12 اسحب شريط التقدّم للأمام — يتوقّف عند `max_position_seconds` ويظهر
   `video_no_skip_note` دون أي طلب شبكة.
7. أغلق التطبيق في منتصف الدرس 12 ثم أعد فتحه — يستأنف من الموضع المخزَّن ولا يُعاد
   إرسال أي نقطة تفتيش سبق تجاوزها.
8. **اختبار 422:** يجب أن يقفز المشغّل إلى `allowed_position_seconds` بلا حوار ولا
   رسالة خطأ، وألّا يُعاد إرسال نفس نقطة التفتيش خلال الخمس ثوانٍ التالية (التعديل 4).
9. **اختبار 403:** افتح 12 قبل فتحه (رابط عميق) — تظهر شاشة القفل الجديدة برسالة
   السيرفر وزر «العودة إلى الدروس» لا «إعادة المحاولة»، و**لا** يخرج المستخدم من
   الحساب (تحقّق أن `refresh_token` ما زال محفوظاً).
10. **اختبار الأرشيف والرئيسية:** افتح درساً من شاشة المحفوظات ومن بطاقة «متابعة»
    في الرئيسية، أكمله، ارجع — يجب أن تُعاد قراءة القائمة وتتحدّث حالة القفل (التعديل 5).
