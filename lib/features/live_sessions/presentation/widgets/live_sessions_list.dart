import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/models/live_session_model.dart';
import '../../../../core/widgets/live_session_tile.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';

class LiveSessionsList extends StatelessWidget {
  const LiveSessionsList({
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
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16.w,
        4.h,
        16.w,
        AppBottomNavBar.barHeight + 24.h,
      ),
      itemCount: sessions.length,
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: 12.h),
      itemBuilder: (BuildContext context, int index) {
        final LiveSessionModel session = sessions[index];

        return LiveSessionTile(
          session: session,
          onWatch: () => onWatch(session),
          onRemind: () => onRemind(session),
        );
      },
    );
  }
}
