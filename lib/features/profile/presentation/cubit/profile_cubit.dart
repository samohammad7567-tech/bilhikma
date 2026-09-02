import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/models/profile_model.dart';
import '../../data/repos/profile_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({this.repo = const ProfileRepo()})
    : super(const ProfileState()) {
    loadProfile();
  }

  final ProfileRepo repo;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final ProfileModel profile = await repo.fetchProfile();
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  void reportMessage(String messageKey) =>
      emit(state.copyWith(messageKey: messageKey));
}
