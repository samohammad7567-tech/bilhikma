import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/screen_scale.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/models/lesson_model.dart';
import '../cubit/lessons_cubit.dart';
import '../widgets/lessons_content.dart';

class LessonsViewAllBody extends StatelessWidget {
  const LessonsViewAllBody({super.key, this.onBack, this.onLessonTap});

  final VoidCallback? onBack;
  final ValueChanged<LessonModel>? onLessonTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocBuilder<LessonsCubit, LessonsState>(
        builder: (BuildContext context, LessonsState state) {
          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB((16).w(context), (8).h(context), (16).w(context), (12).h(context)),
                child: AppTopBar(title: state.title, onBack: onBack),
              ),

              Expanded(
                child: LessonsContent(state: state, onLessonTap: onLessonTap),
              ),
            ],
          );
        },
      ),
    );
  }
}
