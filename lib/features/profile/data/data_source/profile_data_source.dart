import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';

class ProfileDataSource {
  const ProfileDataSource({this.client = const ApiClient()});

  final ApiClient client;

  Future<ProfileModel> fetchProfile() => client.getObject<ProfileModel>(
    ApiEndpoints.profile,
    ProfileModel.fromJson,
  );

  Future<void> updateProfile({String? fullName, String? email}) => client.patch(
    ApiEndpoints.profile,
    data: <String, dynamic>{'full_name': ?fullName, 'email': ?email},
  );

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
