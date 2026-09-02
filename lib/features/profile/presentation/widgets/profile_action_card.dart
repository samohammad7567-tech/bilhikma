import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/enums/profile_action_enum.dart';
import 'profile_action_row.dart';

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
      borderRadius: BorderRadius.circular(12.r),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int index = 0; index < actions.length; index++) ...<Widget>[
            if (index > 0)
              Divider(
                height: 1.h,
                thickness: 1.h,
                indent: 12.w,
                endIndent: 12.w,
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
