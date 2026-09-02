import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../../core/routing/subject_content_args.dart';
import '../../../../core/models/subject_model.dart';
import '../cubit/subjects_cubit.dart';
import '../refactor/subjects_body.dart';
import '../../../../core/widgets/app_toast.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key, this.showBack = true, this.onSubjectTap});

  final bool showBack;
  final ValueChanged<SubjectModel>? onSubjectTap;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubjectsCubit>(
      create: (_) => getIt<SubjectsCubit>(),
      child: BlocListener<SubjectsCubit, SubjectsState>(
        listenWhen: (SubjectsState previous, SubjectsState current) =>
            current.errorKey != null && current.subjects != null,
        listener: _showRefreshError,
        child: AppSectionScaffold(
          title: context.tr('study_subjects'),
          showBack: showBack,
          showMenu: !showBack,
          child: Builder(
            builder: (BuildContext context) => SubjectsBody(
              onSubjectTap: (SubjectModel subject) =>
                  _openSubject(context, subject),
            ),
          ),
        ),
      ),
    );
  }

  void _openSubject(BuildContext context, SubjectModel subject) {
    final ValueChanged<SubjectModel>? onSubjectTap = this.onSubjectTap;
    if (onSubjectTap != null) {
      onSubjectTap(subject);
      return;
    }

    Navigator.of(context).pushNamed(
      AppRoutes.subjectContent,
      arguments: SubjectContentArgs(
        categorySubjectId: subject.categorySubjectId,
      ),
    );
  }

  void _showRefreshError(BuildContext context, SubjectsState state) {
    final String? errorKey = state.errorKey;
    if (errorKey == null) return;

    AppToast.error(context, errorKey.tr());
  }
}
