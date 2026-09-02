import '../constants/app_assets.dart';

enum AppTab {
  subjects(label: 'study_subjects_tab', icon: AppAssets.assetsSubjectsIcon),
  live(label: 'live_broadcast', icon: AppAssets.assetsLive),
  home(label: 'home', icon: AppAssets.assetsHomeIcon),

  saved(label: 'saved_items', icon: AppAssets.assetsSavedIcon),
  account(label: 'account', icon: AppAssets.assetsProfileIcon);

  const AppTab({required this.label, required this.icon});
  final String label;
  final String icon;
}
