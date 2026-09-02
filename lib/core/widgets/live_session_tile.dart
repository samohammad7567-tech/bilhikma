import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../enums/content_type_enum.dart';
import '../models/live_session_model.dart';
import 'lesson_thumbnail.dart';
import 'ornamented_card.dart';
import 'live_session_details.dart';

class LiveSessionTile extends StatelessWidget {
  const LiveSessionTile({
    required this.session,
    required this.onWatch,
    required this.onRemind,
    super.key,
  });

  final LiveSessionModel session;
  final VoidCallback onWatch;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    return OrnamentedCard(
      radius: 14.r,
      padding: EdgeInsets.all(10.w),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LessonThumbnail(
              mediaType: ContentType.video,
              imageUrl: session.coverUrl,
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: LiveSessionDetails(
                session: session,
                onWatch: onWatch,
                onRemind: onRemind,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
