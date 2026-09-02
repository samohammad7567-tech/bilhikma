import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_theme.dart';
import 'custom_button.dart';
import 'sheet_handle.dart';

/// The answer to tapping something that does not exist yet.
///
/// A control that silently does nothing reads as a broken app, so every
/// unfinished feature routes here instead: it says the feature is coming rather
/// than leaving the tap unanswered. Call [show] from the tap handler.
class ComingSoonSheet extends StatelessWidget {
  const ComingSoonSheet({super.key, this.messageKey = 'coming_soon_message'});

  /// Lets a caller explain what in particular is coming, while every sheet
  /// keeps the same title and shape.
  final String messageKey;

  static Future<void> show(
    BuildContext context, {
    String messageKey = 'coming_soon_message',
  }) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) =>
        ComingSoonSheet(messageKey: messageKey),
  );

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SheetHandle(),

              SizedBox(height: 24.h),

              Container(
                width: 84.w,
                height: 84.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.tertiary.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rocket_launch_outlined,
                  size: 40.w,
                  color: colors.primary,
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                'coming_soon'.tr(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: styles.sectionTitle,
              ),

              SizedBox(height: 10.h),

              Text(
                messageKey.tr(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: styles.cardBlurb,
              ),

              SizedBox(height: 24.h),

              CustomButton(
                onPressed: () => Navigator.of(context).pop(),
                text: 'close'.tr(),
                width: double.infinity,
                height: 46,
                threeRadius: 8.r,
                lastRadius: 8.r,
                backgroundColor: colors.secondary,
                textColor: colors.onSecondary,
                elevation: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
