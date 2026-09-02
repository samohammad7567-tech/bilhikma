import '../data_source/sidebar_data_source.dart';
import '../models/sidebar_user_model.dart';

class SidebarRepo {
  const SidebarRepo({this.dataSource = const SidebarDataSource()});

  final SidebarDataSource dataSource;

  Future<SidebarUserModel> fetchUser() => dataSource.fetchUser();
}
