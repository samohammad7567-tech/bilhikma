import '../../../../core/network/json_reader.dart';
import 'test_option_model.dart';

class TestBlankModel {
  const TestBlankModel({
    required this.id,
    this.blankIndex,
    this.placeholder,
    this.maxLength,
    this.scoreWeight,
    this.choices = const <TestOptionModel>[],
  });

  final String id;
  final int? blankIndex;
  final String? placeholder;
  final int? maxLength;
  final double? scoreWeight;
  final List<TestOptionModel> choices;

  factory TestBlankModel.fromJson(Map<String, dynamic> json) => TestBlankModel(
    id: Json.asString(json['id']),
    blankIndex: Json.asOptionalInt(json['blank_index']),
    placeholder: Json.asOptionalString(json['placeholder']),
    maxLength: Json.asOptionalInt(json['max_length']),
    scoreWeight: json['score_weight'] == null
        ? null
        : Json.asDouble(json['score_weight']),
    choices: Json.asMapList(
      json['choices'],
    ).map(TestOptionModel.fromJson).toList(growable: false),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'blank_index': blankIndex,
    'placeholder': placeholder,
    'max_length': maxLength,
    'score_weight': scoreWeight,
    'choices': choices
        .map((TestOptionModel choice) => choice.toJson())
        .toList(growable: false),
  };
}
