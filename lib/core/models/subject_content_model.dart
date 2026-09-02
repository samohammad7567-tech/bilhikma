import '../network/json_reader.dart';
import 'subject_tab_counts_model.dart';
import 'textbook_model.dart';

class SubjectContentModel {
  const SubjectContentModel({
    required this.categorySubjectId,
    required this.name,
    this.iconUrl,
    this.position = 0,
    this.categoryId = 0,
    this.categoryName = '',
    this.entityName = '',
    this.tabs = const SubjectTabCountsModel(),
    this.lessonsCount = 0,
    this.completedLessons = 0,
    this.progressPercent = 0,
    this.textbooks = const <TextbookModel>[],
  });

  final int categorySubjectId;
  final String name;

  /// Where the class places this subject, 1-based — the same number the
  /// subjects list prints on its index strip, so the two screens agree.
  ///
  /// `GET /user/subjects/{id}` does not return this field yet; until it does it
  /// parses as 0, which [LessonSubjectHeader] reads as "unknown" and hides the
  /// strip for rather than printing a wrong number.
  final int position;

  final String? iconUrl;
  final int categoryId;
  final String categoryName;
  final String entityName;
  final SubjectTabCountsModel tabs;

  final int lessonsCount;
  final int completedLessons;
  final int progressPercent;

  final List<TextbookModel> textbooks;

  double get progress => (progressPercent / 100).clamp(0.0, 1.0);

  factory SubjectContentModel.fromData(Map<String, dynamic> data) =>
      SubjectContentModel(
        categorySubjectId: Json.asInt(data['category_subject_id']),
        name: Json.asString(data['name']),
        position: Json.asInt(data['position']),
        iconUrl: Json.asOptionalString(data['icon_url']),
        categoryId: Json.asInt(data['category_id']),
        categoryName: Json.asString(data['category_name']),
        entityName: Json.asString(data['entity_name']),
        tabs: SubjectTabCountsModel.fromJson(Json.asMap(data['tabs'])),
        lessonsCount: Json.asInt(data['lessons_count']),
        completedLessons: Json.asInt(data['completed_lessons']),
        progressPercent: Json.asInt(data['progress_percent']),
        textbooks: Json.asList<TextbookModel>(
          data['textbooks'],
          TextbookModel.fromJson,
        ),
      );
}
