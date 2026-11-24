import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/enums/settings_group_enum.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({required this.group, required this.rows, super.key});

  final SettingsGroup group;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          group.label.tr(),
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).groupTitle,
        ),

        SizedBox(height: (10).h(context)),

        Material(
          color: colors.tertiaryContainer.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular((14).r(context)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int index = 0; index < rows.length; index++) ...<Widget>[
                if (index > 0)
                  Divider(
                    height: (1).h(context),
                    thickness: 1,
                    indent: 12,
                    endIndent: 12,
                    color: colors.outline.withValues(alpha: 0.15),
                  ),
                rows[index],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
