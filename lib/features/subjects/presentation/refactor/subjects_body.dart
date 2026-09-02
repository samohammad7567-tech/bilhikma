import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/models/subject_model.dart';
import '../cubit/subjects_cubit.dart';
import '../widgets/subjects_list.dart';

class SubjectsBody extends StatelessWidget {
  const SubjectsBody({super.key, this.onSubjectTap});

  final ValueChanged<SubjectModel>? onSubjectTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectsCubit, SubjectsState>(
      builder: (BuildContext context, SubjectsState state) {
        if (state.isFirstLoad) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasFailed) {
          return AppErrorView(
            errorKey: state.errorKey,
            onRetry: context.read<SubjectsCubit>().loadSubjects,
          );
        }

        return RefreshIndicator(
          onRefresh: context.read<SubjectsCubit>().refresh,
          child: SubjectsList(
            subjects: state.visibleSubjects,
            onSubjectTap: onSubjectTap,
          ),
        );
      },
    );
  }
}
