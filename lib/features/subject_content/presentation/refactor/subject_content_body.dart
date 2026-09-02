import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/custom_bar_icon.dart';
import '../../../../core/models/lesson_model.dart';
import '../../../../core/models/textbook_model.dart';
import '../../../gallery/data/models/media_album_model.dart';
import '../../../../core/models/live_session_model.dart';
import '../cubit/subject_content_cubit.dart';
import '../widgets/subject_content_content.dart';

class SubjectContentBody extends StatelessWidget {
  const SubjectContentBody({
    required this.onLessonTap,
    required this.onWatchLive,
    required this.onRemindLive,
    required this.onDownloadBook,
    required this.onPreviewBook,
    required this.onAlbumTap,
    super.key,
    this.onBack,
    this.onMenuTap,
  });

  final ValueChanged<LessonModel> onLessonTap;
  final ValueChanged<LiveSessionModel> onWatchLive;
  final ValueChanged<LiveSessionModel> onRemindLive;
  final ValueChanged<TextbookModel> onDownloadBook;
  final ValueChanged<TextbookModel> onPreviewBook;
  final ValueChanged<MediaAlbumModel> onAlbumTap;
  final VoidCallback? onBack;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: AppTopBar(
              title: context.tr('subject_content'),
              onBack: onBack,
              trailing: onMenuTap == null
                  ? null
                  : CustomBarIcon(
                      onTap: onMenuTap,
                      padding: 13.w,
                      child: AppIcon(
                        asset: AppAssets.assetsMenuIcon,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
            ),
          ),

          Expanded(
            child: BlocBuilder<SubjectContentCubit, SubjectContentState>(
              builder: (BuildContext context, SubjectContentState state) =>
                  SubjectContentContent(
                    state: state,
                    onLessonTap: onLessonTap,
                    onWatchLive: onWatchLive,
                    onRemindLive: onRemindLive,
                    onDownloadBook: onDownloadBook,
                    onPreviewBook: onPreviewBook,
                    onAlbumTap: onAlbumTap,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
