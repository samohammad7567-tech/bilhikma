import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DownloadsLogDeleteAllButton extends StatelessWidget {
  const DownloadsLogDeleteAllButton({
    required this.isEnabled,
    required this.isDeletingAll,
    required this.onPressed,
    super.key,
  });

  final bool isEnabled;

  final bool isDeletingAll;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    if (isDeletingAll) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            color: colors.error,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: isEnabled ? onPressed : null,
      tooltip: 'clear_all_downloads'.tr(),
      icon: Icon(
        Icons.delete_sweep_outlined,
        size: 24.w,
        color: isEnabled
            ? colors.error
            : colors.onSurfaceVariant.withValues(alpha: 0.4),
      ),
    );
  }
}
