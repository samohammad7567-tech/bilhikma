import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app/cubit/app_preferences_cubit.dart';
import '../../../../core/utils/my_screen_size.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_nav_rail.dart';
import '../../../../core/drawer/presentation/refactor/app_drawer.dart';
import '../refactor/main_shell_tabs.dart';

class MainShellView extends StatelessWidget {
  const MainShellView({required this.onBack, super.key});

  final void Function(BuildContext context, ShellBackAction action) onBack;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesCubit, AppPreferencesState>(
      buildWhen: (AppPreferencesState previous, AppPreferencesState current) =>
          current is AppPreferencesTabChanged,
      builder: (BuildContext context, AppPreferencesState state) {
        final AppPreferencesCubit cubit = context.read<AppPreferencesCubit>();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop) return;
            onBack(context, cubit.handleBackPress());
          },
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final Widget tabs = MainShellTabs(
                selectedTab: cubit.selectedTab,
                visitedTabs: cubit.visitedTabs,
                tabsEpoch: cubit.tabsEpoch,
              );
              final bool isWide = MyScreenSize.isTablet(context);

              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                extendBody: true,
                drawer: const AppDrawer(),
                body: isWide
                    ? _wideBody(context, constraints, cubit, tabs)
                    : tabs,
                bottomNavigationBar: isWide
                    ? null
                    : AppBottomNavBar(
                        selectedTab: cubit.selectedTab,
                        onTabSelected: cubit.selectTab,
                      ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _wideBody(
    BuildContext context,
    BoxConstraints constraints,
    AppPreferencesCubit cubit,
    Widget tabs,
  ) {
    final double availableWidth = math.max(
      0,
      constraints.maxWidth - MyScreenSize.navRailWidth(context),
    );
    final double contentWidth = math.min(
      availableWidth,
      MyScreenSize.contentMaxWidth(context),
    );

    return Row(
      children: <Widget>[
        AppNavRail(
          selectedTab: cubit.selectedTab,
          onTabSelected: cubit.selectTab,
        ),
        Expanded(
          child: Center(
            child: SizedBox(
              width: contentWidth,
              height: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : null,
              child: tabs,
            ),
          ),
        ),
      ],
    );
  }
}
