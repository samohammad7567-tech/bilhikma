import '../constants/app_assets.dart';
import 'content_type_enum.dart';

enum ArchiveFilter {
  audios(ContentType.audio),
  videos(ContentType.video),
  articles(ContentType.article);

  const ArchiveFilter(this.mediaType);

  final ContentType mediaType;

  String get label => switch (this) {
    ArchiveFilter.audios => 'audio_files',
    ArchiveFilter.videos => 'video_files',
    ArchiveFilter.articles => 'articles',
  };
  String get imagePath => switch (this) {
    ArchiveFilter.audios => AppAssets.assetsAudios,
    ArchiveFilter.videos => AppAssets.assetsVideos,
    ArchiveFilter.articles => AppAssets.assetsArticles,
  };
}
