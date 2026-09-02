import '../network/json_reader.dart';

enum LessonCategory {
  lessons('lessons'),
  live('live'),
  books('books'),

  pictures('pictures');

  const LessonCategory(this.key);

  final String key;
}
