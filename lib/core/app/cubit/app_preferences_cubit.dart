import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/settings/data/data_source/settings_data_source.dart';
import '../../constants/cache_keys.dart';
import '../../enums/app_tab_enum.dart';
import '../../utils/cache_util.dart';

part 'app_preferences_state.dart';

enum ShellBackAction { none, confirmExit, exit }

class AppPreferencesCubit extends Cubit<AppPreferencesState> {
  AppPreferencesCubit() : super(AppPreferencesInitial());

  bool isDark = CacheUtil.get(key: CacheKeys.isDark) ?? false;
  double fontScale = SettingsDataSource.readFontScale();
  AppTab selectedTab = AppTab.home;
  final Set<AppTab> visitedTabs = <AppTab>{AppTab.home};

  void changeTheme(bool isDark) {
    this.isDark = isDark;
    CacheUtil.setBool(key: CacheKeys.isDark, value: isDark);
    emit(AppPreferencesThemeChanged());
  }

  void applyFontScale(double scale) {
    if (scale == fontScale) return;

    fontScale = scale;
    emit(AppPreferencesFontScaleChanged());
  }

  void selectTab(AppTab tab) {
    if (tab == selectedTab) return;

    selectedTab = tab;
    visitedTabs.add(tab);
    emit(AppPreferencesTabChanged());
  }

  int tabsEpoch = 0;

  void resetTabs() {
    tabsEpoch++;

    visitedTabs
      ..clear()
      ..add(AppTab.home);

    selectedTab = AppTab.home;
    emit(AppPreferencesTabChanged());
  }

  static const Duration exitWindow = Duration(seconds: 2);

  DateTime? _lastBackPress;

  ShellBackAction handleBackPress() {
    if (selectedTab != AppTab.home) {
      selectTab(AppTab.home);
      _lastBackPress = null;
      return ShellBackAction.none;
    }

    final DateTime now = DateTime.now();
    final DateTime? previous = _lastBackPress;

    if (previous != null && now.difference(previous) <= exitWindow) {
      _lastBackPress = null;
      return ShellBackAction.exit;
    }

    _lastBackPress = now;
    return ShellBackAction.confirmExit;
  }
}
