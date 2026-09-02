import '../widgets/switch_pathway_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/custom_button.dart';
import '../cubit/educational_pathways_cubit.dart';
import '../widgets/educational_pathways_content.dart';

class EducationalPathwaysBody extends StatelessWidget {
  const EducationalPathwaysBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EducationalPathwaysCubit, EducationalPathwaysState>(
      builder: (BuildContext context, EducationalPathwaysState state) {
        final EducationalPathwaysCubit cubit = context
            .read<EducationalPathwaysCubit>();

        if (state.isFirstLoad) {
          return const Center(child: CircularProgressIndicator());
        }

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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: CustomButton(
                onPressed: () => SwitchPathwaySheet.show(context, cubit),
                text: 'switch_educational_path'.tr(),
                width: double.infinity,
                height: 40,
                threeRadius: 8.r,
                lastRadius: 8.r,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                elevation: 0,
              ),
            ),
          ],
        );
      },
    );
  }
}
