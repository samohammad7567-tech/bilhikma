part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, success, failure }

final class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile = const ProfileModel(),
    this.isSaving = false,
    this.errorKey,
    this.messageKey,
  });

  final ProfileStatus status;
  final ProfileModel profile;

  /// True while an edit is being sent to the backend.
  final bool isSaving;

  final String? errorKey;
  final String? messageKey;

  bool get isLoading => status == ProfileStatus.loading;
  bool get hasFailed => status == ProfileStatus.failure;

  bool get hasUser => profile.name.trim().isNotEmpty;

  /// Only block the screen when there is nothing to show yet: a refresh keeps
  /// the current user on screen instead of flashing a spinner.
  bool get isFirstLoad => isLoading && !hasUser;

  bool get hasFailedOutright => hasFailed && !hasUser;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? profile,
    bool? isSaving,
    String? errorKey,
    String? messageKey,
  }) => ProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    isSaving: isSaving ?? false,
    errorKey: errorKey,
    messageKey: messageKey,
  );
}
