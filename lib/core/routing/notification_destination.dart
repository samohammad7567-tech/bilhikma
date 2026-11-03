import '../../features/lesson_test/presentation/refactor/lesson_test_args.dart';
import '../../features/notifications/data/models/notification_payload.dart';
import '../enums/content_type_enum.dart';
import '../enums/notification_kind_enum.dart';
import 'app_routes.dart';
import 'lesson_detail_args.dart';
import 'subject_content_args.dart';

class NotificationDestination {
  const NotificationDestination(this.route, {this.arguments});

  final String route;

  final Object? arguments;
  static NotificationDestination? resolve({
    required NotificationKind kind,
    NotificationPayload payload = NotificationPayload.none,
    String? deepLink,
  }) {
    final _DeepLink link = _DeepLink.parse(deepLink);

    return fromPayload(payload) ??
        _forTarget(link) ??
        _asLesson(link) ??
        _fromKind(kind);
  }

  static NotificationDestination? fromPayload(NotificationPayload payload) {
    final NotificationDestination? quizResult = _quizResult(payload);
    if (quizResult != null) return quizResult;

    if (payload.hasContent) {
      return NotificationDestination(
        AppRoutes.lessonDetail,
        arguments: LessonDetailArgs(
          id: payload.contentId,
          type: payload.contentType,
        ),
      );
    }

    if (payload.hasLiveSession) {
      return const NotificationDestination(AppRoutes.live);
    }

    if (payload.hasSubject) {
      return NotificationDestination(
        AppRoutes.subjectContent,
        arguments: SubjectContentArgs(
          categorySubjectId: payload.categorySubjectId,
        ),
      );
    }

    return null;
  }

  static NotificationDestination? fromDeepLink(String? link) {
    final _DeepLink parsed = _DeepLink.parse(link);

    return _forTarget(parsed) ?? _asLesson(parsed);
  }

  static NotificationDestination? fromPushData(Map<String, dynamic> data) {
    final NotificationPayload payload = NotificationPayload.fromJson(data);
    final NotificationDestination? quizResult = _quizResultFromData(
      data,
      payload,
    );
    if (quizResult != null) return quizResult;

    final NotificationDestination? linked = fromDeepLink(
      _firstString(data, const <String>[
        'deep_link',
        'deeplink',
        'link',
        'route',
        'url',
      ]),
    );
    if (linked != null) return linked;

    final ContentType contentType = ContentType.fromJson(data['content_type']);

    final int contentId = _firstId(<String?>[
      _firstString(data, const <String>['content_id', 'lesson_id']),
    ]);
    if (contentId > 0) {
      return NotificationDestination(
        AppRoutes.lessonDetail,
        arguments: LessonDetailArgs(id: contentId, type: contentType),
      );
    }

    final int liveSessionId = _firstId(<String?>[
      _firstString(data, const <String>['live_session_id', 'session_id']),
    ]);
    if (liveSessionId > 0) {
      return const NotificationDestination(AppRoutes.live);
    }

    final int subjectId = _firstId(<String?>[
      _firstString(data, const <String>['category_subject_id', 'subject_id']),
    ]);
    if (subjectId > 0) {
      return NotificationDestination(
        AppRoutes.subjectContent,
        arguments: SubjectContentArgs(categorySubjectId: subjectId),
      );
    }

    return _fromKind(NotificationKind.fromJson(data['type'] ?? data['kind']));
  }

  static NotificationDestination? _quizResult(NotificationPayload payload) {
    if (!payload.hasQuizResult) return null;

    return _quizResultDestination(
      contentId: payload.contentId,
      contentType: payload.contentType,
      categorySubjectId: payload.categorySubjectId,
      quizId: payload.quizId,
      attemptId: payload.attemptId,
    );
  }

  static NotificationDestination? _quizResultFromData(
    Map<String, dynamic> data,
    NotificationPayload payload,
  ) {
    final NotificationDestination? resolved = _quizResult(payload);
    if (resolved != null) return resolved;

    final int attemptId = _firstId(<String?>[
      _firstString(data, const <String>['attempt_id', 'quiz_attempt_id']),
    ]);
    final int quizId = _firstId(<String?>[
      _firstString(data, const <String>['quiz_id']),
    ]);
    final int contentId = _firstId(<String?>[
      _firstString(data, const <String>['content_id', 'lesson_id']),
    ]);
    final String action =
        (_firstString(data, const <String>['action', 'type', 'kind']) ?? '')
            .toLowerCase()
            .replaceAll('-', '_');

    final bool isResult =
        action.contains('quiz_result') ||
        (action.contains('quiz') && action.contains('attempt'));

    if (!isResult || (contentId <= 0 && quizId <= 0)) return null;

    return _quizResultDestination(
      contentId: contentId,
      contentType: ContentType.fromJson(data['content_type']),
      categorySubjectId: _firstId(<String?>[
        _firstString(data, const <String>['category_subject_id', 'subject_id']),
      ]),
      quizId: quizId,
      attemptId: attemptId,
    );
  }

