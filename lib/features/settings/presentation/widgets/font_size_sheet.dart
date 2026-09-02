import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/custom_bottom_sheet.dart';
import '../cubit/settings_cubit.dart';
import 'font_size_stepper.dart';
import '../../../../core/widgets/sheet_handle.dart';
import '../../../../core/themes/app_theme.dart';

class FontSizeSheet extends StatelessWidget {
  const FontSizeSheet({super.key});
  static void show(BuildContext context, SettingsCubit cubit) =>
      CustomBottomSheet.showModalBottomSheetContainer(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surface,
        widget: BlocProvider<SettingsCubit>.value(
          value: cubit,
          child: const FontSizeSheet(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
          final SettingsCubit cubit = context.read<SettingsCubit>();

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SheetHandle(),

                SizedBox(height: 20.h),

                Text(
                  'font_size'.tr(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(
                    context,
                  ).sectionTitle.copyWith(color: colors.secondaryContainer),
                ),

                SizedBox(height: 14.h),

                Text(
                  'font_size_sample'.tr(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(context).bodyStrong,
                ),

                SizedBox(height: 24.h),

                FontSizeStepper(
                  percent: state.fontScalePercent,
                  onDecrease: state.settings.canDecreaseFont
                      ? cubit.decreaseFontScale
                      : null,
                  onIncrease: state.settings.canIncreaseFont
                      ? cubit.increaseFontScale
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
