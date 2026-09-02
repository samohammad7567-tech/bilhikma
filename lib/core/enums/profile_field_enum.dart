import '../constants/app_assets.dart';

enum ProfileField {
  institution(label: 'institution'),
  academicPath(label: 'academic_path'),
  phone(label: 'phone_number');

  const ProfileField({required this.label});

  final String label;

  String get imagePath => switch (this) {
    ProfileField.institution => AppAssets.assetsBookIcon,
    ProfileField.academicPath => AppAssets.assetsClassIcon,
    ProfileField.phone => AppAssets.assetsPhoneIconFilled,
  };
}
