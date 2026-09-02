import 'package:flutter/material.dart';
import '../../../../core/widgets/app_empty_view.dart';

class LiveSessionsEmptyView extends StatelessWidget {
  const LiveSessionsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const <Widget>[
        AppEmptyView(
          icon: Icons.podcasts_outlined,
          messageKey: 'no_live_broadcasts',
        ),
      ],
    );
  }
}
