enum TestQuestionType {
  singleChoice('single_choice'),
  multiChoice('multi_choice'),
  mostCorrect('most_correct'),
  trueFalse('true_false'),
  fillBlanks('fill_blanks'),
  typedBlanks('typed_blanks'),
  matchPairs('match_pairs'),
  orderSentences('order_sentences');

  const TestQuestionType(this.key);

  final String key;

  bool get isMultiSelect => this == multiChoice;

  bool get usesWordBank => this == fillBlanks;

  bool get isTyped => this == typedBlanks;

  static TestQuestionType fromJson(Object? value) {
    final String key = (value ?? '').toString().toLowerCase().trim();

    return TestQuestionType.values.firstWhere(
      (TestQuestionType type) => type.key == key,
      orElse: () => TestQuestionType.singleChoice,
    );
  }
}
