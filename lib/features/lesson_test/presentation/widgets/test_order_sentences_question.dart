import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/test_answer_model.dart';
import '../../data/models/test_question_model.dart';
import '../../data/models/test_sentence_model.dart';
import 'test_question_prompt.dart';
import 'test_sentence_tile.dart';

class TestOrderSentencesQuestion extends StatelessWidget {
  const TestOrderSentencesQuestion({
    required this.question,
    required this.answer,
    required this.onReorder,
    super.key,
    this.questionRemaining,
  });

  final TestQuestionModel question;
  final TestAnswerModel answer;

  final Duration? questionRemaining;

  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final List<TestSentenceModel> sentences = _arranged;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TestQuestionPrompt(
          prompt: question.prompt,
          remaining: questionRemaining,
          imageUrl: question.imageUrl,
          audioUrl: question.audioUrl,
          rich: question.isRichPrompt,
        ),

        SizedBox(height: 18.h),

        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: sentences.length,
          onReorderItem: onReorder,

          proxyDecorator:
              (Widget child, int index, Animation<double> animation) =>
                  Material(color: Colors.transparent, child: child),
          itemBuilder: (BuildContext context, int index) {
            final TestSentenceModel sentence = sentences[index];

            return Padding(
              key: ValueKey<String>(sentence.id),
              padding: EdgeInsets.only(bottom: 10.h),
              child: TestSentenceTile(
                text: sentence.text,
                index: index,
                imageUrl: sentence.imageUrl,
                audioUrl: sentence.audioUrl,
              ),
            );
          },
        ),
      ],
    );
  }

  List<TestSentenceModel> get _arranged {
    if (answer.order.isEmpty) return question.sentences;

    final List<TestSentenceModel> arranged = <TestSentenceModel>[];

    for (final String sentenceId in answer.order) {
      for (final TestSentenceModel sentence in question.sentences) {
        if (sentence.id == sentenceId) arranged.add(sentence);
      }
    }

    return arranged.length == question.sentences.length
        ? arranged
        : question.sentences;
  }
}
