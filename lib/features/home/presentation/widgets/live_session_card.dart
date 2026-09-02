import '../../../../core/widgets/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/models/live_session_model.dart';
import '../refactor/home_formats.dart';
import '../../../../core/themes/app_theme.dart';
import 'live_session_card_status_badge.dart';

class LiveSessionCard extends StatelessWidget {
  const LiveSessionCard({required this.session, super.key, this.onTap});

  final LiveSessionModel session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(11.w),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: AppIcon(
                  asset: AppAssets.assetsVideoIcon,
                  width: 26.w,
                  height: 26.w,
                  color: colors.onPrimaryContainer,
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      HomeFormats.liveHeadline(session),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.styles(context).labelStrong,
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.styles(context).cardSubtitle,
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10.w),

              LiveSessionCardStatusBadge(label: HomeFormats.liveBadge(session)),
            ],
          ),
        ),
      ),
    );
  }
}
