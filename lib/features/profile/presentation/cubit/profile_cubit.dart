import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/models/profile_model.dart';
import '../../data/repos/profile_repo.dart';

part 'profile_state.dart';

/// The single source of truth for the signed-in user. Registered as a lazy
/// singleton, so the drawer, the account tab and the edit screen all read and
/// write the same state instead of each holding their own copy.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({this.repo = const ProfileRepo()})
    : super(const ProfileState()) {
    _seedFromCache();
    loadProfile();
  }

  final ProfileRepo repo;

  bool _isFetching = false;

  /// Identifies the newest read, so a slower earlier one cannot overwrite it.
  int _loadToken = 0;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    await _load();
  }

  /// Re-reads the profile without clearing what is already on screen.
  Future<void> refresh() => _load();

  /// Saves the edited fields, then re-reads the profile so every consumer
  /// rebuilds from the server's version of the user in one emit.
  Future<bool> updateProfile({required String fullName, String? email}) async {
    if (state.isSaving) return false;

    emit(state.copyWith(isSaving: true));

    try {
      await repo.updateProfile(fullName: fullName, email: email);

      emit(
        state.copyWith(
          profile: state.profile.copyWith(
            name: fullName,
            email: email ?? state.profile.email,
          ),
        ),
      );

      await _load(force: true);

      return true;
    } on AppException catch (error) {
      _emitSaveFailure(error.key);
      return false;
    } catch (error) {
      _emitSaveFailure(ErrorMapper.map(error));
      return false;
    }
  }

  /// Drops the previous account's data when the session ends.
  void reset() {
    _isFetching = false;
    _loadToken++;

    emit(const ProfileState());
  }

  /// Starts a new session: takes the user just cached by login, then re-reads
  /// the profile, so nothing survives from the previous account.
  Future<void> reload() async {
    reset();
    _seedFromCache();

    await loadProfile();
  }

  void reportMessage(String messageKey) =>
      emit(state.copyWith(messageKey: messageKey));

  void _seedFromCache() {
    final ProfileModel? cached = repo.cachedProfile();
    if (cached == null) return;

    emit(state.copyWith(profile: cached));
  }

  Future<void> _load({bool force = false}) async {
    if (_isFetching && !force) return;

    final int token = ++_loadToken;
    _isFetching = true;

    try {
      final ProfileModel profile = await repo.fetchProfile();
      if (isClosed || token != _loadToken) return;

      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } on AppException catch (error) {
      if (token == _loadToken) _emitLoadFailure(error.key);
    } catch (error) {
      if (token == _loadToken) _emitLoadFailure(ErrorMapper.map(error));
    } finally {
      if (token == _loadToken) _isFetching = false;
    }
  }

  void _emitLoadFailure(String errorKey) {
    if (isClosed) return;

    emit(state.copyWith(status: ProfileStatus.failure, errorKey: errorKey));
  }

  void _emitSaveFailure(String errorKey) {
    if (isClosed) return;

    emit(state.copyWith(errorKey: errorKey));
  }
}
