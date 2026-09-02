import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../widgets/home_tab.dart';
import '../../../live_sessions/presentation/screens/live_sessions_screen.dart';
import '../../../archive/presentation/screens/archive_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../subjects/presentation/screens/subjects_screen.dart';
import '../../../../core/enums/app_tab_enum.dart';

class MainShellTabs extends StatelessWidget {
  const MainShellTabs({
    required this.selectedTab,
    required this.visitedTabs,
    this.tabsEpoch = 0,
    super.key,
  });

  final AppTab selectedTab;
  final Set<AppTab> visitedTabs;

  final int tabsEpoch;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: selectedTab.index,
      children: [
        for (final tab in AppTab.values)
          visitedTabs.contains(tab)
              ? KeyedSubtree(
                  key: ValueKey<String>(
                    '${tab.name}-$tabsEpoch-${context.locale}',
                  ),
                  child: _body(context, tab),
                )
              : const SizedBox.shrink(),
      ],
    );
  }

  Widget _body(BuildContext context, AppTab tab) => switch (tab) {
    AppTab.home => const HomeTab(),
    AppTab.saved => const ArchiveScreen(showBack: false),
    AppTab.account => const ProfileScreen(showBack: false),
    AppTab.subjects => const SubjectsScreen(showBack: false),

    AppTab.live => const LiveSessionsScreen(showBack: false),
  };
}
