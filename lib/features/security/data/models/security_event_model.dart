import '../../../../core/network/json_reader.dart';
import '../../../../core/enums/security_event_type_enum.dart';

class SecurityEventRequestModel {
  const SecurityEventRequestModel({
    required this.eventType,
    this.contentId,
    this.meta = const <String, dynamic>{},
  });

  final SecurityEventType eventType;

  final int? contentId;

  final Map<String, dynamic> meta;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'event_type': eventType.key,
    if (contentId != null) 'content_id': contentId,
    if (meta.isNotEmpty) 'meta': meta,
  };
}

class SecurityEventResponseModel {
  const SecurityEventResponseModel({
    required this.eventId,
    this.accountSuspended = false,
    this.warningIssued,
    this.canCaptureScreen,
  });

  final int eventId;
  final bool accountSuspended;

  final String? warningIssued;

  /// The account's capture permission as the backend sees it right now, echoed
  /// back on every reported event. Null when the payload omits it, which means
  /// "unchanged" rather than "revoked" — see ScreenCapturePolicy.
  final bool? canCaptureScreen;

  bool get hasWarning => (warningIssued ?? '').isNotEmpty;

  factory SecurityEventResponseModel.fromData(Map<String, dynamic> data) =>
      SecurityEventResponseModel(
        eventId: Json.asInt(data['event_id']),
        accountSuspended: Json.asBool(data['account_suspended']),
        warningIssued: Json.asOptionalString(data['warning_issued']),
        canCaptureScreen: Json.asOptionalBool(data['can_capture_screen']),
      );
}
