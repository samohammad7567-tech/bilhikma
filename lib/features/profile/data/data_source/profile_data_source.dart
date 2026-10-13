import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/models/auth_user_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/current_user.dart';
import '../models/profile_model.dart';

class ProfileDataSource {
  const ProfileDataSource({this.client = const ApiClient()});

  final ApiClient client;

  Future<ProfileModel> fetchProfile() async {
    final ProfileModel profile = await client.getObject<ProfileModel>(
      ApiEndpoints.profile,
      ProfileModel.fromJson,
    );

    await CurrentUser.saveFields(fullName: profile.name, email: profile.email);

    return profile;
  }

  Future<void> updateProfile({String? fullName, String? email}) async {
    await client.patch(
      ApiEndpoints.profile,
      data: <String, dynamic>{'full_name': ?fullName, 'email': ?email},
    );

    await CurrentUser.saveFields(fullName: fullName, email: email);
  }

  /// The user saved at login, so the drawer and the profile tab can show a
  /// name immediately instead of an empty card while the request is in flight.
  ProfileModel? cachedProfile() {
    final AuthUserModel? user = CurrentUser.cachedUser();
    if (user == null) return null;

    return ProfileModel(
      id: '${user.id}',
      name: user.fullName,
      email: user.email ?? '',
      phone: user.phone ?? '',
      studentNo: user.studentNo ?? '',
      canCaptureScreen: user.canCaptureScreen,
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => client.post(
    ApiEndpoints.profilePassword,
    data: <String, dynamic>{
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPassword,
    },
  );
}
