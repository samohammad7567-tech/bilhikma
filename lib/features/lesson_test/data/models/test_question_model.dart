import '../../../../core/enums/blank_input_mode_enum.dart';
import '../../../../core/enums/test_question_type_enum.dart';
import '../../../../core/network/json_reader.dart';
import 'test_blank_model.dart';
import 'test_match_item_model.dart';
import 'test_option_model.dart';
import 'test_pair_model.dart';
import 'test_sentence_model.dart';

class TestQuestionModel {
  const TestQuestionModel({
    required this.id,
    required this.type,
    required this.prompt,
    this.body,
    this.score = 0,
    this.timeLimit,
    this.isBestAnswer = false,
    this.maxSelections,
    this.blankInputMode,
    this.options = const <TestOptionModel>[],
    this.blanks = const <TestBlankModel>[],
    this.wordBank = const <TestOptionModel>[],
    this.leftItems = const <TestMatchItemModel>[],
    this.rightItems = const <TestMatchItemModel>[],
    this.pairs = const <TestPairModel>[],
    this.sentences = const <TestSentenceModel>[],
  });

  final String id;
  final TestQuestionType type;

  final String prompt;
  final String? body;
  final double score;

  final Duration? timeLimit;
  final bool isBestAnswer;
  final int? maxSelections;
  final BlankInputMode? blankInputMode;

  final List<TestOptionModel> options;
  final List<TestBlankModel> blanks;
  final List<TestOptionModel> wordBank;
  final List<TestMatchItemModel> leftItems;
  final List<TestMatchItemModel> rightItems;

  @Deprecated('Legacy mock only; use leftItems/rightItems.')
  final List<TestPairModel> pairs;

  final List<TestSentenceModel> sentences;

  int get effectiveMaxSelections =>
      maxSelections ?? (options.isEmpty ? 1 : options.length);

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

  TestBlankModel? blankById(String id) {
    for (final TestBlankModel blank in blanks) {
      if (blank.id == id) return blank;
    }
    return null;
  }

  TestMatchItemModel? leftById(String id) {
    for (final TestMatchItemModel item in leftItems) {
      if (item.id == id) return item;
    }
    return null;
  }

  TestMatchItemModel? rightById(String id) {
    for (final TestMatchItemModel item in rightItems) {
      if (item.id == id) return item;
    }
    return null;
  }

  factory TestQuestionModel.fromJson(Map<String, dynamic> json) {
    final bool attemptShape =
        json.containsKey('question_id') || json.containsKey('question_type');

    return attemptShape
        ? TestQuestionModel._fromAttempt(json)
        : TestQuestionModel._fromLegacy(json);
  }

  factory TestQuestionModel._fromAttempt(Map<String, dynamic> json) {
    final Map<String, dynamic> options = Json.asMap(json['options']);
    final Map<String, dynamic> details = Json.asMap(options['details']);

    final TestQuestionType type = TestQuestionType.fromJson(
      json['question_type'],
    );

    final List<TestOptionModel> choiceOptions = Json.asMapList(
      details['options'],
    ).map(TestOptionModel.fromJson).toList(growable: false);

    final List<TestOptionModel> wordBank = Json.asMapList(
      details['word_bank'],
    ).map(TestOptionModel.fromJson).toList(growable: false);

    final List<TestBlankModel> blanks = Json.asMapList(
      details['blanks'],
    ).map(TestBlankModel.fromJson).toList(growable: false);

    final Map<String, dynamic> pairs = Json.asMap(details['pairs']);

    final List<TestOptionModel> displayOptions =
        type == TestQuestionType.fillBlanks
        ? (choiceOptions.isEmpty ? wordBank : choiceOptions)
        : choiceOptions;

    final String prompt = Json.asString(json['question_text']);

    final List<TestMatchItemModel> leftItems = Json.asMapList(
      pairs['left'],
    ).map(TestMatchItemModel.fromJson).toList(growable: false);

    final List<TestMatchItemModel> rightItems = Json.asMapList(
      pairs['right'],
    ).map(TestMatchItemModel.fromJson).toList(growable: false);

    return TestQuestionModel(
      id: Json.asString(json['question_id']),
      type: type,
      prompt: prompt,
      body: _bodyFor(type, prompt, blanks),
      score: Json.asDouble(json['score']),
      timeLimit: Json.asDuration(options['default_time_seconds']),
      isBestAnswer:
          Json.asOptionalString(details['choice_variant']) == 'best_answer',
      maxSelections: Json.asOptionalInt(details['max_selections']),
      blankInputMode: details['blank_input_mode'] == null
          ? null
          : BlankInputMode.fromJson(details['blank_input_mode']),
      options: displayOptions,
      blanks: blanks,
      wordBank: wordBank,
      leftItems: leftItems,
      rightItems: rightItems,
      sentences: Json.asMapList(
        details['items'],
      ).map(TestSentenceModel.fromJson).toList(growable: false),
    );
  }

