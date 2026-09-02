import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/profile_action_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import 'profile_action_handler.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (BuildContext context, ProfileState state) {
        final ProfileCubit cubit = context.read<ProfileCubit>();

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasFailed) {
          return AppErrorView(
            errorKey: state.errorKey,
            onRetry: cubit.loadProfile,
          );
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(
            16.w,
            8.h,
            16.w,
            AppBottomNavBar.barHeight + 24.h,
          ),
          children: <Widget>[
            ProfileHeader(name: state.profile.name),

            SizedBox(height: 22.h),

            ProfileInfoCard(profile: state.profile),

            SizedBox(height: 14.h),

            ProfileActionCard(
              onAction: (action) =>
                  ProfileActionHandler.handle(context, cubit, action),
            ),
          ],
        );
      },
    );
  }
}
