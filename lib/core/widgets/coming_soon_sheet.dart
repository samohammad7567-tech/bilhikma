import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import 'custom_button.dart';
import 'sheet_handle.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class ComingSoonSheet extends StatelessWidget {
  const ComingSoonSheet({super.key, this.messageKey = 'coming_soon_message'});
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
        borderRadius: BorderRadius.vertical(top: Radius.circular((24).r(context))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB((24).w(context), (12).h(context), (24).w(context), (20).h(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SheetHandle(),

              SizedBox(height: (24).h(context)),

              Container(
                width: (84).w(context),
                height: (84).h(context),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.tertiary.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rocket_launch_outlined,
                  size: (40).r(context),
                  color: colors.primary,
                ),
              ),

              SizedBox(height: (20).h(context)),

              Text(
                'coming_soon'.tr(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: styles.sectionTitle,
              ),

              SizedBox(height: (10).h(context)),

              Text(
                messageKey.tr(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: styles.cardBlurb,
              ),

              SizedBox(height: (24).h(context)),

              CustomButton(
                onPressed: () => Navigator.of(context).pop(),
                text: 'close'.tr(),
                width: double.infinity,
                height: (46).h(context),
                threeRadius: 8,
                lastRadius: 8,
                backgroundColor: colors.secondary,
                textColor: colors.onSecondary,
                elevation: (0).r(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
