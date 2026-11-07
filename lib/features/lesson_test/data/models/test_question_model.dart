import '../../../../core/enums/blank_input_mode_enum.dart';
import '../../../../core/enums/test_question_type_enum.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/media_url.dart';
import 'question_timer_model.dart';
import 'test_blank_model.dart';
import 'test_match_item_model.dart';
import 'test_option_model.dart';
import 'test_sentence_model.dart';

class TestQuestionModel {
  const TestQuestionModel({
    required this.id,
    required this.type,
    required this.prompt,
    this.body,
    this.score = 0,
    this.timeLimit,
    this.initialTimer,
    this.isBestAnswer = false,
    this.maxSelections,
    this.allowsOneToManyMatching = false,
    this.blankInputMode,
    this.questionFormat = '',
    this.imageUrl,
    this.audioUrl,
    this.options = const <TestOptionModel>[],
    this.blanks = const <TestBlankModel>[],
    this.wordBank = const <TestOptionModel>[],
    this.leftItems = const <TestMatchItemModel>[],
    this.rightItems = const <TestMatchItemModel>[],
    this.sentences = const <TestSentenceModel>[],
  });

  final String id;
  final TestQuestionType type;

  final String prompt;
  final String? body;
  final double score;

  final String? imageUrl;
  final String? audioUrl;

  final Duration? timeLimit;
  final QuestionTimerModel? initialTimer;
  final bool isBestAnswer;
  final int? maxSelections;
  final bool allowsOneToManyMatching;
  final BlankInputMode? blankInputMode;
  final String questionFormat;

  final List<TestOptionModel> options;
  final List<TestBlankModel> blanks;
  final List<TestOptionModel> wordBank;
  final List<TestMatchItemModel> leftItems;
  final List<TestMatchItemModel> rightItems;
  final List<TestSentenceModel> sentences;

  int get effectiveMaxSelections =>
      maxSelections ?? (options.isEmpty ? 1 : options.length);

  static final RegExp _numberedBlankToken = RegExp(r'\{\{\s*\d+\s*\}\}');
  static final RegExp _anyBlankToken = RegExp(r'\{\{[^}]+\}\}');
  static final RegExp _extraSpaces = RegExp(r'\s+');

  bool get isBlankQuestion =>
      type == TestQuestionType.fillBlanks ||
      type == TestQuestionType.typedBlanks;

  bool get isRichPrompt {
    final String format = questionFormat.trim().toLowerCase();
    return format == 'rich' ||
        format == 'rich_text' ||
        format == 'richtext' ||
        format == 'markdown';
  }

  String get displayPrompt => prompt
      .replaceAll(_numberedBlankToken, ' ')
      .replaceAll(_extraSpaces, ' ')
      .trim();

  bool get shouldShowPrompt {
    final String text = displayPrompt;
    if (text.isEmpty) return false;
    if (!isBlankQuestion) return true;

    final String sentence = (body ?? '')
        .replaceAll(_anyBlankToken, ' ')
        .replaceAll(_extraSpaces, ' ')
        .trim();

    return text != sentence;
  }

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
    final Map<String, dynamic> options = Json.asMap(json['options']);
    final Map<String, dynamic> details = Json.asMap(options['details']);

    final TestQuestionType type = TestQuestionType.fromJson(
      json['question_type'],
    );

    final String questionFormat = Json.asString(
      options['question_format'] ??
          details['question_format'] ??
          json['question_format'] ??
          json['text_format'] ??
          json['content_format'],
    ).trim();

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
      imageUrl: MediaUrl.resolve(
        Json.asOptionalString(
          options['image_path'] ??
              details['image_path'] ??
              json['image_path'] ??
              json['image_url'],
        ),
      ),
      audioUrl: MediaUrl.resolve(
        Json.asOptionalString(
          options['audio_path'] ??
              details['audio_path'] ??
              json['audio_path'] ??
              json['audio_url'],
        ),
      ),
      timeLimit: Json.asDuration(
        options['default_time_seconds'] ?? json['default_time_seconds'],
      ),
      initialTimer: json['timer'] == null
          ? null
          : QuestionTimerModel.fromJson(Json.asMap(json['timer'])),
      isBestAnswer:
          Json.asOptionalString(details['choice_variant']) == 'best_answer',
      maxSelections: Json.asOptionalInt(details['max_selections']),
      allowsOneToManyMatching: Json.asBool(
        details['allow_one_to_many_matching'],
      ),
      blankInputMode: details['blank_input_mode'] == null
          ? null
          : BlankInputMode.fromJson(details['blank_input_mode']),
      questionFormat: questionFormat,
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
    'image_url': imageUrl,
    'audio_url': audioUrl,
    'time_limit': timeLimit?.inSeconds,
    'timer': initialTimer?.toJson(),
    'is_best_answer': isBestAnswer,
    'max_selections': maxSelections,
    'allow_one_to_many_matching': allowsOneToManyMatching,
    'blank_input_mode': blankInputMode?.key,
    'question_format': questionFormat,
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
    'sentences': sentences
        .map((TestSentenceModel sentence) => sentence.toJson())
        .toList(growable: false),
  };
}
