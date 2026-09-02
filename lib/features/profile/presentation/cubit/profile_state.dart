part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, success, failure }

final class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile = const ProfileModel(),
    this.errorKey,
    this.messageKey,
  });

  final ProfileStatus status;
  final ProfileModel profile;
  final String? errorKey;
  final String? messageKey;

  bool get isLoading => status == ProfileStatus.loading;
  bool get hasFailed => status == ProfileStatus.failure;
  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? profile,
    String? errorKey,
    String? messageKey,
  }) => ProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    errorKey: errorKey,
    messageKey: messageKey,
  );
}
