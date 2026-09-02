part of 'splash_cubit.dart';

sealed class SplashState {
  const SplashState();
}

final class SplashInitial extends SplashState {
  const SplashInitial();
}

final class SplashLoading extends SplashState {
  const SplashLoading();
}

final class SplashCompleted extends SplashState {
  const SplashCompleted({required this.isLoggedIn, this.noticeKey});

  final bool isLoggedIn;
  final String? noticeKey;
}
