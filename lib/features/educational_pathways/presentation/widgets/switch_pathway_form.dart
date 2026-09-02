import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/sheet_handle.dart';
import '../cubit/educational_pathways_cubit.dart';
import 'pathway_dropdown_field.dart';
import '../../../../core/themes/app_theme.dart';

class SwitchPathwayForm extends StatelessWidget {
  const SwitchPathwayForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EducationalPathwaysCubit, EducationalPathwaysState>(
      builder: (BuildContext context, EducationalPathwaysState state) {
        final EducationalPathwaysCubit cubit = context
            .read<EducationalPathwaysCubit>();

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Align(child: SheetHandle()),

              SizedBox(height: 22.h),

              Text(
                'switch_educational_path'.tr(),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).sectionTitle.copyWith(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
              ),

              SizedBox(height: 20.h),

              PathwayDropdownField(
                label: 'institution'.tr(),
                options: state.institutionOptions,
                value: state.draft.pathwayId,
                onChanged: cubit.selectInstitution,
                isLoading: state.isLoadingInstitutes,
              ),

              SizedBox(height: 16.h),

              PathwayDropdownField(
                label: 'level'.tr(),
                options: state.levelOptions,
                value: state.draft.levelId,
                onChanged: cubit.selectLevel,
                isLoading: state.isLoadingClasses,
              ),

              SizedBox(height: 16.h),

              PathwayDropdownField(
                label: 'term'.tr(),
                options: state.termOptions,
                value: state.draft.termId,
                onChanged: cubit.selectTerm,
                isLoading: state.isLoadingClasses,
              ),

              SizedBox(height: 26.h),

              CustomButton(
                onPressed: state.canSubmitSwitch ? cubit.switchPathway : () {},
                text: 'switch_educational_path'.tr(),
                width: double.infinity,
                height: 48.h,
                threeRadius: 8.r,
                lastRadius: 8.r,
                isLoading: state.isSwitching,
                backgroundColor: state.canSubmitSwitch
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHigh,
                elevation: 0,
              ),
            ],
          ),
        );
      },
    );
  }
}
