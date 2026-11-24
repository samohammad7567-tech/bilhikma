import 'package:flutter/material.dart';

import '../../../../core/models/live_session_model.dart';
import '../../../../core/widgets/live_session_tile.dart';
import '../../../../core/utils/my_screen_size.dart';
import '../../../../core/utils/screen_scale.dart';

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
        16,
        4,
        16,
        MyScreenSize.bottomChromeHeight(context) + 24,
      ),
      itemCount: sessions.length,
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: (12).h(context)),
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
