import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/book_preview_args.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../security/presentation/widgets/security_watch.dart';
import '../cubit/book_preview_cubit.dart';
import '../refactor/book_preview_body.dart';

class BookPreviewScreen extends StatelessWidget {
  const BookPreviewScreen({required this.args, super.key});

  final BookPreviewArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookPreviewCubit>(
      create: (_) => getIt<BookPreviewCubit>(param1: args),
      child: BlocListener<BookPreviewCubit, BookPreviewState>(
        listenWhen: (BookPreviewState previous, BookPreviewState current) =>
            current.isResumed && !previous.isResumed,
        listener: _announceResume,
        child: SecurityWatch(
          screen: AppRoutes.bookPreview,
          contentId: args.contentId,
          child: AppSectionScaffold(
            title: args.title,
            child: BookPreviewBody(args: args),
          ),
        ),
      ),
    );
  }

  void _announceResume(BuildContext context, BookPreviewState state) =>
      AppToast.show(
        context,
        'reader_resumed'.tr(
          namedArgs: <String, String>{'page': '${state.page}'},
        ),
      );
}
