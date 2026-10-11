import '../network/json_reader.dart';
import '../utils/byte_format.dart';

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

  String get readableSize => ByteFormat.readable(fileSize);

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
