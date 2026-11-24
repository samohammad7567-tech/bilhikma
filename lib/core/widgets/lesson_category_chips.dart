import 'package:flutter/material.dart';

import '../enums/lesson_category_enum.dart';
import 'lesson_category_chip.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class LessonCategoryChips extends StatelessWidget {
  const LessonCategoryChips({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final LessonCategory selected;
  final ValueChanged<LessonCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (44).h(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: (16).w(context)),
        itemCount: LessonCategory.values.length,
        separatorBuilder: (_, _) => SizedBox(width: (10).w(context)),
        itemBuilder: (BuildContext context, int index) {
          final LessonCategory category = LessonCategory.values[index];

          return LessonCategoryChip(
            category: category,
            isSelected: category == selected,
            onTap: () => onSelected(category),
          );
        },
      ),
    );
  }
}
