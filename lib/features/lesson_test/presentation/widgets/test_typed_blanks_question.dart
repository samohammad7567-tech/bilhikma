import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/test_answer_model.dart';
import '../../data/models/test_blank_model.dart';
import '../../data/models/test_question_model.dart';
import '../refactor/test_blank_segments.dart';
import 'test_blank_text.dart';
import 'test_question_prompt.dart';

class TestTypedBlanksQuestion extends StatefulWidget {
  const TestTypedBlanksQuestion({
    required this.question,
    required this.answer,
    required this.onBlankTap,
    required this.onTyped,
    super.key,
    this.selectedBlankId,
  });

  final TestQuestionModel question;
  final TestAnswerModel answer;

  final ValueChanged<String> onBlankTap;
  final void Function({required String blankId, required String value}) onTyped;

  final String? selectedBlankId;

  @override
  State<TestTypedBlanksQuestion> createState() =>
      _TestTypedBlanksQuestionState();
}

class _TestTypedBlanksQuestionState extends State<TestTypedBlanksQuestion> {
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? activeBlankId = _activeBlankId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TestQuestionPrompt(prompt: widget.question.prompt),

        SizedBox(height: 20.h),

        TestBlankText(
          segments: TestBlankSegments.parse(widget.question.body),
          valueOf: widget.answer.blankValue,
          onBlankTap: widget.onBlankTap,
          selectedBlankId: activeBlankId,
        ),

        if (activeBlankId != null) ...<Widget>[
          SizedBox(height: 28.h),

          CustomTextField(
            controller: _controllerFor(activeBlankId),
            filled: true,
            maxLines: 3,
            hintText: 'type_your_answer'.tr(),
            onChanged: (String? value) {
              widget.onTyped(blankId: activeBlankId, value: value ?? '');
              return null;
            },
          ),
        ],
      ],
    );
  }

  String? get _activeBlankId {
    final String? selected = widget.selectedBlankId;
    if (selected != null) return selected;

    final List<TestBlankModel> blanks = widget.question.blanks;
    return blanks.isEmpty ? null : blanks.first.id;
  }

  TextEditingController _controllerFor(String blankId) {
    final String value = widget.answer.blankValue(blankId) ?? '';

    final TextEditingController controller = _controllers.putIfAbsent(
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
}
