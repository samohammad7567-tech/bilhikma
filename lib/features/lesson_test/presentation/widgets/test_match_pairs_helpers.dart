import '../../data/models/test_answer_model.dart';
import '../../data/models/test_match_item_model.dart';
import '../../data/models/test_question_model.dart';

List<TestMatchItemModel> orderedRights(
  TestQuestionModel question,
  List<String> matchOrder,
) {
  if (matchOrder.isEmpty) return question.rightItems;

  final List<TestMatchItemModel> ordered = <TestMatchItemModel>[];

  for (final String rightId in matchOrder) {
    for (final TestMatchItemModel item in question.rightItems) {
      if (item.id == rightId) ordered.add(item);
    }
  }

  return ordered.length == question.rightItems.length
      ? ordered
      : question.rightItems;
}

int? leftBadge(
  TestQuestionModel question,
  TestAnswerModel answer,
  String leftId,
) {
  final int index = question.leftItems.indexWhere(
    (TestMatchItemModel item) => item.id == leftId,
  );
  if (index == -1) return null;

  final bool isMatched = answer.matches.values.any(
    (String value) => value == leftId,
  );

  return isMatched ? index + 1 : null;
}

int? rightBadge(
  TestQuestionModel question,
  TestAnswerModel answer,
  String rightId,
) {
  final String? leftId = answer.leftForRight(rightId);
  if (leftId == null) return null;

  final int index = question.leftItems.indexWhere(
    (TestMatchItemModel item) => item.id == leftId,
  );
  return index == -1 ? null : index + 1;
}
