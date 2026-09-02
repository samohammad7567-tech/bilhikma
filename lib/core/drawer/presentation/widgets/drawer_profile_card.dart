import 'package:bilhikma/core/utils/current_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../themes/app_theme.dart';
import '../../../widgets/ornamented_card.dart';
import 'drawer_profile_monogram.dart';

class DrawerProfileCard extends StatelessWidget {
  const DrawerProfileCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.secondaryContainer;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        // Both sides carried the same mask, which read as one lopsided smudge
        // rather than the pair every other card shows. Falling through to
        // OrnamentedCard's defaults is what puts this card in the same design
        // system as the dashboard header and the subject cards.
        child: OrnamentedCard(
          radius: 14.r,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: <Widget>[
              DrawerProfileMonogram(avatarUrl: ''),

              SizedBox(width: 12.w),

              Expanded(
                child: Text(
                  CurrentUser.cachedUser()!.fullName,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.styles(context).cardTitle.copyWith(
                    color: accent,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dashed,
                    decorationColor: accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
