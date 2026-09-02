import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/app_theme.dart';

/// The educational path — the stage, any classes between, then the current
/// semester — rendered outermost first and separated by a chevron that follows
/// the reading direction, so the path always flows towards the current class.
///
/// A single segment renders as plain text, which is the fallback when only the
/// class name is known.
///
/// Callers may override the styles so the path sits naturally in whichever
/// surface hosts it; the defaults suit the dashboard header card.
class EducationalPathText extends StatelessWidget {
  const EducationalPathText({
    required this.segments,
    this.ancestorStyle,
    this.currentStyle,
    this.alignment = WrapAlignment.center,
    super.key,
  });

  final List<String> segments;

  /// Styling for every segment above the current one.
  final TextStyle? ancestorStyle;

  /// Styling for the last segment — the class the student is actually in.
  final TextStyle? currentStyle;

  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AppTextStyles styles = AppTheme.styles(context);

    // Ancestors stay quiet; the class the student is actually in is the one
    // the eye should land on.
    final TextStyle ancestor =
        ancestorStyle ??
        styles.bodyMedium.copyWith(color: colors.onSurfaceVariant);
    final TextStyle current =
        currentStyle ?? styles.labelStrong.copyWith(color: colors.secondary);

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final int last = segments.length - 1;

    return Wrap(
      alignment: alignment,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6.w,
      runSpacing: 2.h,
      children: <Widget>[
        for (int i = 0; i < segments.length; i++) ...<Widget>[
          if (i > 0) Text(isRtl ? '‹' : '›', style: ancestor),

          Text(
            segments[i],
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: i == last ? current : ancestor,
          ),
        ],
      ],
    );
  }
}
