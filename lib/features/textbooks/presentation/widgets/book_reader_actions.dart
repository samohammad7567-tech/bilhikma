import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import '../cubit/book_preview_cubit.dart';

class BookReaderActions extends StatelessWidget {
  const BookReaderActions({
    required this.state,
    required this.onJump,
    required this.onSearch,
    required this.onOutline,
    required this.onToggleLayout,
    super.key,
  });

  final BookPreviewState state;
  final VoidCallback onJump;
  final VoidCallback onSearch;
  final VoidCallback onOutline;
  final VoidCallback onToggleLayout;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        _pageChip(context, colors),

        const Spacer(),

        if (state.hasOutline)
          _action(
            icon: Icons.list_alt_outlined,
            tooltipKey: 'reader_outline',
            onPressed: onOutline,
            colors: colors,
          ),

        _action(
          icon: Icons.search,
          tooltipKey: 'reader_search',
          onPressed: state.isLoaded ? onSearch : null,
          colors: colors,
        ),
        _action(
          icon: state.layout.isSingle
              ? Icons.view_day_outlined
              : Icons.auto_stories_outlined,
          tooltipKey: state.layout.toggled.isSingle
              ? 'reader_layout_single'
              : 'reader_layout_continuous',
          onPressed: onToggleLayout,
          colors: colors,
        ),
      ],
    );
  }

  Widget _pageChip(BuildContext context, ColorScheme colors) {
    final String label = state.hasPages
        ? 'reader_page_position'.tr(
            namedArgs: <String, String>{
              'page': '${state.shownPage}',
              'total': '${state.pageCount}',
            },
          )
        : '—';

    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(8.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: state.hasPages ? onJump : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Text(
            label,
            maxLines: 1,
            style: AppTheme.styles(context).progressLabel,
          ),
        ),
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String tooltipKey,
    required VoidCallback? onPressed,
    required ColorScheme colors,
  }) => IconButton(
    onPressed: onPressed,
    tooltip: tooltipKey.tr(),
    visualDensity: VisualDensity.compact,
    icon: Icon(icon, size: 22.w),
    color: colors.onSurface,
    disabledColor: colors.outlineVariant,
  );
}
