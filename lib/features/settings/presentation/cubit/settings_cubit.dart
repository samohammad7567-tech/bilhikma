import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/models/settings_model.dart';
import '../../../../core/enums/sleep_timer_option_enum.dart';
import '../../data/repos/settings_repo.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({this.repo = const SettingsRepo()})
    : super(const SettingsState()) {
    loadSettings();
  }

  final SettingsRepo repo;

  Future<void> loadSettings() async {
    emit(state.copyWith(status: SettingsStatus.loading));

    try {
      final SettingsModel settings = await repo.readSettings();
      emit(state.copyWith(status: SettingsStatus.success, settings: settings));
    } catch (error) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  void increaseFontScale() =>
      _applyFontScale(state.settings.fontScale + SettingsModel.fontScaleStep);

  void decreaseFontScale() =>
      _applyFontScale(state.settings.fontScale - SettingsModel.fontScaleStep);

  Future<void> selectSleepTimer(SleepTimerOption option) async {
    if (option.minutes == state.settings.sleepTimerMinutes) return;

    emit(
      state.copyWith(
        settings: state.settings.copyWith(sleepTimerMinutes: option.minutes),
      ),
    );

    try {
      await repo.saveSleepTimer(option.minutes);
    } catch (error) {
      emit(state.copyWith(errorKey: ErrorMapper.map(error)));
    }
  }

  Future<void> clearDownloads() async {
    emit(state.copyWith(isClearingDownloads: true));

    try {
      await repo.clearDownloads();
      emit(
        state.copyWith(
          isClearingDownloads: false,
          messageKey: 'downloads_cleared',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isClearingDownloads: false,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  void reportMessage(String messageKey) =>
      emit(state.copyWith(messageKey: messageKey));
  Future<void> _applyFontScale(double scale) async {
    final double normalised = SettingsModel.normaliseScale(scale);
    if (normalised == state.settings.fontScale) return;

    emit(
      state.copyWith(settings: state.settings.copyWith(fontScale: normalised)),
    );

    try {
      await repo.saveFontScale(normalised);
    } catch (error) {
      emit(state.copyWith(errorKey: ErrorMapper.map(error)));
    }
  }
}
