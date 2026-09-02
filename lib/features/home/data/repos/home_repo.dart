import '../../../../core/models/live_session_model.dart';
import '../data_source/home_data_source.dart';
import '../models/home_overview_model.dart';

class HomeRepo {
  const HomeRepo({this.dataSource = const HomeDataSource()});

  final HomeDataSource dataSource;

  Future<HomeOverviewModel> fetchOverview() => dataSource.fetchOverview();

  Future<LiveSessionModel?> fetchHighlightedSession() =>
      dataSource.fetchHighlightedSession();

  Future<List<String>> fetchEducationalPath() =>
      dataSource.fetchEducationalPath();
}
