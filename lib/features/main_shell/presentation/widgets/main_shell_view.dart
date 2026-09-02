import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app/cubit/app_preferences_cubit.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
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
            print(
              'MainShellView: onPopInvokedWithResult: didPop=$didPop, result=$result',
            );
            if (didPop) return;
            onBack(context, cubit.handleBackPress());
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            extendBody: true,
            drawer: const AppDrawer(),
            body: MainShellTabs(
              selectedTab: cubit.selectedTab,
              visitedTabs: cubit.visitedTabs,
              tabsEpoch: cubit.tabsEpoch,
            ),
            bottomNavigationBar: AppBottomNavBar(
              selectedTab: cubit.selectedTab,
              onTabSelected: cubit.selectTab,
            ),
          ),
        );
      },
    );
  }
}
