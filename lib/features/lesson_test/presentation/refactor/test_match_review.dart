import '../../../../core/utils/media_url.dart';
import '../../data/models/quiz_question_result_model.dart';
import '../../data/models/test_match_item_model.dart';
import '../../data/models/test_question_model.dart';
import 'quiz_review_answer.dart';

class TestMatchReview {
  TestMatchReview._();

  static List<QuizReviewAnswer> solutionItems(
    QuizQuestionResultModel result, {
    TestQuestionModel? question,
  }) {
    final _MatchResolver resolver = _MatchResolver(result, question);
    final Map<Object?, Object?> details = _details(result);
    final List<QuizReviewAnswer> items = <QuizReviewAnswer>[];

    void add(_MatchPair pair) {
      if (!pair.isComplete) return;

      final QuizReviewAnswer answer = pair.toAnswer();
      if (answer.isEmpty) return;

      items.add(answer);
    }

    final Object? rawPairs = details['pairs'];

    if (rawPairs is List) {
      for (final Map pair in rawPairs.whereType<Map>()) {
        if (_truthy(pair['is_distractor'])) continue;
        add(_pairOf(pair, resolver));
      }
    }

    if (items.isEmpty) {
      final List<Object?> mappings = <Object?>[
        details['matches'],
        details['correct_matches'],
        details['pairs_map'],
        details['map'],
        details['matching'],
        if (rawPairs is Map && !_isItemDefinitionMap(rawPairs)) rawPairs,
      ];

      for (final Object? mapping in mappings) {
        if (mapping is! Map) continue;
        for (final MapEntry<Object?, Object?> entry in mapping.entries) {
          add(resolver.mappingOf(entry.key, entry.value));
        }
        if (items.isNotEmpty) break;
      }
    }

    if (items.isEmpty) {
      _consumePairs(result.componentResults, add, resolver);
    }

    return items;
  }

  static List<QuizReviewAnswer> givenItems(
    QuizQuestionResultModel result, {
    TestQuestionModel? question,
  }) {
    final _MatchResolver resolver = _MatchResolver(result, question);
    final List<QuizReviewAnswer> items = <QuizReviewAnswer>[];

    void add(_MatchPair pair) {
      if (!pair.isComplete) return;

      final QuizReviewAnswer answer = pair.toAnswer();
      if (answer.isEmpty) return;

      items.add(answer);
    }

    final Object? given =
        result.givenAnswer['matches'] ??
        result.givenAnswer['pairs'] ??
        result.givenAnswer['map'] ??
        result.givenAnswer['matching'];

    _consumePairs(given, add, resolver);

    if (items.isEmpty) {
      _consumePairs(result.componentResults, add, resolver);
    }

    return items;
  }

  static void _consumePairs(
    Object? value,
    void Function(_MatchPair pair) add,
    _MatchResolver resolver,
  ) {
    if (value is List) {
      for (final Map pair in value.whereType<Map>()) {
        add(_pairOf(pair, resolver));
      }
      return;
    }

    if (value is! Map) return;

    for (final MapEntry<Object?, Object?> entry in value.entries) {
      final Object? entryValue = entry.value;

      if (entryValue is Map && _hasPairKeys(entryValue)) {
        final Map<String, dynamic> pair = Map<String, dynamic>.from(entryValue);
        pair['right_id'] ??= entry.key;
        add(_pairOf(pair, resolver));
        continue;
      }

      add(resolver.mappingOf(entry.key, entryValue));
    }
  }

  static _MatchPair _pairOf(Map pair, _MatchResolver resolver) {
    final Map? leftItem = pair['left'] is Map ? pair['left'] as Map : null;
    final Map? rightItem = pair['right'] is Map ? pair['right'] as Map : null;

    final String leftId = _idOf(pair['left_id'] ?? pair['id'] ?? pair['left']);
    final String rightId = _idOf(pair['right_id'] ?? pair['right']);

    return _MatchPair(
      left: resolver.leftSide(
        id: leftId,
        text:
            pair['left_text'] ??
            pair['left_label'] ??
            pair['source_text'] ??
            leftItem?['text'] ??
            leftItem?['label'] ??
            pair['source'],
        image:
            pair['left_image_path'] ??
            pair['left_image'] ??
            pair['source_image_path'] ??
            leftItem?['image_path'] ??
            leftItem?['image'] ??
            pair['source_image'],
      ),
      right: resolver.rightSide(
        id: rightId,
        text:
            pair['right_text'] ??
            pair['right_label'] ??
            pair['target_text'] ??
            rightItem?['text'] ??
            rightItem?['label'] ??
            pair['target'],
        image:
            pair['right_image_path'] ??
            pair['right_image'] ??
            pair['target_image_path'] ??
            rightItem?['image_path'] ??
            rightItem?['image'] ??
            pair['target_image'],
      ),
    );
  }
}

class _MatchResolver {
  _MatchResolver(QuizQuestionResultModel result, TestQuestionModel? question) {
    _index(question?.leftItems, result.options, _left, 'left');
    _index(question?.rightItems, result.options, _right, 'right');
    _indexSolutionPairs(result);
  }

  final Map<String, TestMatchItemModel> _left = <String, TestMatchItemModel>{};
  final Map<String, TestMatchItemModel> _right = <String, TestMatchItemModel>{};

