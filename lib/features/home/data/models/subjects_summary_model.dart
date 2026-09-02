import '../../../../core/network/json_reader.dart';

class SubjectsSummaryModel {
  const SubjectsSummaryModel({
    this.subjectsCount = 0,
    this.lessonsCount = 0,
    this.completedLessons = 0,
    this.progressPercent = 0,
  });

  final int subjectsCount;
  final int lessonsCount;
  final int completedLessons;

  final int progressPercent;

  double get progress => (progressPercent / 100).clamp(0.0, 1.0);

  factory SubjectsSummaryModel.fromJson(Map<String, dynamic> json) =>
      SubjectsSummaryModel(
        subjectsCount: Json.asInt(json['subjects_count']),
        lessonsCount: Json.asInt(json['lessons_count']),
        completedLessons: Json.asInt(json['completed_lessons']),
        progressPercent: Json.asInt(json['progress_percent']),
      );
}
