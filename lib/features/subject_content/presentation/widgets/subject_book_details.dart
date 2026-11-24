import 'package:flutter/material.dart';

import '../../../../core/widgets/lesson_meta_item.dart';
import '../../../../core/models/textbook_model.dart';
import '../refactor/subject_content_formats.dart';
import '../../../../core/themes/app_theme.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SubjectBookDetails extends StatelessWidget {
  const SubjectBookDetails({required this.book, super.key});

  final TextbookModel book;

  @override
  Widget build(BuildContext context) {
    final String? version = book.version;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          book.title,
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.styles(context).cardTitle,
        ),

        SizedBox(height: (4).h(context)),

        if (version != null) ...<Widget>[
          Text(
            version,
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.styles(context).labelStrong.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),

          SizedBox(height: (10).h(context)),
        ],

        if (book.pageCount > 0) ...<Widget>[
          LessonMetaItem(
            icon: Icons.menu_book_outlined,
            label: SubjectContentFormats.pages(book.pageCount),
            isIconTrailing: true,
          ),

          SizedBox(height: (6).h(context)),
        ],

        LessonMetaItem(
          icon: Icons.download_outlined,
          label: book.readableSize,
          isIconTrailing: true,
        ),
      ],
    );
  }
}
