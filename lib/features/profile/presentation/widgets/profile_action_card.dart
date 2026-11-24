import 'package:flutter/material.dart';

import '../../../../core/enums/profile_action_enum.dart';
import 'profile_action_row.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class ProfileActionCard extends StatelessWidget {
  const ProfileActionCard({required this.onAction, super.key});

  final ValueChanged<ProfileAction> onAction;

  @override
  Widget build(BuildContext context) {
    const List<ProfileAction> actions = ProfileAction.values;

    return Material(
      color: Theme.of(
        context,
      ).colorScheme.tertiaryContainer.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular((12).r(context)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int index = 0; index < actions.length; index++) ...<Widget>[
            if (index > 0)
              Divider(
                height: (1).h(context),
                thickness: 1,
                indent: 12,
                endIndent: 12,
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.15),
              ),
            ProfileActionRow(
              action: actions[index],
              onTap: () => onAction(actions[index]),
            ),
          ],
        ],
      ),
    );
  }
}
