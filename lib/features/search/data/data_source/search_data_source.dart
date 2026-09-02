import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/paginated_result.dart';
import '../../../../core/models/lesson_model.dart';

class SearchDataSource {
  const SearchDataSource({this.client = const ApiClient()});

  final ApiClient client;

  static const int _perPage = 50;

  static const int _targetResults = 50;

  static const int _maxPages = 10;

  Future<List<LessonModel>> search(String query) async {
    final String searchWord = query.trim();
    if (searchWord.isEmpty) return const <LessonModel>[];

    final List<LessonModel> unlocked = <LessonModel>[];
    int pageNumber = 1;

    for (int i = 0; i < _maxPages; i++) {
      final PaginatedResult<LessonModel> page = await _fetchPage(
        searchWord,
        pageNumber,
      );

      unlocked.addAll(
        page.items.where((LessonModel lesson) => !lesson.isLocked),
      );

      if (!page.hasMore || unlocked.length >= _targetResults) break;

      pageNumber = page.meta.nextPage;
    }

    return unlocked.toList(growable: false);
  }

  Future<PaginatedResult<LessonModel>> _fetchPage(
    String searchWord,
    int page,
  ) => client.getPage<LessonModel>(
    ApiEndpoints.content,
    LessonModel.fromJson,
    queryParameters: <String, dynamic>{
      'search': searchWord,
      'page': page,
      'per_page': _perPage,
    },
  );
}
