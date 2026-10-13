import '../network/json_reader.dart';

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
