import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/book_preview_cubit.dart';

class BookPageScrubber extends StatelessWidget {
  const BookPageScrubber({
    required this.state,
    required this.onScrub,
    required this.onScrubEnd,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final BookPreviewState state;
  final ValueChanged<double> onScrub;
  final VoidCallback onScrubEnd;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isEnabled = state.isLoaded && state.pageCount > 1;

    return Row(
      children: <Widget>[
        _step(
          icon: Icons.chevron_left,
          onPressed: state.canGoBack ? onPrevious : null,
          colors: colors,
        ),

        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.h,
              activeTrackColor: colors.secondary,
              inactiveTrackColor: colors.surfaceContainerLowest,
              thumbColor: colors.secondary,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: state.sliderValue,
              min: 1,
              max: state.sliderMax,
              onChanged: isEnabled ? onScrub : null,
              onChangeEnd: isEnabled ? (_) => onScrubEnd() : null,
            ),
          ),
        ),

        _step(
          icon: Icons.chevron_right,
          onPressed: state.canGoForward ? onNext : null,
          colors: colors,
        ),
      ],
    );
  }

  Widget _step({
    required IconData icon,
    required VoidCallback? onPressed,
    required ColorScheme colors,
  }) => IconButton(
    onPressed: onPressed,
    visualDensity: VisualDensity.compact,
    icon: Icon(icon, size: 26.w),
    color: colors.onSurface,
    disabledColor: colors.outlineVariant,
  );
}
