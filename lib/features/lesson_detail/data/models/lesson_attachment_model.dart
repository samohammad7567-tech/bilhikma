import '../../../../core/network/json_reader.dart';

class LessonAttachmentModel {
  const LessonAttachmentModel({
    required this.id,
    required this.fileName,
    this.fileType,
    this.fileSize = 0,
  });

  final int id;
  final String fileName;

  final String? fileType;

  final int fileSize;

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

  factory LessonAttachmentModel.fromJson(Map<String, dynamic> json) =>
      LessonAttachmentModel(
        id: Json.asInt(json['id']),
        fileName: Json.asString(json['file_name']),
        fileType: Json.asOptionalString(json['file_type']),
        fileSize: Json.asInt(json['file_size']),
      );
}
