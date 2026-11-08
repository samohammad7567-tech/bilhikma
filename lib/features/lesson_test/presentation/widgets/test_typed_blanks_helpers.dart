import 'package:flutter/widgets.dart';

import '../../data/models/test_answer_model.dart';
import '../../data/models/test_question_model.dart';

int? blankMaxLength(TestQuestionModel question, String blankId) {
  for (final blank in question.blanks) {
    if (blank.id == blankId) return blank.maxLength;
  }
  return null;
}

TextEditingController blankController(
  Map<String, TextEditingController> controllers,
  TestAnswerModel answer,
  String blankId,
) {
  final String value = answer.blankValue(blankId) ?? '';

  final TextEditingController controller = controllers.putIfAbsent(
    blankId,
    () => TextEditingController(text: value),
  );

  if (controller.text != value) {
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  return controller;
}
