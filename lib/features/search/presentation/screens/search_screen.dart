import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../../core/models/lesson_model.dart';
import '../cubit/search_cubit.dart';
import '../refactor/search_body.dart';
import '../../../../core/widgets/app_toast.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key, this.onResultTap});

  final ValueChanged<LessonModel>? onResultTap;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchCubit>(
      create: (_) => getIt<SearchCubit>(),
      child: BlocListener<SearchCubit, SearchState>(
        listenWhen: (SearchState previous, SearchState current) =>
            current.errorKey != null && current.results != null,
        listener: _showSearchError,
        child: AppSectionScaffold(
          title: context.tr('search_title'),
          child: SearchBody(onResultTap: onResultTap),
        ),
      ),
    );
  }

  void _showSearchError(BuildContext context, SearchState state) {
    final String? errorKey = state.errorKey;
    if (errorKey == null) return;

    AppToast.error(context, errorKey.tr());
  }
}
