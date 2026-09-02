import 'dart:convert';

import '../../../../core/utils/cache_util.dart';
import '../models/lesson_playback_state_model.dart';

class LessonPlaybackDataSource {
  const LessonPlaybackDataSource();

  static String _key(int contentId) => 'lesson_playback_$contentId';

  LessonPlaybackStateModel read(int contentId) {
    final Object? raw = CacheUtil.get(key: _key(contentId));
    if (raw is! String || raw.isEmpty) {
      return LessonPlaybackStateModel(contentId: contentId);
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return LessonPlaybackStateModel(contentId: contentId);
      }

      return LessonPlaybackStateModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } on FormatException {
      return LessonPlaybackStateModel(contentId: contentId);
    }
  }

  Future<void> write(LessonPlaybackStateModel state) => CacheUtil.setString(
    key: _key(state.contentId),
    value: jsonEncode(state.toJson()),
  );

  void clear(int contentId) => CacheUtil.remove(key: _key(contentId));
}
