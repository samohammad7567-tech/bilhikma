import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../enums/content_type_enum.dart';
import '../enums/lesson_category_enum.dart';
import '../enums/lesson_status_enum.dart';
import '../enums/media_source_enum.dart';

extension LessonCategoryView on LessonCategory {
  String get label => switch (this) {
    LessonCategory.lessons => 'lessons',
    LessonCategory.live => 'live_broadcast',
    LessonCategory.books => 'books',
    LessonCategory.pictures => 'pictures',
  };

  String get icon => switch (this) {
    LessonCategory.lessons => AppAssets.assetsVideoIcon,
    LessonCategory.live => AppAssets.assetsLive,
    LessonCategory.books => AppAssets.assetsSubjectsIcon,
    LessonCategory.pictures => AppAssets.assetsArticles,
  };
}

extension ContentTypeView on ContentType {
  String get label => switch (this) {
    ContentType.video => 'media_video',
    ContentType.audio => 'media_audio',
    ContentType.article => 'media_article',
  };

  String get filterLabel => switch (this) {
    ContentType.video => 'video_files',
    ContentType.audio => 'audio_files',
    ContentType.article => 'articles',
  };

  IconData get icon => switch (this) {
    ContentType.video => Icons.videocam_outlined,
    ContentType.audio => Icons.volume_up_outlined,
    ContentType.article => Icons.article_outlined,
  };
}

extension LessonStatusView on LessonStatus {
  String? get badgeLabel => switch (this) {
    LessonStatus.completed => 'lesson_completed',
    LessonStatus.locked => 'lesson_locked',
    LessonStatus.available || LessonStatus.inProgress => 'lesson_in_progress',
  };

  ({Color background, Color foreground}) badgeColors(ColorScheme colors) =>
      switch (this) {
        LessonStatus.locked => (
          background: colors.errorContainer,
          foreground: colors.onErrorContainer,
        ),
        LessonStatus.completed ||
        LessonStatus.available ||
        LessonStatus.inProgress => (
          background: colors.primaryContainer,
          foreground: colors.onPrimaryContainer,
        ),
      };
}

extension MediaSourceView on MediaSource {
  String get badgeLabel => switch (this) {
    MediaSource.file => 'lesson_source_file',
    MediaSource.youtube => 'lesson_source_youtube',
  };

  ({Color background, Color foreground}) badgeColors(ColorScheme colors) => (
    background: colors.secondaryContainer,
    foreground: colors.onSecondaryContainer,
  );
}
