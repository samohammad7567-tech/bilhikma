import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../cubit/book_preview_cubit.dart';

class BookSearchField extends StatefulWidget {
  const BookSearchField({
    required this.state,
    required this.onSubmit,
    required this.onClose,
    required this.onNext,
    required this.onPrevious,
    super.key,
  });

  final BookPreviewState state;
  final ValueChanged<String> onSubmit;
  final VoidCallback onClose;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  State<BookSearchField> createState() => _BookSearchFieldState();
}

class _BookSearchFieldState extends State<BookSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 4.h, 4.w, 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: CustomTextField(
                    controller: _controller,
                    hintText: 'reader_search_hint'.tr(),
                    textInputAction: TextInputAction.search,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    borderRadius: 10.r,
                    onFieldSubmitted: widget.onSubmit,
                  ),
                ),

                IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(Icons.close, size: 22.w),
                  color: colors.onSurface,
                ),
              ],
            ),

            _status(context, colors),
          ],
        ),
      ),
    );
  }

  Widget _status(BuildContext context, ColorScheme colors) {
    final BookPreviewState state = widget.state;
    if (!state.hasQuery) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              _label(state),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.styles(context).cardCaption,
            ),
          ),

          if (state.hasMatches) ...<Widget>[
            _step(Icons.keyboard_arrow_up, widget.onPrevious, colors),
            _step(Icons.keyboard_arrow_down, widget.onNext, colors),
          ],
        ],
      ),
    );
  }

  String _label(BookPreviewState state) {
    if (state.hasNoMatches) return 'reader_no_matches'.tr();

    if (state.isSearching && !state.hasMatches) {
      return 'reader_searching'.tr();
    }

    final String position = 'reader_match_position'.tr(
      namedArgs: <String, String>{
        'index': '${state.matchIndex}',
        'total': '${state.matchCount}',
      },
    );

    return state.isSearching
        ? '$position · ${'reader_searching'.tr()}'
        : position;
  }

  Widget _step(IconData icon, VoidCallback onPressed, ColorScheme colors) =>
      IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, size: 22.w),
        color: colors.onSurface,
      );
}
