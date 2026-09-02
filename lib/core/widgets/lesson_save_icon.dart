import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/lessons/presentation/cubit/lesson_save_cubit.dart';
import '../di/service_locator.dart';
import 'app_toast.dart';

class LessonSaveIcon extends StatelessWidget {
  const LessonSaveIcon({
    required this.lessonId,
    super.key,
    this.iconSize,
    this.padding,
    this.backgroundColor,
  });

  final int lessonId;
  final double? iconSize;
  final double? padding;

  final Color? backgroundColor;

  Future<void> _toggle(BuildContext context, LessonSaveCubit cubit) async {
    final bool isSaved = await cubit.toggle(lessonId);
    if (!context.mounted) return;

    AppToast.success(
      context,
      (isSaved ? 'lesson_saved' : 'lesson_unsaved').tr(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final LessonSaveCubit cubit = getIt<LessonSaveCubit>();

    return BlocBuilder<LessonSaveCubit, LessonSaveState>(
      bloc: cubit,

      buildWhen: (LessonSaveState previous, LessonSaveState current) =>
          previous.isSaved(lessonId) != current.isSaved(lessonId),
      builder: (BuildContext context, LessonSaveState state) {
        final bool isSaved = state.isSaved(lessonId);

        return Tooltip(
          message: (isSaved ? 'lesson_unsave' : 'lesson_save').tr(),
          child: Material(
            color: backgroundColor ?? Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _toggle(context, cubit),
              child: Padding(
                padding: EdgeInsets.all(padding ?? 8.w),
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: iconSize ?? 20.w,
                  color: isSaved ? colors.secondary : colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