  static NotificationDestination _quizResultDestination({
    required int contentId,
    required ContentType contentType,
    required int categorySubjectId,
    required int quizId,
    required int attemptId,
  }) => NotificationDestination(
    AppRoutes.lessonTest,
    arguments: LessonTestArgs(
      lessonId: contentId,
      quizId: quizId > 0 ? quizId : null,
      attemptId: attemptId > 0 ? attemptId : null,
      contentType: contentType,
      categorySubjectId: categorySubjectId,
      openResult: true,
      openLessonOnBack: true,
      popOnResultBack: true,
    ),
  );

  static NotificationDestination? _forTarget(_DeepLink link) {
    switch (link.target) {
      case 'content' || 'contents' || 'lesson' || 'lessons' || 'media':
        return _lesson(link);

      case 'subject' ||
          'subjects' ||
          'subject_content' ||
          'category_subject' ||
          'categorysubject':
        if (link.id <= 0) {
          return const NotificationDestination(AppRoutes.study);
        }

        return NotificationDestination(
          AppRoutes.subjectContent,
          arguments: SubjectContentArgs(categorySubjectId: link.id),
        );

      case 'live' ||
          'lives' ||
          'live_session' ||
          'live_sessions' ||
          'session' ||
          'sessions':
        return const NotificationDestination(AppRoutes.live);

      case 'archive' || 'archives' || 'saved':
        return const NotificationDestination(AppRoutes.archive);

      case 'gallery' || 'pictures' || 'images':
        return const NotificationDestination(AppRoutes.pictures);

      case 'profile' || 'account':
        return const NotificationDestination(AppRoutes.profile);

      case 'pathway' ||
          'pathways' ||
          'educational_pathway' ||
          'educational_pathways':
        return const NotificationDestination(AppRoutes.educationalPathways);

      case 'study' || 'categories':
        return const NotificationDestination(AppRoutes.study);

      case 'search':
        return const NotificationDestination(AppRoutes.search);

      case 'settings':
        return const NotificationDestination(AppRoutes.settings);

      case 'notification' || 'notifications':
        return const NotificationDestination(AppRoutes.notification);

      default:
        return null;
    }
  }

  static NotificationDestination? _asLesson(_DeepLink link) =>
      link.target.isEmpty ? _lesson(link) : null;
  static bool _isTarget(String segment) =>
      _forTarget(
        _DeepLink(target: segment, id: 1, contentType: ContentType.video),
      ) !=
      null;

  static NotificationDestination? _lesson(_DeepLink link) => link.id <= 0
      ? null
      : NotificationDestination(
          AppRoutes.lessonDetail,
          arguments: LessonDetailArgs(id: link.id, type: link.contentType),
        );
  static NotificationDestination? _fromKind(NotificationKind kind) =>
      switch (kind) {
        NotificationKind.newContent => const NotificationDestination(
          AppRoutes.study,
        ),
        NotificationKind.liveSession || NotificationKind.liveReminder =>
          const NotificationDestination(AppRoutes.live),
        NotificationKind.enrollmentApproved => const NotificationDestination(
          AppRoutes.profile,
        ),
        _ => null,
      };

  static int _firstId(Iterable<String?> values) {
    for (final String? value in values) {
      final int id = int.tryParse((value ?? '').trim()) ?? 0;
      if (id > 0) return id;
    }

    return 0;
  }

  static String? _firstString(Map<String, dynamic> data, List<String> keys) {
    for (final String key in keys) {
      final Object? value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is num) return '$value';
    }

    return null;
  }
}

class _DeepLink {
  const _DeepLink({
    required this.id,
    required this.contentType,
    this.target = '',
  });
  final String target;
  final int id;

  final ContentType contentType;

  static const List<String> _idKeys = <String>[
    'id',
    'content_id',
    'lesson_id',
    'category_subject_id',
    'subject_id',
  ];

  static _DeepLink parse(String? link) {
    final String raw = (link ?? '').trim();
    final Uri? uri = raw.isEmpty ? null : Uri.tryParse(raw);

    if (uri == null) {
      return const _DeepLink(id: 0, contentType: ContentType.video);
    }

    final Map<String, String> query = uri.queryParameters;

    final List<String> segments =
        <String>[if (!uri.host.contains('.')) uri.host, ...uri.pathSegments]
            .map((String segment) => segment.trim().toLowerCase())
            .where((String segment) => segment.isNotEmpty)
            .toList(growable: false);

    final int targetIndex = segments.indexWhere(
      (String segment) =>
          int.tryParse(segment) == null &&
          NotificationDestination._isTarget(segment),
    );

    return _DeepLink(
      target: targetIndex < 0 ? '' : segments[targetIndex],
      id: NotificationDestination._firstId(<String?>[
        ...segments.skip(targetIndex + 1),
        ...segments,
        ..._idKeys.map((String key) => query[key]),
      ]),
      contentType: ContentType.fromJson(query['content_type'] ?? query['type']),
    );
  }
}
