import '../../../core/utils/error_mapper.dart';

class QuizErrorMapper {
  QuizErrorMapper._();

  static const Set<String> _stableKeys = <String>{
    'quiz_locked',
    'quiz_video_incomplete',
    'quiz_article_not_read',
    'quiz_unavailable',
    'quiz_not_found',
    'quiz_cooldown',
    'quiz_attempts_exhausted',
    'quiz_already_submitted',
    'quiz_answers_invalid',
  };

  static AppException translate(AppException error) {
    final int? status = error.statusCode;

    final String key = _stableKeys.contains(error.key)
        ? error.key
        : switch (status) {
            401 => error.key,
            403 => _forbiddenKey(error),
            404 => 'quiz_not_found',
            422 => _validationKey(error),
            429 => 'quiz_cooldown',
            _ => error.key,
          };

    return AppException(
      key,
      message: error.message,
      errors: error.errors,
      statusCode: error.statusCode,
      data: error.data,
      endsSession: error.endsSession && status != 403,
    );
  }

  static String _forbiddenKey(AppException error) {
    final String? reason = _serverReason(error);
    if (reason != null) {
      if (_isArticleReason(reason)) {
        return 'quiz_article_not_read';
      }
      if (reason.contains('video') ||
          reason.contains('watch') ||
          reason.contains('100')) {
        return 'quiz_video_incomplete';
      }
      if (reason.contains('lock') || reason.contains('block')) {
        return 'quiz_locked';
      }
    }

    final String text =
        '${error.message ?? ''} '
        '${error.errors.values.expand((List<String> e) => e).join(' ')}';
    final String lower = text.toLowerCase();

    if (_isArticleReason(lower)) {
      return 'quiz_article_not_read';
    }
    if (lower.contains('video') ||
        lower.contains('watch') ||
        lower.contains('100')) {
      return 'quiz_video_incomplete';
    }
    if (lower.contains('locked') || lower.contains('blocked')) {
      return 'quiz_locked';
    }
    return 'quiz_unavailable';
  }

  static bool _isArticleReason(String text) =>
      text.contains('article') ||
      text.contains('not_read') ||
      text.contains('read_the') ||
      text.contains('read_content') ||
      text.contains('reading') ||
      text.contains('قراءة') ||
      text.contains('قراء') ||
      text.contains('مقال');

  static String _validationKey(AppException error) {
    final String? reason = _serverReason(error);
    if (reason != null) {
      if (reason.contains('attempt') &&
          (reason.contains('exhaust') || reason.contains('limit'))) {
        return 'quiz_attempts_exhausted';
      }
      if (reason.contains('submit')) {
        return 'quiz_already_submitted';
      }
    }

    final String text =
        '${error.message ?? ''} ${error.errors.keys.join(' ')} '
        '${error.errors.values.expand((List<String> e) => e).join(' ')}';
    final String lower = text.toLowerCase();

    if (lower.contains('attempt') &&
        (lower.contains('exhaust') || lower.contains('limit'))) {
      return 'quiz_attempts_exhausted';
    }
    if (lower.contains('already') && lower.contains('submit')) {
      return 'quiz_already_submitted';
    }
    if (lower.contains('submit')) {
      return 'quiz_already_submitted';
    }
    return 'quiz_answers_invalid';
  }

  static String? _serverReason(AppException error) {
    const List<String> keys = <String>['code', 'reason', 'error_code', 'error'];

    for (final String key in keys) {
      final List<String> values = error.errorsFor(key);
      if (values.isNotEmpty) return values.first.toLowerCase().trim();
    }

    final Object? data = error.data;
    if (data is Map) {
      for (final String key in keys) {
        final Object? value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.toLowerCase().trim();
        }
      }
    }

    return null;
  }
}
