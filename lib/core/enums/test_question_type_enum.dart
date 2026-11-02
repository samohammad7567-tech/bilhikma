enum TestQuestionType {
  singleChoice('mcq_single'),
  multiChoice('mcq_multiple'),
  trueFalse('true_false'),
  fillBlanks('fill_blank_choice'),
  typedBlanks('fill_blank_typed'),
  matchPairs('matching'),
  orderSentences('ordering'),
  @Deprecated('Legacy mock only; best_answer is mcq_single.')
  mostCorrect('most_correct');

  const TestQuestionType(this.key);

  final String key;

  bool get isMultiSelect => this == multiChoice;

  bool get usesWordBank => this == fillBlanks;

  bool get isTyped => this == typedBlanks;

  bool get isTrueFalse => this == trueFalse;

  bool get isOrdering => this == orderSentences;

  static TestQuestionType fromJson(Object? value) {
    final String key = (value ?? '').toString().toLowerCase().trim();

    final String normalized = switch (key) {
      'single_choice' => singleChoice.key,
      'multi_choice' => multiChoice.key,
      'fill_blanks' => fillBlanks.key,
      'typed_blanks' => typedBlanks.key,
      'match_pairs' => matchPairs.key,
      'order_sentences' => orderSentences.key,
      _ => key,
    };

    return TestQuestionType.values.firstWhere(
      (TestQuestionType type) => type.key == normalized,
      orElse: () => throw const FormatException('unsupported_question_type'),
    );
  }
}
