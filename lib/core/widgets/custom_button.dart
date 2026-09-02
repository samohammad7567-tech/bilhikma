import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/app_theme.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.onPressed,
    required this.text,
    required this.width,
    required this.height,
    super.key,
    this.lastRadius,
    this.threeRadius,
    this.backgroundColor,
    this.textColor,
    this.textAlign,
    this.isLoading = false,
    this.loadingWidth,
    this.loadingHeight,
    this.elevation,
  });
  final VoidCallback onPressed;
  final String text;
  final double width;
  final double height;
  final double? threeRadius;
  final double? lastRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final TextAlign? textAlign;
  final double? loadingWidth;
  final double? loadingHeight;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final double radius = threeRadius ?? 20.r;

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          backgroundColor:
              backgroundColor ?? Theme.of(context).colorScheme.secondary,
          disabledBackgroundColor: backgroundColor ?? Colors.black,
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
                width: loadingWidth ?? 30.w,
                height: loadingHeight ?? 30.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                text,
                textAlign: textAlign,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textColor == null
                    ? AppTheme.styles(context).buttonLabel
                    : AppTheme.styles(
                        context,
                      ).buttonLabel.copyWith(color: textColor),
              ),
      ),
    );
  }
}
