import 'package:flutter/material.dart';

import '../../../../core/widgets/app_progress_bar.dart';
import '../../data/models/resume_lesson_model.dart';
import '../refactor/home_formats.dart';
import '../../../../core/themes/app_theme.dart';
import 'resume_lesson_play_button.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class ResumeLessonCard extends StatelessWidget {
  const ResumeLessonCard({required this.lesson, super.key, this.onTap});

  final ResumeLessonModel lesson;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular((12).r(context)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all((12).r(context)),
          child: Row(
            children: <Widget>[
              const ResumeLessonPlayButton(),

              SizedBox(width: (12).w(context)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      lesson.title,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.styles(context).cardTitle,
                    ),

                    SizedBox(height: (2).h(context)),

                    Text(
                      HomeFormats.subjectDuration(
                        lesson.subjectName,
                        lesson.duration.inMinutes,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.styles(context).cardSubtitle,
                    ),

                    SizedBox(height: (10).h(context)),

                    AppProgressBar(progress: lesson.progress),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
