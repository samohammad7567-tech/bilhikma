import 'pathway_term_model.dart';

class PathwayLevelModel {
  const PathwayLevelModel({
    required this.categoryId,
    this.name = '',
    this.terms = const <PathwayTermModel>[],
  });

  final int categoryId;
  final String name;
  final List<PathwayTermModel> terms;

  String get id => '$categoryId';

  List<PathwayTermModel> get offerableTerms => <PathwayTermModel>[
    for (final PathwayTermModel term in terms)
      if (term.isOfferable) term,
  ];

  PathwayTermModel? termById(String? termId) {
    for (final PathwayTermModel term in terms) {
      if (term.id == termId) return term;
    }
    return null;
  }
}
