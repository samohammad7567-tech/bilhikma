part of 'security_cubit.dart';

enum SecurityStatus { idle, warned, suspended }

class SecurityState {
  const SecurityState({
    this.status = SecurityStatus.idle,
    this.warningIssued,
    this.eventId,
  });

  final SecurityStatus status;

  final String? warningIssued;

  final int? eventId;

  bool get isWarned => status == SecurityStatus.warned;
  bool get isSuspended => status == SecurityStatus.suspended;

  SecurityState copyWith({
    SecurityStatus? status,
    String? warningIssued,
    int? eventId,
  }) => SecurityState(
    status: status ?? this.status,
    warningIssued: warningIssued ?? this.warningIssued,
    eventId: eventId ?? this.eventId,
  );
}
