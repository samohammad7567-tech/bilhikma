import 'json_reader.dart';
import 'pagination_meta.dart';

class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    this.meta = const PaginationMeta(),
  });

  final List<T> items;
  final PaginationMeta meta;

  bool get isEmpty => items.isEmpty;
  bool get hasMore => meta.hasMore;

  const PaginatedResult.empty()
    : items = const <Never>[],
      meta = const PaginationMeta();

  factory PaginatedResult.fromData(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic> json) parse,
  ) => PaginatedResult<T>(
    items: Json.asList<T>(data['items'], parse),
    meta: PaginationMeta.fromData(data),
  );

  factory PaginatedResult.fromDynamic(
    Object? data,
    T Function(Map<String, dynamic> json) parse,
  ) {
    if (data is List) {
      return PaginatedResult<T>(items: Json.asList<T>(data, parse));
    }

    return PaginatedResult<T>.fromData(Json.asMap(data), parse);
  }
}
