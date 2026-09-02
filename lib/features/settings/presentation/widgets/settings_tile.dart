import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/enums/settings_action_enum.dart';
import '../../../../core/themes/app_theme.dart';
import 'settings_glyph_tile.dart';
import 'settings_tile_trailing.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.action,
    required this.onTap,
    super.key,
    this.value,
    this.isBusy = false,
  });

  final SettingsAction action;
  final VoidCallback onTap;
  final String? value;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final String? value = this.value;

    return InkWell(
      onTap: isBusy ? null : onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: <Widget>[
            SettingsGlyphTile(imagePath: action.imagePath),

            SizedBox(width: 12.w),

            Expanded(
              child: Text(
                action.label.tr(),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(context).rowTitle,
              ),
            ),

            if (value != null)
              Padding(
                padding: EdgeInsetsDirectional.only(end: 8.w),
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(context).rowValue,
                ),
              ),

            SettingsTileTrailing(isBusy: isBusy),
          ],
        ),
      ),
    );
  }
}
