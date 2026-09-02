import '../../../../core/enums/archive_filter_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/models/lesson_model.dart';
import '../cubit/archive_cubit.dart';
import '../widgets/archive_filter_bar.dart';
import '../widgets/archive_content.dart';

class ArchiveBody extends StatelessWidget {
  const ArchiveBody({super.key, this.onLessonTap, this.onFilterSelected});

  final ValueChanged<LessonModel>? onLessonTap;
  final ValueChanged<ArchiveFilter>? onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArchiveCubit, ArchiveState>(
      builder: (BuildContext context, ArchiveState state) {
        return Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ArchiveFilterBar(
                selected: state.selectedFilter,
                onSelected: (filter) {
                  context.read<ArchiveCubit>().selectFilter(filter);
                  onFilterSelected?.call(filter);
                },
              ),
            ),

            SizedBox(height: 16.h),

            Expanded(
              child: ArchiveContent(state: state, onLessonTap: onLessonTap),
            ),
          ],
        );
      },
    );
  }
}
