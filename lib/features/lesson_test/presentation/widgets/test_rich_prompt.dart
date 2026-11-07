import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'test_html_text.dart';

class TestRichPrompt extends StatelessWidget {
  const TestRichPrompt(
    this.text, {
    super.key,
    this.rich = false,
    this.style,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final bool rich;
  final TextStyle? style;
  final TextAlign textAlign;

  static final RegExp _markers = RegExp(
    r'\*\*(.+?)\*\*|﴿([^﴾]*)﴾',
    dotAll: true,
  );

  static bool hasRichMarkup(String value) => _markers.hasMatch(value);

  @override
  Widget build(BuildContext context) {
    final String value = text.trim();
    if (value.isEmpty) return const SizedBox.shrink();

    final TextStyle baseStyle = style ?? DefaultTextStyle.of(context).style;

    if (!rich || !hasRichMarkup(value)) {
      return TestHtmlText(value, style: baseStyle, textAlign: textAlign);
    }

    if (TestHtmlText.hasMarkup(value)) {
      return _html(value, baseStyle);
    }

    return Text.rich(
      TextSpan(children: _spans(context, value, baseStyle)),
      textAlign: textAlign,
      style: baseStyle,
    );
  }

  Widget _html(String value, TextStyle style) {
    final String html = value.replaceAllMapped(
      _markers,
      (Match match) => match.group(1) != null
          ? '<strong>${match.group(1)}</strong>'
          : '<span class="quiz-quran">${match.group(2)}</span>',
    );

    return HtmlWidget(
      html,
      textStyle: style,
      customStylesBuilder: (element) {
        if (element.attributes['class']?.contains('quiz-quran') ?? false) {
          return <String, String>{'font-style': 'italic', 'font-weight': '600'};
        }
        return null;
      },
    );
  }

  List<InlineSpan> _spans(
    BuildContext context,
    String value,
    TextStyle baseStyle,
  ) {
    final List<InlineSpan> spans = <InlineSpan>[];
    final TextStyle quranStyle = baseStyle.copyWith(
      color: Theme.of(context).colorScheme.secondary,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w600,
    );

    int cursor = 0;

    for (final RegExpMatch match in _markers.allMatches(value)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: value.substring(cursor, match.start)));
      }

      final String? bold = match.group(1);
      final String? quran = match.group(2);

      if (bold != null) {
        spans.add(
          TextSpan(
            text: bold,
            style: baseStyle.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      } else if (quran != null) {
        spans.add(TextSpan(text: quran, style: quranStyle));
      }

      cursor = match.end;
    }

    if (cursor < value.length) {
      spans.add(TextSpan(text: value.substring(cursor)));
    }

    return spans;
  }
}
