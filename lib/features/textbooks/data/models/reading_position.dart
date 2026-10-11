import '../../../../core/network/json_reader.dart';

/// Where the reader left a document, so reopening it resumes in place.
class ReadingPosition {
  const ReadingPosition({
    required this.page,
    this.pageCount = 0,
    this.zoom = 1,
    this.updatedAt,
  });

  final int page;
  final int pageCount;
  final double zoom;
  final DateTime? updatedAt;

  static const ReadingPosition start = ReadingPosition(page: 1);

  /// Page 1 is where an unread document opens anyway — nothing to restore.
  bool get isResumable => page > 1;

  int get millisSinceEpoch => updatedAt?.millisecondsSinceEpoch ?? 0;

  /// Clamped so a position saved before a file was replaced by a shorter one
  /// cannot open the viewer past its last page.
  int pageWithin(int totalPages) {
    if (totalPages <= 0) return page < 1 ? 1 : page;

    return page.clamp(1, totalPages);
  }

  ReadingPosition copyWith({int? page, int? pageCount, double? zoom}) =>
      ReadingPosition(
        page: page ?? this.page,
        pageCount: pageCount ?? this.pageCount,
        zoom: zoom ?? this.zoom,
        updatedAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'page': page,
    'page_count': pageCount,
    'zoom': zoom,
    'updated_at': millisSinceEpoch,
  };

  /// Caps zoom at the viewer's own maximum: a stored value outside the
  /// allowed range opens the document at an unusable scale.
  static const double minZoom = 1;
  static const double maxZoom = 3;

  factory ReadingPosition.fromJson(Map<String, dynamic> json) {
    final int stamp = Json.asInt(json['updated_at']);
    final double stored = Json.asDouble(json['zoom']);

    return ReadingPosition(
      page: Json.asInt(json['page']),
      pageCount: Json.asInt(json['page_count']),
      zoom: stored.clamp(minZoom, maxZoom),
      updatedAt: stamp > 0 ? DateTime.fromMillisecondsSinceEpoch(stamp) : null,
    );
  }
}
