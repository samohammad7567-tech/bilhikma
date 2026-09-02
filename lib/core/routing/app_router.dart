import 'package:flutter/material.dart';

import '../../features/archive/presentation/screens/archive_screen.dart';
import '../../features/auth/account_approved/presentation/screens/account_approved_screen.dart';
import '../../features/auth/forget_password/presentation/refactor/set_password_args.dart';
import '../../features/auth/forget_password/presentation/screens/forget_password_screen.dart';
import '../../features/auth/forget_password/presentation/screens/set_password_screen.dart';
import '../../features/auth/login/data/models/login_response_model.dart';
import '../../features/auth/login/presentation/screens/login_screen.dart';
import '../../features/auth/rejected/presentation/screens/rejected_screen.dart';
import '../../features/auth/request_review/presentation/screens/request_review_screen.dart';
import '../enums/enrollment_status_enum.dart';
import '../models/enrollment_model.dart';
import '../../features/educational_pathways/presentation/screens/educational_pathways_screen.dart';
import '../../features/gallery/presentation/screens/gallery_screen.dart';
import 'lesson_detail_args.dart';
import '../../features/lesson_detail/presentation/screens/lesson_detail_screen.dart';
import '../../features/lesson_test/presentation/refactor/lesson_test_args.dart';
import '../../features/lesson_test/presentation/screens/lesson_test_screen.dart';
import '../../features/lessons/presentation/screens/lessons_view_all_screen.dart';
import '../models/live_session_model.dart';
import '../../features/textbooks/presentation/screens/book_preview_screen.dart';
import '../../features/profile/data/models/profile_model.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/downloads_log_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/live_sessions/presentation/screens/live_player_screen.dart';
import '../../features/live_sessions/presentation/screens/live_sessions_screen.dart';
import '../../features/main_shell/presentation/screens/main_shell_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'subject_content_args.dart';
import '../../features/subject_content/presentation/screens/subject_content_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/subjects/presentation/screens/subjects_screen.dart';
import '../di/service_locator.dart';
import '../utils/cache_util.dart';
import '../utils/orientation/orientation_lock.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static const String _approvalSeenKey = 'account_approved_seen_enrollment_id';

  static Route onGenerateRoute(RouteSettings settings) {
    final Object? args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => OrientationLock(
            child: SplashScreen(
              onCompleted: (BuildContext context, bool isLoggedIn) =>
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    !isLoggedIn ? AppRoutes.login : AppRoutes.home,
                    (Route<dynamic> route) => false,
                  ),
            ),
          ),
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(
            onLoggedIn: _onLoggedIn,
            onForgotPassword: () => getIt<GlobalKey<NavigatorState>>()
                .currentState
                ?.pushNamed(AppRoutes.forgetPassword),
          ),
        );

      case AppRoutes.forgetPassword:
        return MaterialPageRoute(
          builder: (_) => ForgetPasswordScreen(
            onCodeSent: (BuildContext context, SetPasswordArgs args) =>
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.setPassword, arguments: args),
            onBackToLogin: () =>
                getIt<GlobalKey<NavigatorState>>().currentState?.pop(),
          ),
        );

      case AppRoutes.setPassword:
        return MaterialPageRoute(
          builder: (_) => SetPasswordScreen(
            args: SetPasswordArgs.fromRoute(args),

            onPasswordSet: (BuildContext context) =>
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (Route<dynamic> route) => false,
                ),
          ),
        );

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());

      case AppRoutes.live:
        return MaterialPageRoute(builder: (_) => const LiveSessionsScreen());

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => args is ProfileModel
              ? EditProfileScreen(profile: args)
              : const ProfileScreen(),
        );

      case AppRoutes.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case AppRoutes.downloadsLog:
        return MaterialPageRoute(builder: (_) => const DownloadsLogScreen());

      case AppRoutes.bookPreview:
        return MaterialPageRoute(
          builder: (_) => args is BookPreviewArgs
              ? BookPreviewScreen(args: args)
              : const SubjectsScreen(),
        );

      case AppRoutes.livePlayer:
        return MaterialPageRoute(
          builder: (_) => args is LiveSessionModel
              ? LivePlayerScreen(session: args)
              : const LiveSessionsScreen(),
        );

      case AppRoutes.study:
        return MaterialPageRoute(builder: (_) => const SubjectsScreen());

      case AppRoutes.viewAll:
        return MaterialPageRoute(
          builder: (_) =>
              LessonsViewAllScreen(categorySubjectId: args is int ? args : 0),
        );

      case AppRoutes.archive:
        return MaterialPageRoute(
          builder: (_) => ArchiveScreen(
            onLessonTap: (lesson) => _push(
              AppRoutes.lessonDetail,
              LessonDetailArgs.fromLesson(lesson),
            ),
          ),
        );

      case AppRoutes.pictures:
        return MaterialPageRoute(builder: (_) => const GalleryScreen());

      case AppRoutes.search:
        return MaterialPageRoute(
          builder: (_) => SearchScreen(
            onResultTap: (lesson) => _push(
              AppRoutes.lessonDetail,
              LessonDetailArgs.fromLesson(lesson),
            ),
          ),
        );

      case AppRoutes.lessonDetail:
        final LessonDetailArgs detailArgs = LessonDetailArgs.fromRoute(args);

        return MaterialPageRoute(
          builder: (_) => LessonDetailScreen(
            args: detailArgs,
            onGoToTest: () => _push(
              AppRoutes.lessonTest,
              LessonTestArgs(lessonId: '${detailArgs.id}'),
            ),
          ),
        );

      case AppRoutes.lessonTest:
        return MaterialPageRoute(
          builder: (_) =>
              LessonTestScreen(args: LessonTestArgs.fromRoute(args)),
        );

      case AppRoutes.subjectContent:
        return MaterialPageRoute(
          builder: (_) =>
              SubjectContentScreen(args: SubjectContentArgs.fromRoute(args)),
        );

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.educationalPathways:
        return MaterialPageRoute(
          builder: (_) => const EducationalPathwaysScreen(),
        );

      case AppRoutes.notification:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.review:
        return MaterialPageRoute(
          builder: (_) => const RequestReviewScreen(
            institution: 'Bilhikma',
            academicLevel: '1st Year',
            phone: '+966 1234567890',
          ),
        );

      case AppRoutes.rejected:
        return MaterialPageRoute(builder: (_) => const RejectedScreen());

      default:
        return MaterialPageRoute(builder: (_) => const SizedBox());
    }
  }

  static void _push(String route, Object arguments) =>
      getIt<GlobalKey<NavigatorState>>().currentState?.pushNamed(
        route,
        arguments: arguments,
      );

  static void _onLoggedIn(BuildContext context, LoginResponseModel session) {
    final EnrollmentModel? active = session.user?.activeEnrollment;

    switch (active?.status) {
      case EnrollmentStatus.pending:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => RequestReviewScreen(
              institution: active!.entityName,
              academicLevel: active.categoryName,
              phone: session.user?.phone ?? '',
            ),
          ),
          (Route<dynamic> route) => false,
        );
        return;

      case EnrollmentStatus.rejected:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => RejectedScreen(reason: active!.rejectionReason),
          ),
          (Route<dynamic> route) => false,
        );
        return;

      case EnrollmentStatus.approved:
        if (CacheUtil.get(key: _approvalSeenKey) == active!.id) {
          _goHome(context);
          return;
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext screenContext) => AccountApprovedScreen(
              onContinue: () {
                CacheUtil.setInt(key: _approvalSeenKey, value: active.id);
                _goHome(screenContext);
              },
            ),
          ),
          (Route<dynamic> route) => false,
        );
        return;

      case EnrollmentStatus.archived:
      case null:
        _goHome(context);
    }
  }

  static void _goHome(BuildContext context) => Navigator.of(
    context,
  ).pushNamedAndRemoveUntil(AppRoutes.home, (Route<dynamic> route) => false);
}
