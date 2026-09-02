import '../../../../core/network/json_reader.dart';
import 'test_blank_model.dart';
import 'test_option_model.dart';
import 'test_pair_model.dart';
import '../../../../core/enums/test_question_type_enum.dart';
import 'test_sentence_model.dart';

class TestQuestionModel {
  const TestQuestionModel({
    required this.id,
    required this.type,
    required this.prompt,
    this.body,
    this.timeLimit,
    this.options = const <TestOptionModel>[],
    this.blanks = const <TestBlankModel>[],
    this.pairs = const <TestPairModel>[],
    this.sentences = const <TestSentenceModel>[],
  });

  final String id;
  final TestQuestionType type;

  final String prompt;

  final String? body;

  final Duration? timeLimit;

  final List<TestOptionModel> options;
  final List<TestBlankModel> blanks;
  final List<TestPairModel> pairs;
  final List<TestSentenceModel> sentences;

  List<String> get correctOptionIds => options
      .where((TestOptionModel option) => option.isCorrect)
      .map((TestOptionModel option) => option.id)
      .toList(growable: false);

  String? get mostCorrectOptionId {
    for (final TestOptionModel option in options) {
      if (option.isMostCorrect) return option.id;
    }
    return null;
  }

  List<TestSentenceModel> get orderedSentences =>
      List<TestSentenceModel>.of(sentences)..sort(
        (TestSentenceModel a, TestSentenceModel b) =>
            a.position.compareTo(b.position),
      );

  List<String> get correctSentenceIds => orderedSentences
      .map((TestSentenceModel sentence) => sentence.id)
      .toList(growable: false);

  TestOptionModel? optionById(String id) {
    for (final TestOptionModel option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  factory TestQuestionModel.fromJson(Map<String, dynamic> json) =>
      TestQuestionModel(
        id: Json.asString(json['id']),
        type: TestQuestionType.fromJson(json['type'] ?? json['question_type']),
        prompt: Json.asString(json['prompt'] ?? json['title']),
        body: Json.asOptionalString(json['body'] ?? json['template']),
        timeLimit: Json.asDuration(json['time_limit'] ?? json['duration']),
        options: Json.asMapList(
          json['options'],
        ).map(TestOptionModel.fromJson).toList(growable: false),
        blanks: Json.asMapList(
          json['blanks'],
        ).map(TestBlankModel.fromJson).toList(growable: false),
        pairs: Json.asMapList(
          json['pairs'],
        ).map(TestPairModel.fromJson).toList(growable: false),
        sentences: Json.asMapList(
          json['sentences'],
        ).map(TestSentenceModel.fromJson).toList(growable: false),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.key,
    'prompt': prompt,
    'body': body,
    'time_limit': timeLimit?.inSeconds,
    'options': options
        .map((TestOptionModel option) => option.toJson())
        .toList(growable: false),
    'blanks': blanks
        .map((TestBlankModel blank) => blank.toJson())
        .toList(growable: false),
    'pairs': pairs
        .map((TestPairModel pair) => pair.toJson())
        .toList(growable: false),
    'sentences': sentences
        .map((TestSentenceModel sentence) => sentence.toJson())
        .toList(growable: false),
  };
}
