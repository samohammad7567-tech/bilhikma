class VerifyOtpRequestModel {
  const VerifyOtpRequestModel({required this.identifier, required this.code});

  final String identifier;
  final String code;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'identifier': identifier,
    'code': code,
  };
}
