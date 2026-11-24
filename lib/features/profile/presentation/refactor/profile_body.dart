import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/profile_action_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import 'profile_action_handler.dart';
import '../../../../core/utils/my_screen_size.dart';
import '../../../../core/utils/screen_scale.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (BuildContext context, ProfileState state) {
        final ProfileCubit cubit = context.read<ProfileCubit>();

        if (state.isFirstLoad) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasFailedOutright) {
          return AppErrorView(
            errorKey: state.errorKey,
            onRetry: cubit.loadProfile,
          );
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            MyScreenSize.bottomChromeHeight(context) + 24,
          ),
          children: <Widget>[
            ProfileHeader(name: state.profile.name),

            SizedBox(height: (22).h(context)),

            ProfileInfoCard(profile: state.profile),

            SizedBox(height: (14).h(context)),

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
