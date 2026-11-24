import 'package:flutter/material.dart';

import '../../../../core/enums/content_type_enum.dart';
import 'lesson_media_tab.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

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
      padding: EdgeInsets.all((8).r(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular((12).r(context)),
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
