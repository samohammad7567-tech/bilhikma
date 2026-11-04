import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../../../core/themes/app_theme.dart';
import '../refactor/test_blank_segments.dart';
import 'test_blank_chip.dart';
import 'test_blank_text.dart';
import 'test_html_text.dart';

class TestBlankBodyText extends StatelessWidget {
  const TestBlankBodyText({
    required this.body,
    required this.valueOf,
    required this.onBlankTap,
    super.key,
    this.selectedBlankId,
  });

  final String? body;

  final String? Function(String blankId) valueOf;

  final ValueChanged<String> onBlankTap;
  final String? selectedBlankId;

  static final RegExp _placeholder = RegExp(r'\{\{([^{}]+)\}\}');

  @override
  Widget build(BuildContext context) {
    final String template = (body ?? '').trim();
    if (template.isEmpty) return const SizedBox.shrink();

    if (!TestHtmlText.hasMarkup(template)) {
      return TestBlankText(
        segments: TestBlankSegments.parse(template),
        valueOf: valueOf,
        onBlankTap: onBlankTap,
        selectedBlankId: selectedBlankId,
      );
    }

    final List<String> ids = <String>[];
    final String html = template.replaceAllMapped(_placeholder, (match) {
      final String id = match.group(1)!.trim();
      final int slot = ids.length;
      ids.add(id);
      return '<x-blank-$slot></x-blank-$slot>';
    });

    return HtmlWidget(
      '<div style="text-align: center">$html</div>',
      textStyle: AppTheme.styles(context).bodyMedium,
      rebuildTriggers: <Object?>[
        html,
        selectedBlankId,
        for (final String id in ids) valueOf(id),
      ],
      customStylesBuilder: (element) {
        if (element.localName == 'p' ||
            element.localName == 'div' ||
            element.localName == 'body') {
          return <String, String>{'margin': '0'};
        }
        return null;
      },
      customWidgetBuilder: (element) {
        final String name = element.localName ?? '';
        if (!name.startsWith('x-blank-')) return null;

        final int? slot = int.tryParse(name.substring('x-blank-'.length));
        if (slot == null || slot < 0 || slot >= ids.length) return null;

        final String blankId = ids[slot];
        return InlineCustomWidget(
          alignment: PlaceholderAlignment.middle,
          child: TestBlankChip(
            value: valueOf(blankId),
            isSelected: selectedBlankId == blankId,
            onTap: () => onBlankTap(blankId),
          ),
        );
      },
    );
  }
}
