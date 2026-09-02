import 'json_reader.dart';

class PaginationMeta {
  const PaginationMeta({
    this.count = 0,
    this.currentPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  final int count;
  final int currentPage;
  final int perPage;

  final int total;

  int get lastPage =>
      perPage <= 0 ? 1 : (total / perPage).ceil().clamp(1, 1 << 30);

  bool get hasMore => currentPage < lastPage;

  int get nextPage => currentPage + 1;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
    count: Json.asInt(json['count']),
    currentPage: Json.asOptionalInt(json['current_page']) ?? 1,
    perPage: Json.asOptionalInt(json['per_page']) ?? 15,
    total: Json.asInt(json['total']),
  );

  factory PaginationMeta.fromData(Map<String, dynamic> data) {
    final Map<String, dynamic> meta = Json.asMap(data['meta']);
    return PaginationMeta.fromJson(Json.asMap(meta['pagination']));
  }
}
