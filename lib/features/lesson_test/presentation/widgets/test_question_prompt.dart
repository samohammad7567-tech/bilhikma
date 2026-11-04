import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../core/utils/lesson_detail_formats.dart';
import 'test_question_media.dart';
import 'test_timer_chip.dart';

class TestQuestionPrompt extends StatelessWidget {
  const TestQuestionPrompt({
    required this.prompt,
    super.key,
    this.remaining,
    this.imageUrl,
    this.audioUrl,
  });

  final String prompt;

  final Duration? remaining;

  final String? imageUrl;
  final String? audioUrl;

  bool get _hasText => prompt.trim().isNotEmpty;

  bool get _hasMedia =>
      _present(imageUrl) != null || _present(audioUrl) != null;

  @override
  Widget build(BuildContext context) {
    final Duration? timeLeft = remaining;

    if (!_hasText && timeLeft == null && !_hasMedia) {
      return const SizedBox.shrink();
    }

    final bool hasHeader = _hasText || timeLeft != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (_hasText)
          _textRow(context, timeLeft)
        else if (timeLeft != null)
          _timerOnly(timeLeft),
        if (_hasMedia) ...<Widget>[
          if (hasHeader) SizedBox(height: 14.h),
          TestQuestionMedia(imageUrl: imageUrl, audioUrl: audioUrl),
        ],
      ],
    );
  }

  Widget _textRow(BuildContext context, Duration? timeLeft) {
    final Widget text = Text(
      prompt,
      textAlign: TextAlign.start,
      style: AppTheme.styles(context).labelStrong,
    );

    if (timeLeft == null) return text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: text),

        SizedBox(width: 10.w),

        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: _timer(timeLeft),
        ),
      ],
    );
  }

  Widget _timerOnly(Duration timeLeft) =>
      Align(alignment: AlignmentDirectional.centerEnd, child: _timer(timeLeft));

  Widget _timer(Duration timeLeft) => TestTimerChip(
    icon: Icons.access_time,
    label: LessonDetailFormats.clock(timeLeft),
  );

  String? _present(String? value) {
    final String text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
