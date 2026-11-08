import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/lang_keys.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../cubit/lesson_test_cubit.dart';

class TestTimeUpView extends StatelessWidget {
  const TestTimeUpView({required this.cubit, required this.state, super.key});

  final LessonTestCubit cubit;
  final LessonTestState state;

  @override
  Widget build(BuildContext context) {
    if (state.errorKey != null) {
      return AppErrorView(
        errorKey: state.errorKey,
        message: state.errorMessage,
        onRetry: () => cubit.submit(timedOut: true),
      );
    }

    if (state.isSubmitting) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.timer_off_outlined,
                size: 46.w,
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 16.h),
              Text(LangKeys.quizTimeUp.tr(), textAlign: TextAlign.center),
              SizedBox(height: 18.h),
              const LinearProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Center(
      child: AppEmptyView(
        icon: Icons.timer_off_outlined,
        messageKey: LangKeys.quizTimeUp,
      ),
    );
  }
}
