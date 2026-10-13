import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../data/models/profile_model.dart';
import '../cubit/profile_cubit.dart';
import '../refactor/edit_profile_form.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({required this.profile, super.key});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>.value(
      value: getIt<ProfileCubit>(),
      child: AppSectionScaffold(
        title: context.tr('edit_information'),
        child: EditProfileForm(profile: profile),
      ),
    );
  }
}
