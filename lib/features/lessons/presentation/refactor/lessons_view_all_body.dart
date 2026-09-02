import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
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
