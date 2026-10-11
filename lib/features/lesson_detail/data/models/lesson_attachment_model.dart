import '../../../../core/network/json_reader.dart';
import '../../../../core/utils/byte_format.dart';

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

  String get readableSize => ByteFormat.readable(fileSize);

  factory LessonAttachmentModel.fromJson(Map<String, dynamic> json) =>
      LessonAttachmentModel(
        id: Json.asInt(json['id']),
        fileName: Json.asString(json['file_name']),
        fileType: Json.asOptionalString(json['file_type']),
        fileSize: Json.asInt(json['file_size']),
      );
}
