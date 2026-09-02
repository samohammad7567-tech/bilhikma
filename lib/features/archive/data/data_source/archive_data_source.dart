import '../../../lessons/data/data_source/saved_lessons_data_source.dart';
import '../../../../core/enums/content_type_enum.dart';
import '../../../../core/models/lesson_model.dart';

class ArchiveDataSource {
  const ArchiveDataSource({this.saved = const SavedLessonsDataSource()});

  final SavedLessonsDataSource saved;

  Future<List<LessonModel>> fetchSavedItems({ContentType? type}) =>
      saved.fetchSaved(type: type);
}
