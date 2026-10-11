import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/book_preview_cubit.dart';
import 'book_page_scrubber.dart';
import 'book_reader_actions.dart';

/// Everything needed to get around a long document, kept off the page itself.
class BookReaderBar extends StatelessWidget {
  const BookReaderBar({
    required this.state,
    required this.onScrub,
    required this.onScrubEnd,
    required this.onPrevious,
    required this.onNext,
    required this.onJump,
    required this.onSearch,
    required this.onOutline,
    required this.onToggleLayout,
    super.key,
  });

  final BookPreviewState state;
  final ValueChanged<double> onScrub;
  final VoidCallback onScrubEnd;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onJump;
  final VoidCallback onSearch;
  final VoidCallback onOutline;
  final VoidCallback onToggleLayout;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BookReaderActions(
                state: state,
                onJump: onJump,
                onSearch: onSearch,
                onOutline: onOutline,
                onToggleLayout: onToggleLayout,
              ),

              BookPageScrubber(
                state: state,
                onScrub: onScrub,
                onScrubEnd: onScrubEnd,
                onPrevious: onPrevious,
                onNext: onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
