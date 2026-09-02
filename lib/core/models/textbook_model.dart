import '../network/json_reader.dart';

class TextbookModel {
  const TextbookModel({
    required this.id,
    required this.title,
    this.categorySubjectId,
    this.version,
    this.fileSize = 0,
    this.pageCount = 0,
    this.isCurrent = true,
  });

  final int id;
  final String title;

  final int? categorySubjectId;
  final String? version;

  final int fileSize;
  final int pageCount;

  final bool isCurrent;

  String get readableSize {
    if (fileSize <= 0) return '';
    const List<String> units = <String>['B', 'KB', 'MB', 'GB'];

    double size = fileSize.toDouble();
    int unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }

    return '${size.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
  }

  factory TextbookModel.fromJson(Map<String, dynamic> json) => TextbookModel(
    id: Json.asInt(json['id']),
    title: Json.asString(json['title']),
    categorySubjectId: Json.asOptionalInt(json['category_subject_id']),
    version: Json.asOptionalString(json['version']),
    fileSize: Json.asInt(json['file_size']),
    pageCount: Json.asInt(json['page_count']),
    isCurrent: Json.asBool(json['is_current']),
  );
}
