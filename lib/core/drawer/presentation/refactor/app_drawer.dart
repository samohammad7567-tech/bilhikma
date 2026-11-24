import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../../di/service_locator.dart';
import '../../../utils/my_screen_size.dart';
import '../widgets/drawer_content.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late final ProfileCubit _profile = getIt<ProfileCubit>();

  @override
  void initState() {
    super.initState();

    unawaited(_profile.refresh());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>.value(
      value: _profile,
      child: Drawer(
        width: MyScreenSize.widthFraction(context, 0.8, max: 320),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(),
        child: const DrawerContent(),
      ),
    );
  }
}
