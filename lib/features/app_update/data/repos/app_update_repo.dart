import '../data_source/app_update_data_source.dart';
import '../models/app_version_model.dart';

class AppUpdateRepo {
  const AppUpdateRepo({required this.dataSource});

  final AppUpdateDataSource dataSource;

  Future<AppVersionModel?> fetch() => dataSource.fetch();

  Future<bool> openStore(String url) => dataSource.openStore(url);
}
