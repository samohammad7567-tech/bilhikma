import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/custom_bottom_sheet.dart';
import '../../../../core/enums/sleep_timer_option_enum.dart';
import '../cubit/settings_cubit.dart';
import '../../../../core/widgets/sheet_handle.dart';
import '../../../../core/themes/app_theme.dart';
import 'sleep_timer_option_row.dart';

class SleepTimerSheet extends StatelessWidget {
  const SleepTimerSheet({super.key});
  static void show(BuildContext context, SettingsCubit cubit) =>
      CustomBottomSheet.showModalBottomSheetContainer(
        context: context,

        backgroundColor: Theme.of(context).colorScheme.surface,
        widget: BlocProvider<SettingsCubit>.value(
          value: cubit,
          child: const SleepTimerSheet(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SheetHandle(),

                SizedBox(height: 20.h),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'sleep_timer'.tr(),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.styles(
                      context,
                    ).sectionTitle.copyWith(color: colors.secondaryContainer),
                  ),
                ),

                SizedBox(height: 12.h),

                for (final SleepTimerOption option
                    in SleepTimerOption.selectable)
                  SleepTimerOptionRow(
                    option: option,
                    isSelected: option == state.sleepTimer,
                    onTap: () {
                      context.read<SettingsCubit>().selectSleepTimer(option);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
