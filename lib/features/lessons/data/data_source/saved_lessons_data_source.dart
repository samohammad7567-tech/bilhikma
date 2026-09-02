import 'package:flutter/foundation.dart';

import '../../../../core/utils/cache_util.dart';
import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/models/lessons_filter.dart';
import 'lessons_data_source.dart';

class SavedLessonsDataSource {
  const SavedLessonsDataSource({this.lessons = const LessonsDataSource()});

  final LessonsDataSource lessons;

  static const String _key = 'saved_lesson_ids';

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  Future<List<LessonModel>> fetchSaved({ContentType? type}) async {
    final Set<int> saved = savedIds();
    if (saved.isEmpty) return const <LessonModel>[];

    final List<LessonModel> all = await lessons.fetchAllLessons(
      LessonsFilter(type: type, perPage: 50),
    );

    return all
        .where((LessonModel lesson) => saved.contains(lesson.id))
        .toList(growable: false);
  }

  Set<int> savedIds() {
    final Object? raw = CacheUtil.get(key: _key);
    if (raw is! List) return <int>{};

    return raw
        .map((Object? id) => int.tryParse(id.toString()))
        .whereType<int>()
        .toSet();
  }

  Future<bool> toggle(int contentId) async {
    final Set<int> saved = savedIds();
    final bool willSave = saved.add(contentId);
    if (!willSave) saved.remove(contentId);

    await CacheUtil.setStringList(
      key: _key,
      value: saved.map((int id) => '$id').toList(growable: false),
    );

    revision.value++;

    return willSave;
  }
}
