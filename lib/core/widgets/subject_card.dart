import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_progress_bar.dart';
import 'brand_badge.dart';
import 'ornamented_card.dart';
import '../themes/app_theme.dart';
import 'index_strip.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.order,
    super.key,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final double progress;
  final int order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              IndexStrip(order: order),

              Expanded(
                child: Stack(
                  children: <Widget>[
                    const Positioned.fill(child: OrnamentBackdrop()),

                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: <Widget>[
                          BrandBadge(size: 58.w),

                          SizedBox(width: 12.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  title,
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.styles(context).cardTitle,
                                ),

                                SizedBox(height: 2.h),

                                Text(
                                  subtitle,
                                  textAlign: TextAlign.start,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.styles(context).cardSubtitle,
                                ),

                                SizedBox(height: 10.h),

                                AppProgressBar(progress: progress),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
