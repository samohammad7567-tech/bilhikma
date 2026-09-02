import '../../../../core/network/paginated_result.dart';
import '../data_source/lessons_data_source.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/models/lessons_filter.dart';

class LessonsRepo {
  const LessonsRepo({this.dataSource = const LessonsDataSource()});

  final LessonsDataSource dataSource;

  Future<PaginatedResult<LessonModel>> fetchLessons([
    LessonsFilter filter = const LessonsFilter(),
  ]) => dataSource.fetchLessons(filter);

  Future<List<LessonModel>> fetchAllLessons([
    LessonsFilter filter = const LessonsFilter(perPage: 50),
  ]) => dataSource.fetchAllLessons(filter);
}
