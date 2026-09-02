import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../cubit/profile_cubit.dart';
import '../refactor/profile_body.dart';
import '../../../../core/widgets/app_toast.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.showBack = true});
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => getIt<ProfileCubit>(),
      child: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (ProfileState previous, ProfileState current) =>
            current.messageKey != null,
        listener: _showMessage,
        child: AppSectionScaffold(
          title: context.tr('profile_title'),
          showBack: showBack,
          showMenu: !showBack,
          child: const ProfileBody(),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, ProfileState state) {
    final String? key = state.messageKey;
    if (key == null) return;

    AppToast.show(context, key.tr());
  }
}
