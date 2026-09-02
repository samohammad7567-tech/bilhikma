import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/app_theme.dart';

class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton({
    required this.onPressed,
    required this.text,
    required this.width,
    required this.height,
    super.key,
    this.lastRadius,
    this.threeRadius,
    this.borderColor,
    this.backgroundColor,
    this.textColor,
    this.borderWidth,
    this.textAlign,
    this.isLoading = false,
    this.loadingWidth,
    this.loadingHeight,
  });

  final VoidCallback onPressed;
  final String text;
  final double width;
  final double height;
  final double? threeRadius;
  final double? lastRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderWidth;
  final bool isLoading;
  final TextAlign? textAlign;
  final double? loadingWidth;
  final double? loadingHeight;

  @override
  Widget build(BuildContext context) {
    final Color stroke = borderColor ?? Theme.of(context).colorScheme.secondary;
    final Color foreground = textColor ?? stroke;
    final double radius = threeRadius ?? 20.r;

    return SizedBox(
      height: height,
      width: width,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: stroke, width: borderWidth ?? 1.w),
          disabledForegroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
              bottomRight: Radius.circular(radius),
              bottomLeft: Radius.circular(lastRadius ?? 0),
            ),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: loadingWidth ?? 22.w,
                height: loadingHeight ?? 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(foreground),
                ),
              )
            : Text(
                text,
                textAlign: textAlign,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.styles(
                  context,
                ).buttonLabel.copyWith(color: foreground),
              ),
      ),
    );
  }
}
