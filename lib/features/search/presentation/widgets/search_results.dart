import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/widgets/lesson_card.dart';
import '../cubit/search_cubit.dart';
import 'package:bilhikma/core/utils/screen_scale.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({required this.state, this.onResultTap, super.key});

  final SearchState state;
  final ValueChanged<LessonModel>? onResultTap;

  @override
  Widget build(BuildContext context) {
    if (state.isFirstLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasFailed) {
      return AppErrorView(
        errorKey: state.errorKey,
        onRetry: context.read<SearchCubit>().runSearch,
      );
    }

    final List<LessonModel> results = state.visibleResults;

    if (results.isEmpty) {
      return AppEmptyView(
        icon: Icons.search_off,
        messageKey: state.hasQuery ? 'no_search_results' : 'search_start_hint',
      );
    }

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: (24).h(context)),
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        final LessonModel result = results[index];

        return Padding(
          padding: EdgeInsets.fromLTRB((16).w(context), (0).h(context), (16).w(context), (12).h(context)),
          child: LessonCard(
            lesson: result,
            onTap: onResultTap == null ? null : () => onResultTap!(result),
          ),
        );
      },
    );
  }
}
