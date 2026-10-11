import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import '../cubit/notifications_cubit.dart';

class NotificationFilterTabs extends StatelessWidget {
  const NotificationFilterTabs({
    required this.filter,
    required this.totalCount,
    required this.unreadCount,
    required this.onSelected,
    super.key,
  });

  final NotificationsFilter filter;
  final int totalCount;
  final int unreadCount;
  final ValueChanged<NotificationsFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _tab(
            context,
            value: NotificationsFilter.all,
            labelKey: 'notifications_filter_all',
            count: totalCount,
          ),
        ),

        SizedBox(width: 10.w),

        Expanded(
          child: _tab(
            context,
            value: NotificationsFilter.unread,
            labelKey: 'notifications_filter_unread',
            count: unreadCount,
          ),
        ),
      ],
    );
  }

  Widget _tab(
    BuildContext context, {
    required NotificationsFilter value,
    required String labelKey,
    required int count,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isSelected = filter == value;

    final String label = labelKey.tr(
      namedArgs: <String, String>{'count': '$count'},
    );

    return Material(
      color: isSelected ? colors.primary : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected ? colors.primary : colors.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onSelected(value),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 8.w),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).labelStrong.copyWith(
              color: isSelected ? colors.onPrimary : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
