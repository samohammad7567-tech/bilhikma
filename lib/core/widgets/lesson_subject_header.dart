import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/subject_content_model.dart';
import '../themes/app_theme.dart';
import 'app_progress_bar.dart';
import 'brand_badge.dart';
import 'index_strip.dart';
import 'ornamented_card.dart';

class LessonSubjectHeader extends StatelessWidget {
  const LessonSubjectHeader({required this.subject, super.key, this.order});

  final SubjectContentModel subject;

  /// Overrides the subject's own [SubjectContentModel.position] when a caller
  /// already knows the number. Left null, the subject answers for itself.
  final int? order;

  @override
  Widget build(BuildContext context) {
    // A hardcoded 1 used to sit here, which is why every subject's details page
    // disagreed with the list it was opened from. An unknown position now shows
    // no strip at all — a missing number beats a wrong one.
    final int position = order ?? subject.position;

    return Material(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (position > 0) IndexStrip(order: position),

            Expanded(
              child: Stack(
                children: <Widget>[
                  const Positioned.fill(child: OrnamentBackdrop()),

                  Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Row(
                      children: <Widget>[
                        BrandBadge(size: 64.w),

                        SizedBox(width: 14.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                subject.name,
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.styles(context).panelTitle,
                              ),

                              SizedBox(height: 14.h),

                              AppProgressBar(progress: subject.progress),
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
    );
  }
}
