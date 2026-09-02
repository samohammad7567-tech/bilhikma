import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated_result.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/models/lessons_filter.dart';

class LessonsDataSource {
  const LessonsDataSource({this.client = const ApiClient()});

  final ApiClient client;

  Future<PaginatedResult<LessonModel>> fetchLessons([
    LessonsFilter filter = const LessonsFilter(),
  ]) => client.getPage<LessonModel>(
    ApiEndpoints.content,
    LessonModel.fromJson,
    queryParameters: filter.toQueryParameters(),
  );

  Future<List<LessonModel>> fetchAllLessons([
    LessonsFilter filter = const LessonsFilter(perPage: 50),
  ]) async {
    PaginatedResult<LessonModel> page = await fetchLessons(filter);
    final List<LessonModel> all = <LessonModel>[...page.items];

    LessonsFilter current = filter;

    for (int i = 0; i < 20 && page.hasMore; i++) {
      current = current.copyWith(page: page.meta.nextPage);
      page = await fetchLessons(current);
      all.addAll(page.items);
    }

    return all;
  }
}
