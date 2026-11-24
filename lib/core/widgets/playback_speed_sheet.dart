import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../enums/playback_speed_enum.dart';
import '../localization/lang_keys.dart';
import '../services/device_info_service.dart';
import '../themes/app_theme.dart';
import '../utils/my_screen_size.dart';
import 'sheet_handle.dart';
import '../utils/screen_scale.dart';

class PlaybackSpeedSheet extends StatelessWidget {
  const PlaybackSpeedSheet({
    required this.current,
    required this.isLessonCompleted,
    required this.onSelected,
    super.key,
  });

  final PlaybackSpeed current;
  final bool isLessonCompleted;

  final ValueChanged<PlaybackSpeed> onSelected;
  static const double _maxHeightFactor = 0.85;

  static Future<void> show({
    required BuildContext context,
    required PlaybackSpeed current,
    required bool isLessonCompleted,
    required ValueChanged<PlaybackSpeed> onSelected,
  }) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MyScreenSize.heightFraction(context, _maxHeightFactor),
    ),
    builder: (BuildContext sheetContext) => PlaybackSpeedSheet(
      current: current,
      isLessonCompleted: isLessonCompleted,
      onSelected: (PlaybackSpeed speed) {
        Navigator.of(sheetContext).pop();
        onSelected(speed);
      },
    ),
  );

  bool get _isLowEndDevice => DeviceInfoService.isLowEndDevice;
  String? get _noteKey {
    if (_isLowEndDevice) return 'playback_speed_device_note';
    if (!isLessonCompleted) return 'playback_speed_locked_note';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);
    final String? noteKey = _noteKey;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular((24).r(context))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB((16).w(context), (12).h(context), (16).w(context), (8).h(context)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SheetHandle(),

                  SizedBox(height: (16).h(context)),

                  Text(
                    LangKeys.playbackSpeed.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: styles.panelTitle,
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MyScreenSize.heightFraction(context, 0.85),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB((16).w(context), (0).h(context), (16).w(context), (16).h(context)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final PlaybackSpeed option in PlaybackSpeed.values)
                      _Option(
                        speed: option,
                        isSelected: option == current,
                        isLocked:
                            (option.needsCompletedLesson &&
                                !isLessonCompleted) ||
                            option.exceedsDevice(
                              isLowEndDevice: _isLowEndDevice,
                            ),
                        onTap: () => onSelected(option),
                      ),

                    if (noteKey != null) ...<Widget>[
                      SizedBox(height: (8).h(context)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: (8).w(context)),
                        child: Text(
                          noteKey.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: styles.cardCaption,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.speed,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  final PlaybackSpeed speed;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    final TextStyle style = isSelected
        ? styles.optionLabelSelected
        : styles.optionLabel;

    return ListTile(
      onTap: isLocked ? null : onTap,
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: (8).w(context)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular((10).r(context))),
      title: Text(
        speed.isNormal ? LangKeys.playbackSpeedNormal.tr() : speed.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isLocked
            ? style.copyWith(color: style.color?.withValues(alpha: 0.4))
            : style,
      ),
      trailing: switch ((isLocked, isSelected)) {
        (true, _) => Icon(
          Icons.lock_outline_rounded,
          size: (18).r(context),
          color: colors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        (false, true) => Icon(
          Icons.check_rounded,
          size: (20).r(context),
          color: colors.primary,
        ),
        (false, false) => null,
      },
    );
  }
}
