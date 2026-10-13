import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty_view.dart';

class NotificationsEmptyView extends StatelessWidget {
  const NotificationsEmptyView({
    super.key,
    this.messageKey = 'no_notifications',
  });

  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        AppEmptyView(icon: Icons.notifications_none, messageKey: messageKey),
      ],
    );
  }
}
