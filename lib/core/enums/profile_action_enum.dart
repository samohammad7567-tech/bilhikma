import '../constants/app_assets.dart';

enum ProfileAction {
  editInformation(label: 'edit_information'),
  changePassword(label: 'change_password'),
  downloadsLog(label: 'downloads_log');

  const ProfileAction({required this.label});
  final String label;
  String get imagePath => switch (this) {
    ProfileAction.editInformation => AppAssets.assetsProfileIcon,
    ProfileAction.changePassword => AppAssets.assetsLockIcon,
    ProfileAction.downloadsLog => AppAssets.assetsDownloadIcon,
  };
}
