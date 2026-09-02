import '../../../../core/network/json_reader.dart';

class TestResultModel {
  const TestResultModel({
    required this.correctCount,
    required this.totalCount,
    this.passPercent = 70,
    this.retryAfterDays = 3,
  });

  final int correctCount;
  final int totalCount;

  final int passPercent;
  final int retryAfterDays;

  int get scorePercent =>
      totalCount == 0 ? 0 : ((correctCount / totalCount) * 100).round();

  bool get passed => scorePercent >= passPercent;

  factory TestResultModel.fromJson(Map<String, dynamic> json) =>
      TestResultModel(
        correctCount: Json.asInt(json['correct_count'] ?? json['correct']),
        totalCount: Json.asInt(json['total_count'] ?? json['total']),
        passPercent: _orDefault(
          Json.asInt(json['pass_percent'] ?? json['pass_mark']),
          70,
        ),
        retryAfterDays: _orDefault(Json.asInt(json['retry_after_days']), 3),
      );

  static int _orDefault(int value, int fallback) =>
      value > 0 ? value : fallback;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'correct_count': correctCount,
    'total_count': totalCount,
    'pass_percent': passPercent,
    'retry_after_days': retryAfterDays,
    'score_percent': scorePercent,
    'passed': passed,
  };
}
