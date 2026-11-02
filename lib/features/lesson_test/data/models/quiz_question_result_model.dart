import '../../../../core/enums/test_question_type_enum.dart';
import '../../../../core/network/json_reader.dart';

class QuizQuestionResultModel {
  const QuizQuestionResultModel({
    required this.questionId,
    required this.questionType,
    this.score = 0,
    this.awardedScore,
    this.isCorrect,
    this.givenAnswer = const <String, dynamic>{},
    this.blankResults = const <String, dynamic>{},
    this.componentResults = const <String, dynamic>{},
    this.solution,
    this.explanation,
  });

  final String questionId;
  final TestQuestionType questionType;
  final double score;
  final double? awardedScore;
  final bool? isCorrect;
  final Map<String, dynamic> givenAnswer;
  final Map<String, dynamic> blankResults;
  final Map<String, dynamic> componentResults;
  final Map<String, dynamic>? solution;
  final String? explanation;

  factory QuizQuestionResultModel.fromJson(Map<String, dynamic> json) =>
      QuizQuestionResultModel(
        questionId: Json.asString(json['question_id']),
        questionType: TestQuestionType.fromJson(json['question_type']),
        score: Json.asDouble(json['score']),
        awardedScore: json['awarded_score'] == null
            ? null
            : Json.asDouble(json['awarded_score']),
        isCorrect: Json.asOptionalBool(json['is_correct']),
        givenAnswer: Json.asMap(json['given_answer']),
        blankResults: Json.asMap(json['blank_results']),
        componentResults: Json.asMap(json['component_results']),
        solution: Json.asOptionalMap(json['solution']),
        explanation: Json.asOptionalString(json['explanation']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'question_id': questionId,
    'question_type': questionType.key,
    'score': score,
    'awarded_score': awardedScore,
    'is_correct': isCorrect,
    'given_answer': givenAnswer,
    'blank_results': blankResults,
    'component_results': componentResults,
    'solution': solution,
    'explanation': explanation,
  };
}
