import '../../../../core/network/json_reader.dart';

class QuestionTimerModel {
  const QuestionTimerModel({
    this.enabled = false,
    this.startedAt,
    this.expiresAt,
    this.secondsLeft,
    this.hasExpired = false,
    this.canAnswer = false,
  });

  final bool enabled;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final int? secondsLeft;
  final bool hasExpired;
  final bool canAnswer;

  bool get isTimed => enabled && expiresAt != null;

  factory QuestionTimerModel.fromJson(Map<String, dynamic> json) =>
      QuestionTimerModel(
        enabled: Json.asBool(json['enabled']),
        startedAt: Json.asDateTime(json['started_at']),
        expiresAt: Json.asDateTime(json['expires_at']),
        secondsLeft: Json.asOptionalInt(json['seconds_left']),
        hasExpired: Json.asBool(json['has_expired']),
        canAnswer: Json.asBool(json['can_answer']),
      );

  QuestionTimerModel copyWith({
    bool? enabled,
    DateTime? startedAt,
    DateTime? expiresAt,
    int? secondsLeft,
    bool? hasExpired,
    bool? canAnswer,
  }) => QuestionTimerModel(
    enabled: enabled ?? this.enabled,
    startedAt: startedAt ?? this.startedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    hasExpired: hasExpired ?? this.hasExpired,
    canAnswer: canAnswer ?? this.canAnswer,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'enabled': enabled,
    'started_at': startedAt?.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'seconds_left': secondsLeft,
    'has_expired': hasExpired,
    'can_answer': canAnswer,
  };
}
