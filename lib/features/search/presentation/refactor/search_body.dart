import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/models/lesson_model.dart';
import '../cubit/search_cubit.dart';
import '../widgets/search_bar_row.dart';
import '../widgets/search_results.dart';

class SearchBody extends StatelessWidget {
  const SearchBody({super.key, this.onResultTap});

  final ValueChanged<LessonModel>? onResultTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (BuildContext context, SearchState state) {
        final SearchCubit cubit = context.read<SearchCubit>();

        return Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SearchBarRow(
                query: state.query,
                onChanged: cubit.queryChanged,
                onSubmitted: cubit.runSearch,
              ),
            ),

            SizedBox(height: 16.h),

            Expanded(
              child: SearchResults(state: state, onResultTap: onResultTap),
            ),
          ],
        );
      },
    );
  }
}