  _MatchSide leftSide({String id = '', Object? text, Object? image}) =>
      _side(_left, id, text, image);

  _MatchSide rightSide({String id = '', Object? text, Object? image}) =>
      _side(_right, id, text, image);

  _MatchPair mappingOf(Object? first, Object? second) {
    final String firstId = _idOf(first);
    final String secondId = _idOf(second);

    if (_left.containsKey(firstId) && _right.containsKey(secondId)) {
      return _MatchPair(
        left: leftSide(id: firstId),
        right: rightSide(id: secondId),
      );
    }

    return _MatchPair(
      left: leftSide(id: secondId),
      right: rightSide(id: firstId),
    );
  }

  _MatchSide _side(
    Map<String, TestMatchItemModel> index,
    String id,
    Object? text,
    Object? image,
  ) {
    final TestMatchItemModel? item = index[id.trim()];

    return _MatchSide(
      text: _firstText(<Object?>[text, item?.text]),
      imageUrl: MediaUrl.resolve(
        _firstText(<Object?>[image, item?.imageUrl]),
      ),
    );
  }

  void _index(
    List<TestMatchItemModel>? items,
    Map<String, dynamic> options,
    Map<String, TestMatchItemModel> target,
    String side,
  ) {
    for (final TestMatchItemModel item in items ?? const <TestMatchItemModel>[]) {
      target[item.id] = item;
    }

    final Map<String, dynamic>? details = _asMap(options['details']);
    final Map<String, dynamic>? pairs = _asMap(
      (details ?? options)['pairs'],
    );
    final Object? raw = pairs?[side];
    if (raw is! List) return;

    for (final Object? entry in raw) {
      if (entry is! Map) continue;

      final TestMatchItemModel item = TestMatchItemModel.fromJson(
        Map<String, dynamic>.from(entry),
      );
      target.putIfAbsent(item.id, () => item);
    }
  }

  void _indexSolutionPairs(QuizQuestionResultModel result) {
    final Object? pairs = _details(result)['pairs'];
    if (pairs is! List) return;

    for (final Map pair in pairs.whereType<Map>()) {
      if (_truthy(pair['is_distractor'])) continue;

      _indexSolutionSide(pair, 'left', _left);
      _indexSolutionSide(pair, 'right', _right);
    }
  }

  void _indexSolutionSide(
    Map pair,
    String side,
    Map<String, TestMatchItemModel> target,
  ) {
    final Object? nested = pair[side];
    final Map nestedItem = nested is Map ? nested : const <Object?, Object>{};

    final String id = _idOf(
      pair['${side}_id'] ?? (side == 'left' ? pair['id'] : null) ?? nested,
    );
    if (id.isEmpty) return;

    final String text = _firstText(<Object?>[
      pair['${side}_text'],
      pair['${side}_label'],
      nestedItem['text'],
      nestedItem['label'],
    ]);
    final String image = _firstText(<Object?>[
      pair['${side}_image_path'],
      pair['${side}_image'],
      nestedItem['image_path'],
      nestedItem['image'],
    ]);

    target.putIfAbsent(
      id,
      () => TestMatchItemModel(
        id: id,
        text: text,
        imageUrl: image.isEmpty ? null : MediaUrl.resolve(image),
      ),
    );
  }
}

class _MatchSide {
  const _MatchSide({this.text = '', this.imageUrl});

  final String text;
  final String? imageUrl;

  bool get isPresent =>
      text.trim().isNotEmpty || (imageUrl?.trim().isNotEmpty ?? false);
}

class _MatchPair {
  const _MatchPair({required this.left, required this.right});

  final _MatchSide left;
  final _MatchSide right;

  bool get isComplete => left.isPresent && right.isPresent;

  QuizReviewAnswer toAnswer() => QuizReviewAnswer.pair(
    text: _label(left.text, right.text),
    images: <String?>[left.imageUrl, right.imageUrl],
  );
}

Map<Object?, Object?> _details(QuizQuestionResultModel result) {
  final Map<String, dynamic>? solution = result.solution;
  if (solution == null) return const <Object?, Object?>{};

  final Object? details = solution['details'];
  if (details is Map) return details;

  return solution;
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is! Map) return null;

  return Map<String, dynamic>.from(value);
}

String _idOf(Object? value) {
  if (value == null) return '';
  if (value is Map) {
    return _idOf(
      value['id'] ??
          value['left_id'] ??
          value['right_id'] ??
          value['text'] ??
          value['label'],
    );
  }
  if (value is List) return '';

  return value.toString().trim();
}

String _firstText(Iterable<Object?> values) {
  for (final Object? value in values) {
    if (value is Map || value is List) continue;

    final String text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }

  return '';
}

bool _truthy(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;

  final String text = value?.toString().trim().toLowerCase() ?? '';
  return text == 'true' || text == '1';
}

String _label(String left, String right) {
  final String source = left.trim();
  final String target = right.trim();

  if (source.isEmpty) return target;
  if (target.isEmpty) return source;

  return '$source → $target';
}

bool _isItemDefinitionMap(Map map) =>
    map['left'] is List || map['right'] is List;

bool _hasPairKeys(Map pair) {
  const List<String> keys = <String>[
    'left_id',
    'right_id',
    'left',
    'right',
    'left_text',
    'right_text',
    'source',
    'target',
  ];

  return keys.any(pair.containsKey);
}
