import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../textbooks/presentation/screens/book_preview_screen.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/coming_soon_sheet.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/lesson_attachment_model.dart';
import '../../data/models/lesson_detail_model.dart';
import '../cubit/lesson_detail_cubit.dart';
import 'lesson_progress_view.dart';
import '../widgets/lesson_artwork.dart';
import '../widgets/lesson_attachments_card.dart';
import '../widgets/lesson_audio_stage.dart';
import '../widgets/lesson_summary_card.dart';
import '../widgets/lesson_text_section.dart';
import '../widgets/lesson_video_stage.dart';
import '../../../../core/themes/app_theme.dart';
import '../widgets/article_read_button.dart';
import '../widgets/lesson_detail_inset.dart';
import '../widgets/lesson_locked_view.dart';

class LessonDetailBody extends StatelessWidget {
  const LessonDetailBody({super.key, this.onGoToTest, this.videoStageKey});

  final VoidCallback? onGoToTest;

  final Key? videoStageKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonDetailCubit, LessonDetailState>(
      builder: (BuildContext context, LessonDetailState state) {
        final LessonDetailCubit cubit = context.read<LessonDetailCubit>();
        final LessonDetailModel? detail = state.detail;

        if (state.hasFailed && state.isLocked) {
          return LessonLockedView(
            message: state.errorMessage,
            onBack: () => Navigator.of(context).maybePop(),
          );
        }

        if (state.hasFailed) {
          return AppErrorView(
            errorKey: state.errorKey,
            message: state.errorMessage,
            onRetry: cubit.loadLesson,
          );
        }

        if (detail == null || state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (detail.isVideo && state.isVideoFullscreen) {
          return _videoStage(cubit, state);
        }

        final String? description = detail.description;

        return ListView(
          padding: EdgeInsets.only(bottom: 24.h),
          children: <Widget>[
            ..._stage(context, cubit, state, detail),

            SizedBox(height: 14.h),

            LessonDetailInset(
              child: LessonSummaryCard(
                detail: detail,
                progressView: LessonProgressView.of(state),
                source: state.playbackSource,
              ),
            ),

            if (detail.isVideo) ...<Widget>[
              SizedBox(height: 10.h),
              LessonDetailInset(
                child: Text(
                  'video_no_skip_note'.tr(),
                  textAlign: TextAlign.center,
                  style: AppTheme.styles(context).cardCaption,
                ),
              ),
            ],

            if (description != null) ...<Widget>[
              SizedBox(height: 18.h),
              LessonDetailInset(
                child: LessonTextSection(
                  headingKey: 'description_heading',
                  body: description,
                ),
              ),
            ],

            if (detail.articleBody != null) ...<Widget>[
              SizedBox(height: 18.h),
              LessonDetailInset(
                child: LessonTextSection(
                  headingKey: 'article_body_heading',
                  body: detail.articleBody!,
                ),
              ),
            ],

            if (detail.hasAttachments) ...<Widget>[
              SizedBox(height: 18.h),
              LessonDetailInset(
                child: LessonAttachmentsCard(
                  attachments: detail.attachments,

                  downloadingId: state.downloadingAttachmentId,
                  previewingId: state.previewingAttachmentId,
                  downloadedIds: state.downloadedAttachmentIds,
                  onDownload: cubit.downloadAttachment,
                  onPreview: (LessonAttachmentModel file) =>
                      _previewAttachment(context, cubit, file),
                ),
              ),
            ],

            if (detail.isArticle) ...<Widget>[
              SizedBox(height: 20.h),
              LessonDetailInset(
                child: ArticleReadButton(
                  isRead: state.isArticleRead,
                  onMarkRead: cubit.markArticleRead,
                ),
              ),
            ],

            if (!detail.isArticle) ...<Widget>[
              SizedBox(height: 20.h),
              LessonDetailInset(
                child: CustomButton(
                  onPressed:
                      onGoToTest ??
                      () => ComingSoonSheet.show(
                        context,
                        messageKey: 'coming_soon_test',
                      ),
                  text: 'go_to_test'.tr(),
                  width: double.infinity,
                  height: 46,
                  threeRadius: 8.r,
                  lastRadius: 8.r,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  textColor: Theme.of(context).colorScheme.onSecondary,
                  elevation: 0,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _previewAttachment(
    BuildContext context,
    LessonDetailCubit cubit,
    LessonAttachmentModel file,
  ) async {
    final NavigatorState navigator = Navigator.of(context);
    final String? path = await cubit.prepareAttachmentPreview(file);

    if (path == null) return;

    navigator.pushNamed(
      AppRoutes.bookPreview,
      arguments: BookPreviewArgs(
        filePath: path,
        title: file.fileName,
        contentId: cubit.id,
      ),
    );
  }

  Widget _videoStage(LessonDetailCubit cubit, LessonDetailState state) {
    return LessonVideoStage(
      key: videoStageKey,
      url: state.playbackUrl,
      isPreparing: state.isPreparingPlayback,
      onPrepare: cubit.preparePlayback,
      isFullscreen: state.isVideoFullscreen,
      onFullscreenChanged: cubit.setVideoFullscreen,
      onTick: (int position, int played) => cubit.onPlaybackTick(
        positionSeconds: position,
        playedSeconds: played,
      ),
      onEnded: cubit.onMediaEnded,
      resumeSeconds: state.resumeSeconds,
      seekLimitSeconds: state.seekLimitSeconds,
      correctionSeconds: state.correctionSeconds,
      correctionRevision: state.correctionRevision,
    );
  }

  List<Widget> _stage(
    BuildContext context,
    LessonDetailCubit cubit,
    LessonDetailState state,
    LessonDetailModel detail,
  ) {
    if (detail.isVideo) {
      return <Widget>[_videoStage(cubit, state)];
    }

    if (detail.isAudio) {
      return <Widget>[
        SizedBox(height: 8.h),
        const LessonDetailInset(child: LessonArtwork(aspectRatio: 1)),
        SizedBox(height: 14.h),
        LessonDetailInset(
          child: LessonAudioStage(
            url: state.playbackUrl,
            isPreparing: state.isPreparingPlayback,
            onPrepare: cubit.preparePlayback,
            onTick: (int position, int played) => cubit.onPlaybackTick(
              positionSeconds: position,
              playedSeconds: played,
            ),
            onEnded: cubit.onMediaEnded,
            resumeSeconds: state.resumeSeconds,
            seekLimitSeconds: state.seekLimitSeconds,
            correctionSeconds: state.correctionSeconds,
            correctionRevision: state.correctionRevision,
          ),
        ),
      ];
    }

    return <Widget>[
      SizedBox(height: 8.h),
      const LessonDetailInset(child: LessonArtwork(aspectRatio: 16 / 9)),
    ];
  }
}
