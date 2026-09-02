class TestBlankSegment {
  const TestBlankSegment.text(this.text) : blankId = null;

  const TestBlankSegment.blank(String this.blankId) : text = '';

  final String text;
  final String? blankId;

  bool get isBlank => blankId != null;
}

class TestBlankSegments {
  TestBlankSegments._();

  static final RegExp _placeholder = RegExp(r'\{\{([^{}]+)\}\}');

  static List<TestBlankSegment> parse(String? body) {
    final String template = (body ?? '').trim();
    if (template.isEmpty) return const <TestBlankSegment>[];

    final List<TestBlankSegment> segments = <TestBlankSegment>[];
    int cursor = 0;

    for (final RegExpMatch match in _placeholder.allMatches(template)) {
      if (match.start > cursor) {
        segments.add(
          TestBlankSegment.text(template.substring(cursor, match.start)),
        );
      }

      segments.add(TestBlankSegment.blank(match.group(1)!.trim()));
      cursor = match.end;
    }

    if (cursor < template.length) {
      segments.add(TestBlankSegment.text(template.substring(cursor)));
    }

    return segments;
  }

  static List<TestBlankSegment> asWords(List<TestBlankSegment> segments) {
    final List<TestBlankSegment> words = <TestBlankSegment>[];

    for (final TestBlankSegment segment in segments) {
      if (segment.isBlank) {
        words.add(segment);
        continue;
      }

      for (final String word in segment.text.split(RegExp(r'\s+'))) {
        if (word.isNotEmpty) words.add(TestBlankSegment.text(word));
      }
    }

    return words;
  }
}
