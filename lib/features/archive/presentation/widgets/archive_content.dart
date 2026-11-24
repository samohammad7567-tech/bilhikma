import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/widgets/lesson_card.dart';
import '../cubit/archive_cubit.dart';
import '../../../../core/utils/my_screen_size.dart';
import '../../../../core/utils/screen_scale.dart';

class ArchiveContent extends StatelessWidget {
  const ArchiveContent({required this.state, this.onLessonTap, super.key});

  final ArchiveState state;
  final ValueChanged<LessonModel>? onLessonTap;

  @override
  Widget build(BuildContext context) {
    if (state.isFirstLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasFailed) {
      return AppErrorView(
        errorKey: state.errorKey,
        onRetry: context.read<ArchiveCubit>().loadSavedItems,
      );
    }
    if (state.status == ArchiveStatus.empty) {
      return const AppEmptyView(
        icon: Icons.bookmark_border,
        messageKey: 'no_saved_items',
      );
    }

    return RefreshIndicator(
      onRefresh: context.read<ArchiveCubit>().refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MyScreenSize.bottomChromeHeight(context) + 12,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final lesson = state.visibleItems[index];

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: (8).h(context)),
                  child: LessonCard(
                    lesson: lesson,
                    onTap: () => onLessonTap?.call(lesson),
                  ),
                );
              }, childCount: state.visibleItems.length),
            ),
          ),
        ],
      ),
    );
  }
}
