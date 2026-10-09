import 'package:bilhikma/core/enums/content_type_enum.dart';
import 'package:bilhikma/core/enums/notification_kind_enum.dart';
import 'package:bilhikma/core/routing/app_routes.dart';
import 'package:bilhikma/core/routing/lesson_detail_args.dart';
import 'package:bilhikma/core/routing/notification_destination.dart';
import 'package:bilhikma/core/routing/subject_content_args.dart';
import 'package:flutter_test/flutter_test.dart';

int? lessonId(NotificationDestination? target) =>
    (target?.arguments as LessonDetailArgs?)?.id;

void main() {
  group('new content', () {
    test('opens the lesson named by the deep link', () {
      final NotificationDestination? target = NotificationDestination.resolve(
        kind: NotificationKind.newContent,
        deepLink: 'bilhikma://content/5',
      );

      expect(target?.route, AppRoutes.lessonDetail);
      expect(lessonId(target), 5);
    });

    test('opens the lesson however the link spells the target', () {
      for (final String link in <String>[
        'bilhikma://contents/5',
        'bilhikma://lesson/5',
        'bilhikma://lessons/5',
        'content/5',
        '/contents/5/',
        'https://bilhikma.net/app/contents/5',
        'bilhikma://content?id=5',
        'bilhikma://content?content_id=5',
        // No target the app knows, but an id: a lesson is the documented
        // meaning of a deep link.
        'bilhikma://open/5',
        '5',
      ]) {
        final NotificationDestination? target =
            NotificationDestination.resolve(
              kind: NotificationKind.newContent,
              deepLink: link,
            );

        expect(target?.route, AppRoutes.lessonDetail, reason: link);
        expect(lessonId(target), 5, reason: link);
      }
    });

    test('falls back to the subjects screen when no id is sent', () {
      expect(
        NotificationDestination.resolve(
          kind: NotificationKind.newContent,
        )?.route,
        AppRoutes.study,
      );
      expect(
        NotificationDestination.resolve(
          kind: NotificationKind.newContent,
          deepLink: 'bilhikma://content',
        )?.route,
        AppRoutes.study,
      );
    });

    test('push payload resolves by link, then content id, then kind', () {
      expect(
        lessonId(
          NotificationDestination.fromPushData(<String, dynamic>{
            'type': 'new_content',
            'deep_link': 'bilhikma://content/3',
          }),
        ),
        3,
      );
      expect(
        lessonId(
          NotificationDestination.fromPushData(<String, dynamic>{
            'type': 'new_content',
            'content_id': '44',
          }),
        ),
        44,
      );
      expect(
        NotificationDestination.fromPushData(<String, dynamic>{
          'type': 'new_content',
        })?.route,
        AppRoutes.study,
      );
    });
  });

  test('content type travels with the link', () {
    expect(
      (NotificationDestination.fromDeepLink(
                'bilhikma://lesson/9?content_type=audio',
              )?.arguments
              as LessonDetailArgs)
          .type,
      ContentType.audio,
    );
    expect(
      (NotificationDestination.fromDeepLink('bilhikma://lesson/9')?.arguments
              as LessonDetailArgs)
          .type,
      ContentType.video,
    );
  });

  test('subject link opens that subject, or the subjects screen', () {
    final NotificationDestination? subject =
        NotificationDestination.fromDeepLink(
          'bilhikma://subject?category_subject_id=12',
        );

    expect(subject?.route, AppRoutes.subjectContent);
    expect((subject?.arguments as SubjectContentArgs).categorySubjectId, 12);
    expect(
      NotificationDestination.fromDeepLink('bilhikma://subjects')?.route,
      AppRoutes.study,
    );
  });

  test('kind fallback covers live and account notifications', () {
    expect(
      NotificationDestination.resolve(
        kind: NotificationKind.liveReminder,
      )?.route,
      AppRoutes.live,
    );
    expect(
      NotificationDestination.resolve(
        kind: NotificationKind.enrollmentApproved,
      )?.route,
      AppRoutes.profile,
    );
  });

  test('nothing to open stays null', () {
    expect(
      NotificationDestination.resolve(
        kind: NotificationKind.adminAnnouncement,
      ),
      isNull,
    );
    expect(
      NotificationDestination.resolve(
        kind: NotificationKind.custom,
        deepLink: '   ',
      ),
      isNull,
    );
    expect(
      NotificationDestination.resolve(
        kind: NotificationKind.inactivityWarning,
        deepLink: 'bilhikma://open',
      ),
      isNull,
    );
    // A push carrying only its own notification id refers to nothing.
    expect(
      NotificationDestination.fromPushData(<String, dynamic>{'id': '20'}),
      isNull,
    );
  });
}
