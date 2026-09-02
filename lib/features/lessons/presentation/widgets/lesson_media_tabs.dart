import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/enums/content_type_enum.dart';
import 'lesson_media_tab.dart';

class LessonMediaTabs extends StatelessWidget {
  const LessonMediaTabs({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ContentType selected;
  final ValueChanged<ContentType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: <Widget>[
          for (final ContentType type in ContentType.values)
            Expanded(
              child: LessonMediaTab(
                mediaType: type,
                isSelected: type == selected,
                onTap: () => onSelected(type),
              ),
            ),
        ],
      ),
    );
  }
}
