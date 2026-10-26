import '../widgets/switch_pathway_sheet.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_state_switcher.dart';
import '../../../../core/widgets/custom_button.dart';
import '../cubit/educational_pathways_cubit.dart';
import '../widgets/educational_pathways_content.dart';
import '../widgets/educational_pathways_skeleton.dart';

class EducationalPathwaysBody extends StatelessWidget {
  const EducationalPathwaysBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EducationalPathwaysCubit, EducationalPathwaysState>(
      builder: (BuildContext context, EducationalPathwaysState state) =>
          AppStateSwitcher(child: _content(context, state)),
    );
  }

  Widget _content(BuildContext context, EducationalPathwaysState state) {
    final EducationalPathwaysCubit cubit = context
        .read<EducationalPathwaysCubit>();

    if (state.isFirstLoad) return const EducationalPathwaysSkeleton();

    if (state.hasFailed) {
      return AppErrorView(
        errorKey: state.errorKey,
        onRetry: cubit.loadPathways,
      );
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: EducationalPathwaysContent(state: state, cubit: cubit),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: CustomButton(
            onPressed: () => SwitchPathwaySheet.show(context, cubit),
            text: 'switch_educational_path'.tr(),
            width: double.infinity,
            // Was a fixed 40: the longest Arabic label clipped at large text
            // scales. `.h` lets the button grow with the rest of the type.
            height: 40.h,
            threeRadius: 8.r,
            lastRadius: 8.r,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            elevation: 0,
          ),
        ),
      ],
    );
  }
}
