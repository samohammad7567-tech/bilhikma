import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app/cubit/app_preferences_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../cubit/educational_pathways_cubit.dart';
import '../refactor/educational_pathways_body.dart';
import '../../../../core/widgets/app_toast.dart';

class EducationalPathwaysScreen extends StatelessWidget {
  const EducationalPathwaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EducationalPathwaysCubit>(
      create: (_) => getIt<EducationalPathwaysCubit>(),
      child: BlocListener<EducationalPathwaysCubit, EducationalPathwaysState>(
        listenWhen:
            (
              EducationalPathwaysState previous,
              EducationalPathwaysState current,
            ) =>
                current.messageKey != null ||
                (current.errorKey != null && current.pathways != null),
        listener: _showMessage,
        child: AppSectionScaffold(
          title: context.tr('my_learning_paths'),
          child: const EducationalPathwaysBody(),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, EducationalPathwaysState state) {
    final String? key = state.errorKey ?? state.messageKey;
    if (key == null) return;

    if (state.messageKey == 'pathway_switched') {
      context.read<AppPreferencesCubit>().resetTabs();
    }

    final String text = state.serverMessage ?? key.tr();
    if (state.messageKey == 'pathway_switched') {
      AppToast.success(context, text);
      return;
    }

    AppToast.show(context, text);
  }
}
