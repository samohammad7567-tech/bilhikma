import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CappedSeekBar extends StatefulWidget {
  const CappedSeekBar({
    required this.position,
    required this.duration,
    required this.maxPosition,
    required this.onSeek,
    super.key,
    this.onBlocked,
  });

  final Duration position;
  final Duration duration;

  final Duration maxPosition;

  final ValueChanged<Duration> onSeek;

  final VoidCallback? onBlocked;

  @override
  State<CappedSeekBar> createState() => _CappedSeekBarState();
}

class _CappedSeekBarState extends State<CappedSeekBar> {
  double? _dragSeconds;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final double total = widget.duration.inSeconds.toDouble();
    final double cap = total <= 0
        ? 0
        : widget.maxPosition.inSeconds.toDouble().clamp(0, total);
    final double value = total <= 0
        ? 0
        : (_dragSeconds ?? widget.position.inSeconds.toDouble()).clamp(
            0,
            total,
          );

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4.h,
        activeTrackColor: colors.secondaryContainer,
        inactiveTrackColor: colors.surfaceContainerLowest,
        secondaryActiveTrackColor: colors.secondaryContainer.withValues(
          alpha: 0.35,
        ),
        thumbColor: colors.secondaryContainer,
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
      ),
      child: Slider(
        value: value,
        max: total <= 0 ? 1 : total,
        secondaryTrackValue: cap,
        onChanged: total <= 0 ? null : _onChanged,
        onChangeEnd: total <= 0 ? null : (double raw) => _onChangeEnd(raw, cap),
      ),
    );
  }

  void _onChanged(double raw) {
    final double cap = widget.maxPosition.inSeconds.toDouble();
    setState(() => _dragSeconds = raw > cap ? cap : raw);
  }

  void _onChangeEnd(double raw, double cap) {
    setState(() => _dragSeconds = null);

    if (raw > cap) widget.onBlocked?.call();

    widget.onSeek(Duration(seconds: (raw > cap ? cap : raw).round()));
  }
}
