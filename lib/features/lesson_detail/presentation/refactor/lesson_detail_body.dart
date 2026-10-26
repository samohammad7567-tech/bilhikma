import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/book_preview_args.dart';
import '../../../textbooks/data/data_source/downloaded_pdfs_data_source.dart';
import '../../../../core/widgets/app_error_view.dart';
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

        // Only gate on a missing detail: gating on `isLoading` too would tear
        // down the mounted video/audio stage on every reload.
        if (detail == null) {
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

            if (detail.isVideo && !state.progress.isCompleted) ...<Widget>[
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
                  downloads: state.attachmentDownloads,
                  onDownload: cubit.downloadAttachment,
                  onOpen: (LessonAttachmentModel file) =>
                      _openAttachment(context, cubit, file),
                  onRetry: cubit.retryAttachmentDownload,
                  onDismissDownload: cubit.dismissAttachmentDownload,
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

            if (!detail.isArticle) ...<Widget>[SizedBox(height: 20.h)],
          ],
        );
      },
    );
  }

  Future<void> _openAttachment(
    BuildContext context,
    LessonDetailCubit cubit,
    LessonAttachmentModel file,
  ) async {
    final NavigatorState navigator = Navigator.of(context);
    final String? path = await cubit.openAttachment(file);

    if (path == null) return;

    navigator.pushNamed(
      AppRoutes.bookPreview,
      arguments: BookPreviewArgs(
        filePath: path,
        title: file.fileName,
        contentId: cubit.id,
        resumeKey: DownloadedPdfsDataSource.attachmentKey(cubit.id, file.id),
      ),
    );
  }

  Future<void> _previewAttachment(
    BuildContext context,
    LessonDetailCubit cubit,
    LessonAttachmentModel file,
  ) async {
    final NavigatorState navigator = Navigator.of(context);
    final String? url = await cubit.prepareAttachmentPreview(file);

    if (url == null) return;

    navigator.pushNamed(
      AppRoutes.bookPreview,
      arguments: BookPreviewArgs.network(
        url: url,
        title: file.fileName,
        contentId: cubit.id,
        resumeKey: DownloadedPdfsDataSource.attachmentKey(cubit.id, file.id),
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
      speed: state.effectivePlaybackSpeed,
      onSpeedChanged: cubit.setPlaybackSpeed,
      isLessonCompleted: state.progress.isCompleted,
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
            speed: state.effectivePlaybackSpeed,
            onSpeedChanged: cubit.setPlaybackSpeed,
            isLessonCompleted: state.progress.isCompleted,
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
