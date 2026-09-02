import 'package:flutter/material.dart';
import '../../../../core/widgets/app_empty_view.dart';

class NotificationsEmptyView extends StatelessWidget {
  const NotificationsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const <Widget>[
        AppEmptyView(
          icon: Icons.notifications_none,
          messageKey: 'no_notifications',
        ),
      ],
    );
  }
}
