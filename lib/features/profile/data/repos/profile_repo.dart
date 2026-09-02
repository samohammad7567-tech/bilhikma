import '../data_source/profile_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepo {
  const ProfileRepo({this.dataSource = const ProfileDataSource()});

  final ProfileDataSource dataSource;

  Future<ProfileModel> fetchProfile() => dataSource.fetchProfile();

  Future<void> updateProfile({String? fullName, String? email}) =>
      dataSource.updateProfile(fullName: fullName, email: email);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => dataSource.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
  );
}
