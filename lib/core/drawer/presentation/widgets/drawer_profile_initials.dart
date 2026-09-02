import 'package:bilhikma/core/utils/current_user.dart';
import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';

class DrawerProfileInitials extends StatelessWidget {
  const DrawerProfileInitials({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      CurrentUser.cachedUser()!.initials,
      maxLines: 1,
      style: AppTheme.styles(
        context,
      ).cardTitle.copyWith(color: Theme.of(context).colorScheme.tertiary),
    );
  }
}
