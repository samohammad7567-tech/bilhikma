import '../network/json_reader.dart';

class SubjectModel {
  const SubjectModel({
    required this.categorySubjectId,
    required this.subjectId,
    required this.name,
    this.iconUrl,
    this.orderNo = 0,
    this.position = 0,
    this.lessonsCount = 0,
    this.completedLessons = 0,
    this.progressPercent = 0,
  });

  final int categorySubjectId;

  final int subjectId;
  final String name;

  final String? iconUrl;

  /// The subject's own catalogue order. Shared across classes and not unique,
  /// so it no longer drives the list — see [position].
  final int orderNo;

  /// Where the class places this subject, 1-based and unique within the class.
  /// This is what arranges the list and what the index strip shows.
  final int position;

  final int lessonsCount;
  final int completedLessons;
  final int progressPercent;

  double get progress => (progressPercent / 100).clamp(0.0, 1.0);

  bool get isCompleted => lessonsCount > 0 && completedLessons >= lessonsCount;

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
    categorySubjectId: Json.asInt(json['category_subject_id']),
    subjectId: Json.asInt(json['subject_id']),
    name: Json.asString(json['name']),
    iconUrl: Json.asOptionalString(json['icon_url']),
    orderNo: Json.asInt(json['order_no']),
    position: Json.asInt(json['position']),
    lessonsCount: Json.asInt(json['lessons_count']),
    completedLessons: Json.asInt(json['completed_lessons']),
    progressPercent: Json.asInt(json['progress_percent']),
  );

  /// Parses `items` and arranges the subjects by [position], so every screen
  /// showing this list agrees on the order regardless of how the payload
  /// happens to arrive.
  ///
  /// The sort is stable: equal positions keep their payload order, which is
  /// what preserves the previous behaviour if a response ever omits the field
  /// and every subject falls back to 0.
  static List<SubjectModel> listFrom(Object? items) {
    final List<SubjectModel> parsed = Json.asList<SubjectModel>(
      items,
      SubjectModel.fromJson,
    );

    final List<(int, SubjectModel)> indexed = <(int, SubjectModel)>[
      for (int i = 0; i < parsed.length; i++) (i, parsed[i]),
    ];

    indexed.sort(((int, SubjectModel) a, (int, SubjectModel) b) {
      final int byPosition = a.$2.position.compareTo(b.$2.position);

      return byPosition != 0 ? byPosition : a.$1.compareTo(b.$1);
    });

    return <SubjectModel>[
      for (final (int, SubjectModel) entry in indexed) entry.$2,
    ];
  }
}
