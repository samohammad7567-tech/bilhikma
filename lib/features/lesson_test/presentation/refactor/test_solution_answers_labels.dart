part of 'test_solution_answers.dart';

String? _optionLabel(TestQuestionModel? question, String id) {
  if (question == null || id.isEmpty) return null;

  final String? option = question.optionById(id)?.label;
  if (option != null && option.trim().isNotEmpty) return option;

  for (final TestOptionModel word in question.wordBank) {
    if (word.id == id) return word.label;
  }

  for (final TestBlankModel blank in question.blanks) {
    for (final TestOptionModel choice in blank.choices) {
      if (choice.id == id) return choice.label;
    }
  }

  return null;
}

String? _optionImage(TestQuestionModel? question, String id) {
  if (question == null || id.isEmpty) return null;

  final String? option = question.optionById(id)?.imageUrl;
  if (option != null && option.trim().isNotEmpty) return option;

  for (final TestOptionModel word in question.wordBank) {
    if (word.id == id) return word.imageUrl;
  }

  for (final TestBlankModel blank in question.blanks) {
    for (final TestOptionModel choice in blank.choices) {
      if (choice.id == id) return choice.imageUrl;
    }
  }

  return null;
}
