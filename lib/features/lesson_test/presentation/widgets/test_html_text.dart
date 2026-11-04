import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class TestHtmlText extends StatelessWidget {
  const TestHtmlText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  final String text;

  final TextStyle? style;

  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  static final RegExp _tag = RegExp(r'</?[a-zA-Z][^>]*>');
  static final RegExp _entity = RegExp(
    r'&(?:[a-zA-Z][a-zA-Z0-9]*|#\d+|#x[0-9a-fA-F]+);',
  );

  static bool hasMarkup(String value) =>
      _tag.hasMatch(value) || _entity.hasMatch(value);

  @override
  Widget build(BuildContext context) {
    final String value = text.trim();
    if (value.isEmpty) return const SizedBox.shrink();

    final TextStyle textStyle = style ?? DefaultTextStyle.of(context).style;

    if (!hasMarkup(value)) {
      return Text(
        value,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: textStyle,
      );
    }

    return HtmlWidget(
      textAlign == TextAlign.center
          ? '<div style="text-align: center">$value</div>'
          : value,
      textStyle: textStyle,
      customStylesBuilder: (element) {
        if (element.localName == 'p' ||
            element.localName == 'div' ||
            element.localName == 'body') {
          return <String, String>{'margin': '0'};
        }
        return null;
      },
    );
  }
}
