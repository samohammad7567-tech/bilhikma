import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/custom_bottom_sheet.dart';
import '../cubit/educational_pathways_cubit.dart';
import 'switch_pathway_form.dart';

class SwitchPathwaySheet extends StatelessWidget {
  const SwitchPathwaySheet({super.key});

  static void show(BuildContext context, EducationalPathwaysCubit cubit) {
    cubit.openSwitchForm();

    CustomBottomSheet.showModalBottomSheetContainer(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      widget: BlocProvider<EducationalPathwaysCubit>.value(
        value: cubit,
        child: const SwitchPathwaySheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EducationalPathwaysCubit, EducationalPathwaysState>(
      listenWhen:
          (
            EducationalPathwaysState previous,
            EducationalPathwaysState current,
          ) =>
              current.messageKey == 'pathway_switched' ||
              current.messageKey == 'enrollment_request_sent' ||
              (current.errorKey != null &&
                  current.errorKey != previous.errorKey),

      listener: (BuildContext context, _) => Navigator.of(context).pop(),
      child: const SafeArea(top: false, child: SwitchPathwayForm()),
    );
  }
}