  factory TestQuestionModel._fromLegacy(Map<String, dynamic> json) {
    final TestQuestionType type = TestQuestionType.fromJson(
      json['type'] ?? json['question_type'],
    );

    final List<TestOptionModel> options = Json.asMapList(
      json['options'],
    ).map(TestOptionModel.fromJson).toList(growable: false);

    final List<TestBlankModel> blanks = Json.asMapList(
      json['blanks'],
    ).map(TestBlankModel.fromJson).toList(growable: false);

    final String prompt = Json.asString(json['prompt'] ?? json['title']);

    return TestQuestionModel(
      id: Json.asString(json['id']),
      type: type,
      prompt: prompt,
      body: Json.asOptionalString(json['body'] ?? json['template']),
      timeLimit: Json.asDuration(json['time_limit'] ?? json['duration']),
      isBestAnswer: options.any(
        (TestOptionModel option) => option.isMostCorrect,
      ),
      maxSelections: type == TestQuestionType.multiChoice
          ? options.length
          : null,
      options: options,
      blanks: blanks,
      wordBank: type == TestQuestionType.fillBlanks
          ? options
          : const <TestOptionModel>[],
      pairs: Json.asMapList(
        json['pairs'],
      ).map(TestPairModel.fromJson).toList(growable: false),
      sentences: Json.asMapList(
        json['sentences'],
      ).map(TestSentenceModel.fromJson).toList(growable: false),
    );
  }

  static String? _bodyFor(
    TestQuestionType type,
    String prompt,
    List<TestBlankModel> blanks,
  ) {
    if (type != TestQuestionType.fillBlanks &&
        type != TestQuestionType.typedBlanks) {
      return null;
    }

    String body = prompt;

    for (final TestBlankModel blank in blanks) {
      final int? index = blank.blankIndex ?? _indexFromId(blank.id);
      if (index != null) {
        body = body.replaceAll('{{$index}}', '{{${blank.id}}}');
      }
    }

    return body;
  }

  static int? _indexFromId(String id) {
    final RegExpMatch? match = RegExp(r'(\d+)$').firstMatch(id);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.key,
    'prompt': prompt,
    'body': body,
    'score': score,
    'time_limit': timeLimit?.inSeconds,
    'is_best_answer': isBestAnswer,
    'max_selections': maxSelections,
    'blank_input_mode': blankInputMode?.key,
    'options': options
        .map((TestOptionModel option) => option.toJson())
        .toList(growable: false),
    'blanks': blanks
        .map((TestBlankModel blank) => blank.toJson())
        .toList(growable: false),
    'word_bank': wordBank
        .map((TestOptionModel option) => option.toJson())
        .toList(growable: false),
    'left_items': leftItems
        .map((TestMatchItemModel item) => item.toJson())
        .toList(growable: false),
    'right_items': rightItems
        .map((TestMatchItemModel item) => item.toJson())
        .toList(growable: false),
    'pairs': pairs
        .map((TestPairModel pair) => pair.toJson())
        .toList(growable: false),
    'sentences': sentences
        .map((TestSentenceModel sentence) => sentence.toJson())
        .toList(growable: false),
  };
}
