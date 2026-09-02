import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_mapper.dart';
import '../../data/models/sidebar_user_model.dart';
import '../../data/repos/sidebar_repo.dart';

part 'sidebar_state.dart';

class SidebarCubit extends Cubit<SidebarState> {
  SidebarCubit({this.repo = const SidebarRepo()})
    : super(const SidebarState()) {
    loadUser();
  }

  final SidebarRepo repo;

  Future<void> loadUser() async {
    emit(state.copyWith(status: SidebarStatus.loading));

    try {
      final SidebarUserModel user = await repo.fetchUser();
      emit(state.copyWith(status: SidebarStatus.success, user: user));
    } catch (error) {
      emit(
        state.copyWith(
          status: SidebarStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }
}
