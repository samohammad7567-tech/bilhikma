import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../enums/playback_speed_enum.dart';
import '../themes/app_theme.dart';
import 'sheet_handle.dart';

/// Playback rate picker shared by the lesson audio and video players.
class PlaybackSpeedSheet extends StatelessWidget {
  const PlaybackSpeedSheet({
    required this.current,
    required this.onSelected,
    super.key,
  });

  final PlaybackSpeed current;

  final ValueChanged<PlaybackSpeed> onSelected;

  static Future<void> show({
    required BuildContext context,
    required PlaybackSpeed current,
    required ValueChanged<PlaybackSpeed> onSelected,
  }) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) => PlaybackSpeedSheet(
      current: current,
      onSelected: (PlaybackSpeed speed) {
        Navigator.of(sheetContext).pop();
        onSelected(speed);
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SheetHandle(),

                SizedBox(height: 16.h),

                Text(
                  'playback_speed'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.panelTitle,
                ),

                SizedBox(height: 8.h),

                for (final PlaybackSpeed option in PlaybackSpeed.values)
                  _Option(
                    speed: option,
                    isSelected: option == current,
                    onTap: () => onSelected(option),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.speed,
    required this.isSelected,
    required this.onTap,
  });

  final PlaybackSpeed speed;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      title: Text(
        speed.isNormal ? 'playback_speed_normal'.tr() : speed.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isSelected ? styles.optionLabelSelected : styles.optionLabel,
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, size: 20.w, color: colors.primary)
          : null,
    );
  }
}
