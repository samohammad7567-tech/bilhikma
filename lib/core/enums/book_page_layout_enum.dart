import '../network/json_reader.dart';

/// How pages are laid out in the reader.
///
/// [single] renders one page at a time, which is what keeps a several hundred
/// page book responsive — [continuous] keeps neighbouring pages alive.
enum BookPageLayout {
  single('single'),
  continuous('continuous');

  const BookPageLayout(this.key);

  final String key;

  bool get isSingle => this == BookPageLayout.single;

  BookPageLayout get toggled =>
      isSingle ? BookPageLayout.continuous : BookPageLayout.single;

  static BookPageLayout fromJson(Object? value) {
    final String key = Json.asString(value).toLowerCase();

    return BookPageLayout.values.firstWhere(
      (BookPageLayout layout) => layout.key == key,
      orElse: () => BookPageLayout.single,
    );
  }
}
