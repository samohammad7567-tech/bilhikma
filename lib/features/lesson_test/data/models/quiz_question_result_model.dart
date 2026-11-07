import '../../../../core/enums/test_question_type_enum.dart';
import '../../../../core/network/json_reader.dart';
import 'test_option_model.dart';

class QuizQuestionResultModel {
  const QuizQuestionResultModel({
    required this.questionId,
    required this.questionType,
    this.questionText = '',
    this.score = 0,
    this.awardedScore,
    this.isCorrect,
    this.givenAnswer = const <String, dynamic>{},
    this.blankResults = const <String, dynamic>{},
    this.componentResults = const <String, dynamic>{},
    this.options = const <String, dynamic>{},
    this.solution,
    this.explanation,
  });

  final String questionId;
  final TestQuestionType questionType;
  final String questionText;
  final double score;
  final double? awardedScore;
  final bool? isCorrect;
  final Map<String, dynamic> givenAnswer;
  final Map<String, dynamic> blankResults;
  final Map<String, dynamic> componentResults;
  final Map<String, dynamic> options;
  final Map<String, dynamic>? solution;
  final String? explanation;

  bool get hasGivenAnswer =>
      givenAnswer.isNotEmpty ||
      blankResults.isNotEmpty ||
      componentResults.isNotEmpty;

  bool get hasSolution => solution != null && solution!.isNotEmpty;

  bool? get correctBoolean => Json.asOptionalBool(options['correct_answer']);

  List<TestOptionModel> get solutionOptions {
    final Map<String, dynamic>? data = solution;
    if (data == null) return const <TestOptionModel>[];

    final Map<String, dynamic> details = Json.asMap(data['details']);
    final Object? raw =
        details['options'] ??
        data['options'] ??
        details['correct_options'] ??
        data['correct_options'];

    return Json.asMapList(
      raw,
    ).map(TestOptionModel.fromJson).toList(growable: false);
  }

  TestOptionModel? solutionOptionFor(String optionId) {
    if (optionId.trim().isEmpty) return null;

    for (final TestOptionModel option in solutionOptions) {
      if (option.id == optionId) return option;
    }

    return null;
  }

  String? feedbackFor(String optionId) {
    final String? feedback = solutionOptionFor(optionId)?.feedback?.trim();
    return feedback == null || feedback.isEmpty ? null : feedback;
  }

  factory QuizQuestionResultModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> given = Json.asMap(json['given_answer']);

    _putIfAbsent(given, 'option_id', json['selected_option_id']);
    _putIfAbsent(given, 'boolean', json['selected_boolean']);
    _putIfAbsent(given, 'text', json['answer_text']);

    return QuizQuestionResultModel(
      questionId: Json.asString(json['question_id']),
      questionType: TestQuestionType.fromJson(json['question_type']),
      questionText: Json.asString(json['question_text']),
      score: Json.asDouble(json['score']),
      awardedScore: json['awarded_score'] == null
          ? null
          : Json.asDouble(json['awarded_score']),
      isCorrect: Json.asOptionalBool(json['is_correct']),
      givenAnswer: given,
      blankResults: _idMap(json['blank_results']),
      componentResults: _idMap(json['component_results']),
      options: Json.asMap(json['options']),
      solution: Json.asOptionalMap(json['solution']),
      explanation: Json.asOptionalString(json['explanation']),
    );
  }

  static void _putIfAbsent(
    Map<String, dynamic> target,
    String key,
    Object? value,
  ) {
    if (target[key] == null && value != null) target[key] = value;
  }

  static const List<String> _idKeys = <String>[
    'blank_id',
    'component_id',
    'item_id',
    'left_id',
    'right_id',
    'id',
    'key',
  ];

  static Map<String, dynamic> _idMap(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is! List) return <String, dynamic>{};

    return <String, dynamic>{
      for (int index = 0; index < value.length; index++)
        _rowId(value[index], index): value[index],
    };
  }

  static String _rowId(Object? row, int index) {
    if (row is Map) {
      for (final String key in _idKeys) {
        final Object? id = row[key];
        if (id != null && '$id'.trim().isNotEmpty) return '$id'.trim();
      }
    }

    return '$index';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'question_id': questionId,
    'question_type': questionType.key,
    'question_text': questionText,
    'score': score,
    'awarded_score': awardedScore,
    'is_correct': isCorrect,
    'given_answer': givenAnswer,
    'blank_results': blankResults,
    'component_results': componentResults,
    'options': options,
    'solution': solution,
    'explanation': explanation,
  };
}
