import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../features/archive/data/data_source/archive_data_source.dart';
import '../../features/archive/data/repos/archive_repo.dart';
import '../../features/archive/presentation/cubit/archive_cubit.dart';
import '../../features/auth/forget_password/data/data_source/forget_password_data_source.dart';
import '../../features/auth/forget_password/data/repos/forget_password_repo.dart';
import '../../features/auth/forget_password/presentation/cubit/forget_password_cubit.dart';
import '../../features/auth/forget_password/presentation/cubit/set_password_cubit.dart';
import '../../features/auth/forget_password/presentation/refactor/set_password_args.dart';
import '../../features/auth/login/data/data_source/login_data_source.dart';
import '../../features/auth/login/data/repos/login_repo.dart';
import '../../features/auth/login/presentation/cubit/login_cubit.dart';
import '../../features/educational_pathways/data/data_source/educational_pathways_data_source.dart';
import '../../features/educational_pathways/data/repos/educational_pathways_repo.dart';
import '../../features/educational_pathways/presentation/cubit/educational_pathways_cubit.dart';
import '../../features/gallery/data/data_source/gallery_data_source.dart';
import '../../features/gallery/data/repos/gallery_repo.dart';
import '../../features/gallery/presentation/cubit/gallery_cubit.dart';
import '../../features/home/data/data_source/home_data_source.dart';
import '../../features/home/data/repos/home_repo.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/enrollments/data/data_source/enrollments_data_source.dart';
import '../../features/enrollments/data/repos/enrollments_repo.dart';
import '../../features/lessons/data/data_source/lessons_data_source.dart';
import '../../features/lessons/data/data_source/saved_lessons_data_source.dart';
import '../../features/lessons/data/repos/lessons_repo.dart';
import '../../features/live_sessions/data/data_source/live_sessions_data_source.dart';
import '../../features/live_sessions/data/repos/live_sessions_repo.dart';
import '../../features/live_sessions/presentation/cubit/live_sessions_cubit.dart';
import '../../features/lessons/presentation/cubit/lesson_save_cubit.dart';
import '../../features/lessons/presentation/cubit/lessons_cubit.dart';
import '../../features/lessons/presentation/cubit/saved_lessons_cubit.dart';
import '../../features/security/data/data_source/security_data_source.dart';
import '../../features/security/data/repos/security_repo.dart';
import '../../features/security/presentation/cubit/security_cubit.dart';
import '../../features/search/data/data_source/search_data_source.dart';
import '../../features/search/data/repos/search_repo.dart';
import '../../features/search/presentation/cubit/search_cubit.dart';
import '../../features/profile/data/data_source/profile_data_source.dart';
import '../../features/profile/data/repos/profile_repo.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/notifications/data/data_source/notifications_data_source.dart';
import '../../features/notifications/data/repos/notifications_repo.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/settings/data/data_source/settings_data_source.dart';
import '../../features/settings/data/repos/settings_repo.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/subject_content/data/data_source/subject_content_data_source.dart';
import '../../features/subject_content/data/repos/subject_content_repo.dart';
import '../../features/subject_content/presentation/cubit/subject_content_cubit.dart';
import '../../features/textbooks/data/data_source/textbooks_data_source.dart';
import '../../features/textbooks/data/repos/textbooks_repo.dart';
import '../../features/subjects/data/data_source/subjects_data_source.dart';
import '../../features/subjects/data/repos/subjects_repo.dart';
import '../../features/subjects/presentation/cubit/subjects_cubit.dart';
import '../../features/sidebar/data/data_source/sidebar_data_source.dart';
import '../../features/sidebar/data/repos/sidebar_repo.dart';
import '../../features/sidebar/presentation/cubit/sidebar_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../app/cubit/app_preferences_cubit.dart';
import '../services/dio_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  await _initCore();
  await _initSplash();
  await _initAuth();
  await _initForgetPassword();
  await _initHome();
  await _initLessons();
  await _initSidebar();
  await _initSettings();
  await _initNotifications();
  await _initProfile();
  await _initSearch();
  await _initArchive();
  await _initGallery();
  await _initEducationalPathways();
  await _initSubjects();
  await _initSubjectContent();
  await _initTextbooks();
  await _initEnrollments();
  await _initLiveSessions();
  await _initSecurity();
}

Future<void> _initSecurity() async {
  getIt
    ..registerLazySingleton(SecurityDataSource.new)
    ..registerLazySingleton(() => SecurityRepo(dataSource: getIt()))
    ..registerSingleton(SecurityCubit(repo: getIt()));
}

Future<void> _initEnrollments() async {
  getIt
    ..registerLazySingleton(() => EnrollmentsRepo(dataSource: getIt()))
    ..registerLazySingleton(EnrollmentsDataSource.new);
}

Future<void> _initLiveSessions() async {
  getIt
    ..registerFactory(() => LiveSessionsCubit(repo: getIt()))
    ..registerLazySingleton(() => LiveSessionsRepo(dataSource: getIt()))
    ..registerLazySingleton(LiveSessionsDataSource.new);
}

