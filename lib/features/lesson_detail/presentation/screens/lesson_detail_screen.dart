import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../../core/enums/content_type_enum.dart';
import '../cubit/lesson_detail_cubit.dart';
import '../../../../core/routing/lesson_detail_args.dart';
import '../refactor/lesson_detail_body.dart';
import '../../../security/presentation/widgets/security_watch.dart';
import '../../../../core/routing/app_routes.dart';
import '../widgets/lesson_save_button.dart';
import '../../../../core/widgets/app_toast.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({required this.args, super.key, this.onGoToTest});

  final LessonDetailArgs args;

  final VoidCallback? onGoToTest;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final GlobalKey _videoStageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final bool isArticle = widget.args.type == ContentType.article;

    return SecurityWatch(
      screen: AppRoutes.lessonDetail,
      contentId: widget.args.id,
      child: BlocProvider<LessonDetailCubit>(
        create: (_) =>
            LessonDetailCubit(id: widget.args.id, type: widget.args.type),
        child: BlocListener<LessonDetailCubit, LessonDetailState>(
          listenWhen: (LessonDetailState previous, LessonDetailState current) =>
              current.messageKey != null || current.message != null,
          listener: _showMessage,
          child: BlocBuilder<LessonDetailCubit, LessonDetailState>(
            buildWhen:
                (LessonDetailState previous, LessonDetailState current) =>
                    previous.isVideoFullscreen != current.isVideoFullscreen,
            builder: (BuildContext context, LessonDetailState state) {
              final Widget body = LessonDetailBody(
                onGoToTest: widget.onGoToTest,
                videoStageKey: _videoStageKey,
              );

              if (state.isVideoFullscreen) {
                return PopScope(
                  canPop: false,

                  onPopInvokedWithResult: (bool didPop, Object? result) {
                    if (didPop) return;
                    context.read<LessonDetailCubit>().setVideoFullscreen(false);
                  },
                  child: Scaffold(backgroundColor: Colors.black, body: body),
                );
              }

              return AppSectionScaffold(
                title: isArticle
                    ? 'article_content'.tr()
                    : 'lesson_content'.tr(),

                trailing: LessonSaveButton(contentId: widget.args.id),
                child: body,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, LessonDetailState state) {
    final String? text = state.message ?? state.messageKey?.tr();
    if (text == null) return;

    AppToast.show(context, text);
  }
}
