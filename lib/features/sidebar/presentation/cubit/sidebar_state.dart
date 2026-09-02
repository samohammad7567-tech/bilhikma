part of 'sidebar_cubit.dart';

enum SidebarStatus { initial, loading, success, failure }

final class SidebarState {
  const SidebarState({
    this.status = SidebarStatus.initial,
    this.user,
    this.errorKey,
  });

  final SidebarStatus status;
  final SidebarUserModel? user;
  final String? errorKey;

  String? get avatarUrl => user?.avatarUrl;

  SidebarState copyWith({
    SidebarStatus? status,
    SidebarUserModel? user,
    String? errorKey,
  }) => SidebarState(
    status: status ?? this.status,
    user: user ?? this.user,
    errorKey: errorKey,
  );
}
