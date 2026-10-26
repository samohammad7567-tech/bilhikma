import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../../di/service_locator.dart';
import '../../../utils/screen_size.dart';
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
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // Was a raw 320 next to `.w` sizing inside the drawer, so the panel and its
    // contents scaled apart on small and large screens.
    final double cap = ScreenSize.isTablet(context) ? 400.w : 320.w;

    return BlocProvider<ProfileCubit>.value(
      value: _profile,
      child: Drawer(
        width: screenWidth * 0.8 > cap ? cap : screenWidth * 0.8,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(),
        child: const DrawerContent(),
      ),
    );
  }
}
