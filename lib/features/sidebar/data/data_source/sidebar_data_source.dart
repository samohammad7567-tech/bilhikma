import '../../../../core/utils/error_mapper.dart';
import '../models/sidebar_user_model.dart';

class SidebarDataSource {
  const SidebarDataSource();

  Future<SidebarUserModel> fetchUser() async {
    try {
      return const SidebarUserModel(id: 'student-1', name: 'محمد محمد');
    } catch (error) {
      throw AppException(ErrorMapper.map(error));
    }
  }
}
