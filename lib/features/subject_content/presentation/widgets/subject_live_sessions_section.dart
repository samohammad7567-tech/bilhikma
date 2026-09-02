import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/models/live_session_model.dart';
import '../../../../core/widgets/live_session_tile.dart';

class SubjectLiveSessionsSection extends StatelessWidget {
  const SubjectLiveSessionsSection({
    required this.sessions,
    required this.onWatch,
    required this.onRemind,
    super.key,
  });

  final List<LiveSessionModel> sessions;
  final ValueChanged<LiveSessionModel> onWatch;
  final ValueChanged<LiveSessionModel> onRemind;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const AppEmptyView(
        icon: Icons.podcasts_outlined,
        messageKey: 'no_live_sessions',
      );
    }

    return Column(
      children: <Widget>[
        for (final LiveSessionModel session in sessions)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: LiveSessionTile(
              session: session,
              onWatch: () => onWatch(session),
              onRemind: () => onRemind(session),
            ),
          ),
      ],
    );
  }
}
