import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../core/enums/settings_action_enum.dart';
import '../../../../core/themes/app_theme.dart';
import 'settings_glyph_tile.dart';
import 'settings_tile_trailing.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
        padding: EdgeInsets.symmetric(horizontal: (12).w(context), vertical: (10).h(context)),
        child: Row(
          children: <Widget>[
            SettingsGlyphTile(imagePath: action.imagePath),

            SizedBox(width: (12).w(context)),

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
                padding: EdgeInsetsDirectional.only(end: (8).h(context)),
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