Future<void> _initCore() async {
  final navigatorKey = GlobalKey<NavigatorState>();
  if (DioService.dio == null) DioService.init();

  getIt
    ..registerLazySingleton(AppPreferencesCubit.new)
    ..registerSingleton<Dio>(DioService.dio!)
    ..registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);
}

Future<void> _initSplash() async {
  getIt.registerFactory(SplashCubit.new);
}

Future<void> _initAuth() async {
  getIt
    ..registerFactory(() => LoginCubit(repo: getIt()))
    ..registerLazySingleton(() => LoginRepo(dataSource: getIt()))
    ..registerLazySingleton(LoginDataSource.new);
}

Future<void> _initForgetPassword() async {
  getIt
    ..registerFactory(() => ForgetPasswordCubit(repo: getIt()))
    ..registerFactoryParam<SetPasswordCubit, SetPasswordArgs, void>(
      (SetPasswordArgs args, _) => SetPasswordCubit(args: args, repo: getIt()),
    )
    ..registerLazySingleton(() => ForgetPasswordRepo(dataSource: getIt()))
    ..registerLazySingleton(ForgetPasswordDataSource.new);
}

Future<void> _initHome() async {
  getIt
    ..registerFactory(() => HomeCubit(repo: getIt()))
    ..registerLazySingleton(() => HomeRepo(dataSource: getIt()))
    ..registerLazySingleton(HomeDataSource.new);
}

Future<void> _initLessons() async {
  getIt
    ..registerFactoryParam<LessonsCubit, int, void>(
      (int categorySubjectId, _) =>
          LessonsCubit(categorySubjectId: categorySubjectId, repo: getIt()),
    )
    ..registerFactory(() => SavedLessonsCubit(dataSource: getIt()))
    ..registerLazySingleton(() => LessonSaveCubit(dataSource: getIt()))
    ..registerLazySingleton(() => SavedLessonsDataSource(lessons: getIt()))
    ..registerLazySingleton(() => LessonsRepo(dataSource: getIt()))
    ..registerLazySingleton(LessonsDataSource.new);
}

Future<void> _initSidebar() async {
  getIt
    ..registerFactory(() => SidebarCubit(repo: getIt()))
    ..registerLazySingleton(() => SidebarRepo(dataSource: getIt()))
    ..registerLazySingleton(SidebarDataSource.new);
}

Future<void> _initSettings() async {
  getIt
    ..registerFactory(() => SettingsCubit(repo: getIt()))
    ..registerLazySingleton(() => SettingsRepo(dataSource: getIt()))
    ..registerLazySingleton(SettingsDataSource.new);
}

Future<void> _initProfile() async {
  getIt
    ..registerFactory(() => ProfileCubit(repo: getIt()))
    ..registerLazySingleton(() => ProfileRepo(dataSource: getIt()))
    ..registerLazySingleton(ProfileDataSource.new);
}

Future<void> _initNotifications() async {
  getIt
    ..registerLazySingleton(() => NotificationsCubit(repo: getIt()))
    ..registerLazySingleton(() => NotificationsRepo(dataSource: getIt()))
    ..registerLazySingleton(NotificationsDataSource.new);
}

Future<void> _initSearch() async {
  getIt
    ..registerFactory(() => SearchCubit(repo: getIt()))
    ..registerLazySingleton(() => SearchRepo(dataSource: getIt()))
    ..registerLazySingleton(SearchDataSource.new);
}

Future<void> _initArchive() async {
  getIt
    ..registerFactory(() => ArchiveCubit(repo: getIt()))
    ..registerLazySingleton(() => ArchiveRepo(dataSource: getIt()))
    ..registerLazySingleton(ArchiveDataSource.new);
}

Future<void> _initGallery() async {
  getIt
    ..registerFactory(() => GalleryCubit(repo: getIt()))
    ..registerLazySingleton(() => GalleryRepo(dataSource: getIt()))
    ..registerLazySingleton(GalleryDataSource.new);
}

Future<void> _initSubjects() async {
  getIt
    ..registerFactory(() => SubjectsCubit(repo: getIt()))
    ..registerLazySingleton(() => SubjectsRepo(dataSource: getIt()))
    ..registerLazySingleton(SubjectsDataSource.new);
}

Future<void> _initSubjectContent() async {
  getIt
    ..registerFactoryParam<SubjectContentCubit, int, void>(
      (int categorySubjectId, _) => SubjectContentCubit(
        categorySubjectId: categorySubjectId,
        repo: getIt(),
        lessonsRepo: getIt(),
        textbooksRepo: getIt(),
      ),
    )
    ..registerLazySingleton(() => SubjectContentRepo(dataSource: getIt()))
    ..registerLazySingleton(SubjectContentDataSource.new);
}

Future<void> _initTextbooks() async {
  getIt
    ..registerLazySingleton(() => TextbooksRepo(dataSource: getIt()))
    ..registerLazySingleton(TextbooksDataSource.new);
}

Future<void> _initEducationalPathways() async {
  getIt
    ..registerFactory(() => EducationalPathwaysCubit(repo: getIt()))
    ..registerLazySingleton(() => EducationalPathwaysRepo(dataSource: getIt()))
    ..registerLazySingleton(
      () => EducationalPathwaysDataSource(enrollments: getIt()),
    );
}
