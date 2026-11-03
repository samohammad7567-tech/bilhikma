import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/lesson_view_data.dart';
import '../enums/content_type_enum.dart';
import '../themes/app_theme.dart';

class LessonMediaTag extends StatelessWidget {
  const LessonMediaTag({required this.mediaType, super.key});

  final ContentType mediaType;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 30.h, 28.w, 8.h),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(64.r),
        ),
      ),
      child: Text(
        mediaType.label.tr(),
        maxLines: 1,
        style: AppTheme.styles(
          context,
        ).labelSmall.copyWith(color: colors.onSecondary),
      ),
    );
  }
}
