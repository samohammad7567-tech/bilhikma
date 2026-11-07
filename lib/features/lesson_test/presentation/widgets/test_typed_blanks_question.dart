import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/test_answer_model.dart';
import '../../data/models/test_blank_model.dart';
import '../../data/models/test_question_model.dart';
import 'test_blank_body_text.dart';
import 'test_question_prompt.dart';

class TestTypedBlanksQuestion extends StatefulWidget {
  const TestTypedBlanksQuestion({
    required this.question,
    required this.answer,
    required this.onBlankTap,
    required this.onTyped,
    super.key,
    this.selectedBlankId,
    this.questionRemaining,
  });

  final TestQuestionModel question;
  final TestAnswerModel answer;

  final ValueChanged<String> onBlankTap;
  final void Function({required String blankId, required String value}) onTyped;

  final String? selectedBlankId;
  final Duration? questionRemaining;

  @override
  State<TestTypedBlanksQuestion> createState() =>
      _TestTypedBlanksQuestionState();
}

class _TestTypedBlanksQuestionState extends State<TestTypedBlanksQuestion> {
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _focusInput() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _focusNode.hasFocus) return;
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? activeBlankId = _activeBlankId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TestQuestionPrompt(
          prompt: widget.question.shouldShowPrompt
              ? widget.question.displayPrompt
              : '',
          remaining: widget.questionRemaining,
          imageUrl: widget.question.imageUrl,
          audioUrl: widget.question.audioUrl,
          rich: widget.question.isRichPrompt,
        ),

        SizedBox(height: 20.h),

        TestBlankBodyText(
          body: widget.question.body,
          valueOf: widget.answer.blankValue,
          onBlankTap: (String blankId) {
            widget.onBlankTap(blankId);
            _focusInput();
          },
          selectedBlankId: activeBlankId,
        ),

        if (activeBlankId != null) ...<Widget>[
          SizedBox(height: 28.h),

          CustomTextField(
            controller: _controllerFor(activeBlankId),
            focusNode: _focusNode,
            filled: true,
            maxLines: 3,
            maxLength: _maxLengthOf(activeBlankId),
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

  int? _maxLengthOf(String blankId) {
    for (final TestBlankModel blank in widget.question.blanks) {
      if (blank.id == blankId) return blank.maxLength;
    }
    return null;
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
