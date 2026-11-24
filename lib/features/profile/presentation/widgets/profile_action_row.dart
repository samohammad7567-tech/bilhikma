import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_icon.dart';
import '../../../../core/enums/profile_action_enum.dart';
import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class ProfileActionRow extends StatelessWidget {
  const ProfileActionRow({
    required this.action,
    required this.onTap,
    super.key,
  });

  final ProfileAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: (12).w(context), vertical: (10).h(context)),
        child: Row(
          children: <Widget>[
            Container(
              width: (38).w(context),
              height: (38).h(context),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular((10).r(context)),
              ),
              child: AppIcon(
                asset: action.imagePath,
                size: (20).r(context),
                color: colors.onPrimaryContainer,
                padding: EdgeInsets.all((9).r(context)),
              ),
            ),

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

            Icon(
              Icons.arrow_forward_ios,
              size: (14).r(context),
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
