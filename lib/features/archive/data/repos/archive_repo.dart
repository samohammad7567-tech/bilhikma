import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/models/lesson_model.dart';
import '../data_source/archive_data_source.dart';

class ArchiveRepo {
  const ArchiveRepo({this.dataSource = const ArchiveDataSource()});

  final ArchiveDataSource dataSource;

  Future<List<LessonModel>> fetchSavedItems({ContentType? type}) =>
      dataSource.fetchSavedItems(type: type);
}
