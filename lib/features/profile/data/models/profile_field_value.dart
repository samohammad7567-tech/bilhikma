import '../../../../core/enums/profile_field_enum.dart';
import 'profile_model.dart';

extension ProfileFieldValue on ProfileField {
  String valueOf(ProfileModel profile) => switch (this) {
    ProfileField.institution => profile.institution,
    ProfileField.academicPath => profile.academicPath,
    ProfileField.phone => profile.phone,
  };

  /// The academic path is the one field with a hierarchy behind it — stage
  /// down to the current semester. Every other field is flat, so it reports an
  /// empty path and falls back to [valueOf].
  List<String> pathOf(ProfileModel profile) => switch (this) {
    ProfileField.institution => const <String>[],
    ProfileField.academicPath => profile.educationalPath,
    ProfileField.phone => const <String>[],
  };
}
