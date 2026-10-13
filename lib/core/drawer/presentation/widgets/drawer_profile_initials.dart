import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../../themes/app_theme.dart';

class DrawerProfileInitials extends StatelessWidget {
  const DrawerProfileInitials({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (ProfileState previous, ProfileState current) =>
          previous.profile.initials != current.profile.initials,
      builder: (BuildContext context, ProfileState state) => Text(
        state.profile.initials,
        maxLines: 1,
        style: AppTheme.styles(
          context,
        ).cardTitle.copyWith(color: Theme.of(context).colorScheme.tertiary),
      ),
    );
  }
}
