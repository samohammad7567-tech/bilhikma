import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../../../../../core/themes/app_theme.dart';

class OtpCodeField extends StatelessWidget {
  const OtpCodeField({
    required this.controller,
    required this.length,
    required this.onChanged,
    super.key,
    this.errorKey,
    this.isVerifying = false,
    this.isVerified = false,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String> onChanged;
  final String? errorKey;

  final bool isVerifying;

  final bool isVerified;

  static const double _gap = 7;

  @override
  Widget build(BuildContext context) {
    final String? errorKey = this.errorKey;
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextStyle digitStyle = AppTheme.styles(context).bodyStrong;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double gap = _gap.w;
            final double boxWidth =
                ((constraints.maxWidth - gap * (length - 1)) / length)
                    .floorToDouble();

            PinTheme boxTheme(Color border) => PinTheme(
              width: boxWidth,
              height: 52.h,
              textStyle: digitStyle,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: border, width: 1.4),
              ),
            );

            final PinTheme restingTheme = boxTheme(
              colors.tertiary.withValues(alpha: 0.35),
            );

            return Pinput(
              controller: controller,
              length: length,
              onChanged: onChanged,
              keyboardType: TextInputType.number,
              showCursor: false,

              forceErrorState: errorKey != null,
              showErrorWhenFocused: true,
              separatorBuilder: (_) => SizedBox(width: gap),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              preFilledWidget: Text(
                '-',
                style: digitStyle.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.4),
                ),
              ),
              defaultPinTheme: restingTheme,
              followingPinTheme: restingTheme,
              focusedPinTheme: boxTheme(colors.tertiary),
              submittedPinTheme: boxTheme(
                isVerified ? colors.primaryContainer : colors.tertiary,
              ),
              errorPinTheme: boxTheme(colors.error),
            );
          },
        ),

        if (isVerifying) ...<Widget>[
          SizedBox(height: 8.h),
          Center(
            child: SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(strokeWidth: 2.w),
            ),
          ),
        ] else if (errorKey != null) ...<Widget>[
          SizedBox(height: 6.h),
          Text(
            errorKey.tr(namedArgs: <String, String>{'count': '$length'}),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).fieldError,
          ),
        ],
      ],
    );
  }
}
