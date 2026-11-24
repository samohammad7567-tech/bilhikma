import 'package:flutter/material.dart';

import '../../../../core/enums/archive_filter_enum.dart';
import 'archive_filter_segment.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class ArchiveFilterBar extends StatelessWidget {
  const ArchiveFilterBar({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ArchiveFilter selected;
  final ValueChanged<ArchiveFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all((6).r(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular((14).r(context)),
      ),
      child: Row(
        children: <Widget>[
          for (final ArchiveFilter filter in ArchiveFilter.values)
            Expanded(
              child: ArchiveFilterSegment(
                filter: filter,
                isSelected: filter == selected,
                onTap: () => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }
}
