import 'package:bilhikma/core/enums/content_type_enum.dart';
import 'package:bilhikma/core/enums/notification_kind_enum.dart';
import 'package:bilhikma/core/routing/app_routes.dart';
import 'package:bilhikma/core/routing/lesson_detail_args.dart';
import 'package:bilhikma/core/routing/notification_destination.dart';
import 'package:bilhikma/core/routing/subject_content_args.dart';
import 'package:bilhikma/features/notifications/data/models/notification_model.dart';
import 'package:bilhikma/features/notifications/data/models/notification_payload.dart';
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
        final NotificationDestination? target = NotificationDestination.resolve(
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
      NotificationDestination.resolve(kind: NotificationKind.adminAnnouncement),
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

  // The listing returns `deep_link: null` on every notification, so the ids
  // in `data` are the only thing that says where a card goes. These payloads
  // are taken verbatim from the notifications endpoint.
  group('api payload', () {
    NotificationModel decode(Map<String, dynamic> json) =>
        NotificationModel.fromJson(json);

    NotificationDestination? open(NotificationModel item) =>
        NotificationDestination.resolve(
          kind: item.kind,
          payload: item.payload,
          deepLink: item.deepLink,
        );

    test('new content opens the lesson the payload names', () {
      final NotificationModel item = decode(<String, dynamic>{
        'id': 1331,
        'type': 'new_content',
        'title': 'محتوى جديد',
        'message': 'كتاب الكافي الوافي في أصول الفقه',
        'data': <String, dynamic>{'content_id': 99, 'content_type': 'video'},
        'deep_link': null,
        'is_read': true,
      });

      final NotificationDestination? target = open(item);

      expect(target?.route, AppRoutes.lessonDetail);
      expect(lessonId(target), 99);
      expect((target?.arguments as LessonDetailArgs?)?.type, ContentType.video);
    });

    test('a live session resolves to the sessions list', () {
      final NotificationModel item = decode(<String, dynamic>{
        'id': 1320,
        'type': 'live_session',
        'title': 'بث مباشر جديد',
        'data': <String, dynamic>{'live_session_id': 43},
        'deep_link': null,
        'is_read': true,
      });

      // The player needs the session itself, which the cubit fetches; this
      // is the fallback for when that fetch cannot be made.
      expect(item.payload.liveSessionId, 43);
      expect(open(item)?.route, AppRoutes.live);
    });

    test('an announcement names no screen, so its own content is shown', () {
      final NotificationModel item = decode(<String, dynamic>{
        'id': 1274,
        'type': 'admin_announcement',
        'title': 'برنامج يوم السبت',
        'message': '1- فقه\r\n2- تفسير',
        'data': null,
        'image_url': 'https://bilhikma.tech/storage/a.jpeg',
        'deep_link': null,
        'is_read': false,
      });

      expect(open(item), isNull);
      expect(item.hasImage, isTrue);
    });

    test('an account notice is its message, not the profile screen', () {
      final NotificationModel item = decode(<String, dynamic>{
        'id': 1395,
        'type': 'account_status',
        'title': 'تم رفع الإيقاف عن حسابك',
        'data': <String, dynamic>{'student_id': 633},
        'deep_link': null,
        'is_read': true,
      });

      expect(item.payload.hasTarget, isFalse);
      expect(open(item), isNull);
    });

    test('a scheduled notification has no sent time', () {
      final NotificationModel item = decode(<String, dynamic>{
        'id': 772,
        'type': 'admin_announcement',
        'title': 'ترحيب',
        'status': 'scheduled',
        'sent_at': null,
        'is_read': true,
      });

      expect(item.sentAt, isNull);
    });

    test('the payload wins over a link that disagrees', () {
      final NotificationDestination? target = NotificationDestination.resolve(
        kind: NotificationKind.newContent,
        payload: const NotificationPayload(contentId: 99),
        deepLink: 'bilhikma://content/5',
      );

      expect(lessonId(target), 99);
    });
  });
}
