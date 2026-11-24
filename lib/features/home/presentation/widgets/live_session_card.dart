import '../../../../core/widgets/app_icon.dart';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/models/live_session_model.dart';
import '../refactor/home_formats.dart';
import '../../../../core/themes/app_theme.dart';
import 'live_session_card_status_badge.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LiveSessionCard extends StatelessWidget {
  const LiveSessionCard({required this.session, super.key, this.onTap});

  final LiveSessionModel session;
  final VoidCallback? onTap;
  String get _headline => session.title.trim().isEmpty
      ? HomeFormats.liveHeadline(session)
      : session.title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular((12).r(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all((10).r(context)),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all((11).r(context)),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular((10).r(context)),
                ),
                child: AppIcon(
                  asset: AppAssets.assetsVideoIcon,
                  width: (26).w(context),
                  height: (26).h(context),
                  color: colors.onPrimaryContainer,
                ),
              ),

              SizedBox(width: (10).w(context)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _headline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.styles(context).labelStrong,
                    ),

                    SizedBox(height: (2).h(context)),

                    Text(
                      HomeFormats.liveHeadline(session),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.styles(context).cardSubtitle,
                    ),
                  ],
                ),
              ),

              SizedBox(width: (10).w(context)),

              LiveSessionCardStatusBadge(label: HomeFormats.liveBadge(session)),
            ],
          ),
        ),
      ),
    );
  }
}
