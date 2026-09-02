import '../enums/content_type_enum.dart';
import '../enums/lessons_sort_enum.dart';

class LessonsFilter {
  const LessonsFilter({
    this.categorySubjectId,
    this.type,
    this.search,
    this.sort = LessonsSort.order,
    this.descending = false,
    this.page = 1,
    this.perPage = 15,
  });

  final int? categorySubjectId;

  final ContentType? type;

  final String? search;
  final LessonsSort sort;

  final bool descending;
  final int page;
  final int perPage;

  String get trimmedSearch => search?.trim() ?? '';

  LessonsFilter copyWith({
    int? categorySubjectId,
    ContentType? type,
    String? search,
    LessonsSort? sort,
    bool? descending,
    int? page,
    int? perPage,
    bool clearType = false,
    bool clearSubject = false,
    bool clearSearch = false,
  }) => LessonsFilter(
    categorySubjectId: clearSubject
        ? null
        : categorySubjectId ?? this.categorySubjectId,
    type: clearType ? null : type ?? this.type,
    search: clearSearch ? null : search ?? this.search,
    sort: sort ?? this.sort,
    descending: descending ?? this.descending,
    page: page ?? this.page,
    perPage: perPage ?? this.perPage,
  );

  LessonsFilter nextPage() => copyWith(page: page + 1);

  Map<String, dynamic> toQueryParameters() => <String, dynamic>{
    if (categorySubjectId != null)
      'filter[category_subject_id]': categorySubjectId,
    if (type != null) 'filter[type]': type!.key,
    if (trimmedSearch.isNotEmpty) 'search': trimmedSearch,
    'sort': '${descending ? '-' : ''}${sort.key}',
    'page': page,
    'per_page': perPage,
  };

  @override
  bool operator ==(Object other) =>
      other is LessonsFilter &&
      other.categorySubjectId == categorySubjectId &&
      other.type == type &&
      other.trimmedSearch == trimmedSearch &&
      other.sort == sort &&
      other.descending == descending &&
      other.page == page &&
      other.perPage == perPage;

  @override
  int get hashCode => Object.hash(
    categorySubjectId,
    type,
    trimmedSearch,
    sort,
    descending,
    page,
    perPage,
  );
}
