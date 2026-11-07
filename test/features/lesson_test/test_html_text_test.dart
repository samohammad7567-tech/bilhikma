import 'package:bilhikma/features/lesson_test/presentation/widgets/test_blank_body_text.dart';
import 'package:bilhikma/features/lesson_test/presentation/widgets/test_blank_chip.dart';
import 'package:bilhikma/features/lesson_test/presentation/widgets/test_html_text.dart';
import 'package:bilhikma/features/lesson_test/presentation/widgets/test_rich_prompt.dart';
import 'package:bilhikma/features/lesson_test/presentation/widgets/test_word_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (BuildContext context, Widget? _) =>
        MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('renders html instead of showing literal tags', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const TestHtmlText(
          '<p>14 - اختر <strong>الجواب الصحيح</strong><br>سطر ثانٍ</p>',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );

    final String plainText = _plainText(tester);

    expect(plainText, contains('14 - اختر'));
    expect(plainText, contains('الجواب الصحيح'));
    expect(plainText, contains('سطر ثانٍ'));
    expect(plainText, isNot(contains('<p>')));
    expect(plainText, isNot(contains('<strong>')));
    expect(_hasBoldSpan(tester), isTrue);
  });

  testWidgets('renders a blank chip inside html', (WidgetTester tester) async {
    String? tapped;

    await tester.pumpWidget(
      _host(
        TestBlankBodyText(
          body: '<p>Fill {{blank-1}} now</p>',
          valueOf: (_) => null,
          onBlankTap: (String blankId) => tapped = blankId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TestBlankChip), findsOneWidget);
    expect(_plainText(tester), isNot(contains('{{blank-1}}')));
    expect(_plainText(tester), isNot(contains('<p>')));

    await tester.tap(find.byType(TestBlankChip));
    expect(tapped, 'blank-1');
  });

  testWidgets('renders html inside a word chip without expanding it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        Wrap(
          children: <Widget>[
            TestWordChip(
              label: '<strong>word</strong>',
              isUsed: false,
              onTap: _noop,
            ),
          ],
        ),
      ),
    );

    expect(_plainText(tester), contains('word'));
    expect(_plainText(tester), isNot(contains('<strong>')));
    expect(tester.getSize(find.byType(TestWordChip)).width, lessThan(300));
  });

  testWidgets('renders rich markers without showing them literally', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const TestRichPrompt(
          'Read **this** then ﴿verse﴾',
          rich: true,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final String plainText = _plainText(tester);

    expect(plainText, contains('Read'));
    expect(plainText, contains('this'));
    expect(plainText, contains('verse'));
    expect(plainText, isNot(contains('**')));
    expect(plainText, isNot(contains('﴿')));
    expect(_hasBoldSpan(tester), isTrue);
  });

  testWidgets('renders markdown markers inside html prompts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const TestRichPrompt(
          '<p>Read <strong>this</strong></p><p>**and** ﴿verse﴾</p>',
          rich: true,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final String plainText = _plainText(tester);

    expect(plainText, contains('Read'));
    expect(plainText, contains('and'));
    expect(plainText, contains('verse'));
    expect(plainText, isNot(contains('**')));
    expect(plainText, isNot(contains('﴿')));
    expect(plainText, isNot(contains('<p>')));
  });
}

void _noop() {}

String _plainText(WidgetTester tester) => tester
    .widgetList<RichText>(find.byType(RichText))
    .map((RichText widget) => widget.text.toPlainText())
    .join(' ');

bool _hasBoldSpan(WidgetTester tester) {
  bool bold = false;

  for (final RichText widget in tester.widgetList<RichText>(
    find.byType(RichText),
  )) {
    widget.text.visitChildren((InlineSpan span) {
      final FontWeight? weight = span.style?.fontWeight;
      if (weight == FontWeight.bold || weight == FontWeight.w700) bold = true;
      return !bold;
    });
    if (bold) return true;
  }

  return false;
}
