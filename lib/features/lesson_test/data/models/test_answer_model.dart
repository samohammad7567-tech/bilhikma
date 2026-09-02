class TestAnswerModel {
  const TestAnswerModel({
    this.optionIds = const <String>[],
    this.blanks = const <String, String>{},
    this.pairs = const <String, String>{},
    this.order = const <String>[],
  });

  final List<String> optionIds;

  final Map<String, String> blanks;

  final Map<String, String> pairs;

  final List<String> order;

  String? blankValue(String blankId) => blanks[blankId];

  String? matchOf(String pairId) => pairs[pairId];

  bool usesOption(String optionId) =>
      optionIds.contains(optionId) || blanks.containsValue(optionId);

  TestAnswerModel copyWith({
    List<String>? optionIds,
    Map<String, String>? blanks,
    Map<String, String>? pairs,
    List<String>? order,
  }) => TestAnswerModel(
    optionIds: optionIds ?? this.optionIds,
    blanks: blanks ?? this.blanks,
    pairs: pairs ?? this.pairs,
    order: order ?? this.order,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'option_ids': optionIds,
    'blanks': blanks,
    'pairs': pairs,
    'order': order,
  };
}
