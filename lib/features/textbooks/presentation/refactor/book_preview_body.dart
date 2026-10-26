import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/book_preview_args.dart';
import '../../../../core/utils/custom_bottom_sheet.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../cubit/book_preview_cubit.dart';
import '../widgets/book_page_jump_sheet.dart';
import '../widgets/book_page_skeleton.dart';
import '../widgets/book_pdf_view.dart';
import '../widgets/book_reader_bar.dart';
import '../widgets/book_search_field.dart';

class BookPreviewBody extends StatelessWidget {
  const BookPreviewBody({required this.args, super.key});

  final BookPreviewArgs args;

  @override
  Widget build(BuildContext context) {
    final BookPreviewCubit cubit = context.read<BookPreviewCubit>();

    return BlocBuilder<BookPreviewCubit, BookPreviewState>(
      builder: (BuildContext context, BookPreviewState state) {
        if (state.hasFailed) {
          return AppErrorView(
            errorKey: state.errorKey ?? 'reader_load_failed',
            onRetry: cubit.retryLoad,
          );
        }

        return Column(
          children: <Widget>[
            if (state.isSearchOpen)
              BookSearchField(
                state: state,
                onSubmit: cubit.search,
                onClose: cubit.closeSearch,
                onNext: cubit.nextMatch,
                onPrevious: cubit.previousMatch,
              ),

            Expanded(
              // The skeleton covers the viewer rather than replacing it: the
              // viewer is what loads the document, so it has to stay mounted.
              child: Stack(
                children: <Widget>[
                  BookPdfView(
                    cubit: cubit,
                    args: args,
                    layout: state.layout,
                    initialPage: state.page,
                  ),

                  if (!state.isLoaded)
                    const Positioned.fill(child: BookPageSkeleton()),
                ],
              ),
            ),

            BookReaderBar(
              state: state,
              onScrub: cubit.scrubTo,
              onScrubEnd: cubit.commitScrub,
              onPrevious: cubit.previousPage,
              onNext: cubit.nextPage,
              onJump: () => _openJumpSheet(context, cubit, state),
              onSearch: cubit.openSearch,
              onOutline: cubit.openOutline,
              onToggleLayout: cubit.toggleLayout,
            ),
          ],
        );
      },
    );
  }

  void _openJumpSheet(
    BuildContext context,
    BookPreviewCubit cubit,
    BookPreviewState state,
  ) => CustomBottomSheet.showModalBottomSheetContainer(
    context: context,
    widget: BookPageJumpSheet(
      pageCount: state.pageCount,
      currentPage: state.page,
      onSubmit: cubit.goToPage,
    ),
  );
}
