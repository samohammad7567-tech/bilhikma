import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/live_session_model.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_section_scaffold.dart';
import '../cubit/live_player_cubit.dart';
import '../widgets/live_player_stage.dart';
import '../widgets/live_player_summary_card.dart';
import '../../../security/presentation/widgets/security_watch.dart';
import '../../../../core/routing/app_routes.dart';

class LivePlayerScreen extends StatefulWidget {
  const LivePlayerScreen({required this.session, super.key});

  final LiveSessionModel session;

  @override
  State<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends State<LivePlayerScreen> {
  bool _isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    return SecurityWatch(
      screen: AppRoutes.livePlayer,
      contentId: widget.session.id,
      child: BlocProvider<LivePlayerCubit>(
        create: (_) => LivePlayerCubit(session: widget.session),
        child: Builder(
          builder: (BuildContext context) {
            final LivePlayerCubit cubit = context.read<LivePlayerCubit>();

            return PopScope(
              onPopInvokedWithResult: (bool didPop, Object? result) {
                if (didPop) cubit.leave();
              },
              child: BlocBuilder<LivePlayerCubit, LivePlayerState>(
                builder: (BuildContext context, LivePlayerState state) {
                  if (state.isJoining) {
                    return _Shell(
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state.hasFailed) {
                    return _Shell(
                      child: AppErrorView(
                        errorKey: state.errorKey,
                        onRetry: cubit.join,
                      ),
                    );
                  }

                  final Widget stage = LivePlayerStage(
                    item: state.item!,
                    isFullscreen: _isFullscreen,
                    onFullscreenChanged: (bool value) =>
                        setState(() => _isFullscreen = value),
                  );

                  if (_isFullscreen) {
                    return Scaffold(backgroundColor: Colors.black, body: stage);
                  }

                  return _Shell(
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 24.h),
                      children: <Widget>[
                        stage,

                        SizedBox(height: 16.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: LivePlayerSummaryCard(session: widget.session),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      AppSectionScaffold(title: context.tr('live_broadcast'), child: child);
}
