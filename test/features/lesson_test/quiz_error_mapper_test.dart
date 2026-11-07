import 'package:bilhikma/core/network/api_client.dart';
import 'package:bilhikma/core/network/api_envelope.dart';
import 'package:bilhikma/core/utils/error_mapper.dart';
import 'package:bilhikma/features/lesson_test/data/data_source/lesson_test_data_source.dart';
import 'package:bilhikma/features/lesson_test/data/models/lesson_test_model.dart';
import 'package:bilhikma/features/lesson_test/data/models/quiz_attempt_model.dart';
import 'package:bilhikma/features/lesson_test/data/quiz_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClient extends ApiClient {
  _FakeClient(this.response);

  final ApiEnvelope response;
  String? lastPath;
  Object? lastData;

  @override
  Future<ApiEnvelope> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    lastPath = path;
    return response;
  }

  @override
  Future<ApiEnvelope> post(String path, {Object? data}) async {
    lastPath = path;
    lastData = data;
    return response;
  }

  @override
  Future<ApiEnvelope> put(String path, {Object? data}) async {
    lastPath = path;
    lastData = data;
    return response;
  }
}

ApiEnvelope _envelope(Object? data) =>
    ApiEnvelope(statusCode: ApiEnvelope.successCode, data: data);

void main() {
  group('quiz error mapping', () {
    test('keeps quiz 403s local and maps the stable reason first', () {
      final AppException translated = QuizErrorMapper.translate(
        const AppException(
          'session_expired',
          statusCode: 403,
          endsSession: true,
          errors: <String, List<String>>{
            'reason': <String>['video_required'],
          },
        ),
      );

      expect(translated.key, 'quiz_video_incomplete');
      expect(translated.endsSession, isFalse);
    });

    test('maps a locked 403 from the message fallback', () {
      final AppException translated = QuizErrorMapper.translate(
        const AppException(
          'session_expired',
          statusCode: 403,
          message: 'This quiz is locked until the video is complete',
          endsSession: true,
        ),
      );

      expect(translated.key, 'quiz_video_incomplete');
      expect(translated.endsSession, isFalse);
    });

    test('maps an article-read 403 before the generic fallback', () {
      final AppException translated = QuizErrorMapper.translate(
        const AppException(
          'forbidden',
          statusCode: 403,
          message: 'يجب قراءة المقال قبل بدء الاختبار',
        ),
      );

      expect(translated.key, 'quiz_article_not_read');
    });

    test('keeps the generic 403 fallback for an unrelated reason', () {
      final AppException translated = QuizErrorMapper.translate(
        const AppException(
          'forbidden',
          statusCode: 403,
          message: 'not allowed for your current enrollment',
        ),
      );

      expect(translated.key, 'quiz_unavailable');
    });

    test('maps validation reasons without hiding the original errors', () {
      final AppException translated = QuizErrorMapper.translate(
        const AppException(
          'validation_error',
          statusCode: 422,
          errors: <String, List<String>>{
            'answers': <String>['invalid'],
            'code': <String>['attempts_exhausted'],
          },
        ),
      );

      expect(translated.key, 'quiz_attempts_exhausted');
      expect(translated.errors, contains('answers'));
    });

    test('maps the per-question start and expiry 422 reasons', () {
      expect(
        QuizErrorMapper.translate(
          const AppException(
            'validation_error',
            statusCode: 422,
            message: 'يجب فتح السؤال أولاً',
          ),
        ).key,
        'quiz_question_not_opened',
      );

      expect(
        QuizErrorMapper.translate(
          const AppException(
            'validation_error',
            statusCode: 422,
            message: 'انتهى وقت هذا السؤال',
          ),
        ).key,
        'quiz_question_time_up',
      );

      expect(
        QuizErrorMapper.translate(
          const AppException(
            'validation_error',
            statusCode: 422,
            message: 'This question time is over',
          ),
        ).key,
        'quiz_question_time_up',
      );

      expect(
        QuizErrorMapper.translate(
          const AppException(
            'validation_error',
            statusCode: 422,
            message: 'انتهى وقت هذه المحاولة',
          ),
        ).key,
        'test_time_up',
      );
    });

    test('keeps 401 on the normal session path', () {
      final AppException translated = QuizErrorMapper.translate(
        const AppException(
          'session_expired',
          statusCode: 401,
          endsSession: true,
        ),
      );

      expect(translated.key, 'session_expired');
      expect(translated.endsSession, isTrue);
    });
  });

  group('lesson test data source', () {
    test('loads the overview from the content quiz endpoint', () async {
      final _FakeClient client = _FakeClient(
        _envelope(<String, dynamic>{
          'id': 4,
          'content_id': 9,
          'title': 'Quiz',
          'question_count': 3,
          'pass_score': 50,
        }),
      );
      final LessonTestDataSource source = LessonTestDataSource(client: client);

      final LessonTestModel quiz = await source.fetchQuiz(9);

      expect(client.lastPath, '/user/content/9/assessment');
      expect(quiz.id, 4);
      expect(quiz.questionCount, 3);
    });

    test(
      'posts an empty body to start and an answers envelope to submit',
      () async {
        final _FakeClient startClient = _FakeClient(
          _envelope(<String, dynamic>{
            'id': 5,
            'quiz_id': 4,
            'student_id': 9,
            'attempt_no': 1,
            'answers': <Map<String, dynamic>>[],
          }),
        );
        final LessonTestDataSource source = LessonTestDataSource(
          client: startClient,
        );

        final QuizAttemptModel attempt = await source.startAttempt(4);

        expect(startClient.lastPath, '/user/assessments/4/attempts');
        expect(startClient.lastData, isNull);
        expect(attempt.id, 5);

        final _FakeClient submitClient = _FakeClient(
          _envelope(<String, dynamic>{
            'id': 5,
            'quiz_id': 4,
            'student_id': 9,
            'attempt_no': 1,
            'score': 2,
            'max_score': 4,
            'answers': <Map<String, dynamic>>[],
          }),
        );
        await LessonTestDataSource(client: submitClient).submitAttempt(5, {
          'q1': <String, dynamic>{'option_id': 'o1'},
        });

        expect(submitClient.lastPath, '/user/assessment-attempts/5/submit');
        expect(submitClient.lastData, <String, dynamic>{
          'answers': <String, Map<String, dynamic>>{
            'q1': <String, dynamic>{'option_id': 'o1'},
          },
        });
      },
    );

    test(
      'reads the attempts list from either a list or an items map',
      () async {
        final _FakeClient listClient = _FakeClient(
          _envelope(<Map<String, dynamic>>[]),
        );
        expect(
          await LessonTestDataSource(client: listClient).fetchMyAttempts(4),
          isEmpty,
        );
        expect(listClient.lastPath, '/user/assessments/4/my-attempts');
      },
    );

    test('loads a submitted attempt by id for the result review', () async {
      final _FakeClient client = _FakeClient(
        _envelope(<String, dynamic>{
          'id': 77,
          'quiz_id': 4,
          'student_id': 9,
          'attempt_no': 1,
          'score': 1,
          'max_score': 1,
          'is_passed': true,
          'submitted_at': '2026-01-01T10:00:00+00:00',
          'answers': <Map<String, dynamic>>[],
        }),
      );

      final QuizAttemptModel attempt = await LessonTestDataSource(
        client: client,
      ).fetchAttempt(77);

      expect(client.lastPath, '/user/assessment-attempts/77');
      expect(attempt.id, 77);
      expect(attempt.isSubmitted, isTrue);
    });

    test('uses assessment paths for answers and question start', () async {
      final _FakeClient answersClient = _FakeClient(
        _envelope(<String, dynamic>{
          'attempt_id': 5,
          'saved': 1,
          'server_now': '2026-01-01T10:00:00+00:00',
        }),
      );
      await LessonTestDataSource(client: answersClient).saveAnswers(5, {
        'q1': <String, dynamic>{'option_id': 'o1'},
      });
      expect(answersClient.lastPath, '/user/assessment-attempts/5/answers');

      final _FakeClient startClient = _FakeClient(
        _envelope(<String, dynamic>{
          'attempt_id': 5,
          'question_id': 'q1',
          'server_now': '2026-01-01T10:00:00+00:00',
          'timer': <String, dynamic>{},
        }),
      );
      await LessonTestDataSource(client: startClient).startQuestion(5, 'q1');
      expect(
        startClient.lastPath,
        '/user/assessment-attempts/5/questions/q1/start',
      );
    });

    test('reads the subject id from the content detail', () async {
      final _FakeClient client = _FakeClient(
        _envelope(<String, dynamic>{'id': 9, 'category_subject_id': 3}),
      );

      final int id = await LessonTestDataSource(
        client: client,
      ).fetchCategorySubjectId(9);

      expect(client.lastPath, '/user/content/9');
      expect(id, 3);
    });

    test('returns 0 when the content detail has no subject id', () async {
      final _FakeClient client = _FakeClient(
        _envelope(<String, dynamic>{'id': 9}),
      );

      expect(
        await LessonTestDataSource(client: client).fetchCategorySubjectId(9),
        0,
      );
    });
  });
}
