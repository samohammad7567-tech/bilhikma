import '../../../../core/models/lesson_model.dart';
import '../data_source/search_data_source.dart';

class SearchRepo {
  const SearchRepo({this.dataSource = const SearchDataSource()});

  final SearchDataSource dataSource;

  Future<List<LessonModel>> search(String query) => dataSource.search(query);
}
