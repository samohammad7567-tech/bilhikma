import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/models/active_pathway_model.dart';
import '../../data/models/educational_pathway_model.dart';
import '../../data/models/pathway_level_model.dart';
import '../../data/models/pathway_selection_model.dart';
import '../../data/models/pathway_stage_model.dart';
import '../../data/models/pathway_submission_model.dart';
import '../../data/models/pathway_term_model.dart';
import '../../data/models/pathways_snapshot_model.dart';
import '../../data/repos/educational_pathways_repo.dart';
import '../refactor/pathway_option.dart';

part 'educational_pathways_state.dart';

class EducationalPathwaysCubit extends Cubit<EducationalPathwaysState> {
  EducationalPathwaysCubit({this.repo = const EducationalPathwaysRepo()})
    : super(const EducationalPathwaysState()) {
    loadPathways();
  }

  final EducationalPathwaysRepo repo;

  Future<void> loadPathways() async {
    emit(state.copyWith(status: EducationalPathwaysStatus.loading));

    try {
      final PathwaysSnapshotModel snapshot = await repo.fetchPathways();
      if (isClosed) return;

      emit(
        state.copyWith(
          status: EducationalPathwaysStatus.success,
          pathways: snapshot.pathways,
          active: snapshot.active,
          expandedNodeIds: _expansionFor(snapshot.pathways, snapshot.active),
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: EducationalPathwaysStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  void toggleNode(String nodeId) {
    final Set<String> expanded = Set<String>.of(state.expandedNodeIds);
    if (!expanded.remove(nodeId)) expanded.add(nodeId);

    emit(state.copyWith(expandedNodeIds: expanded));
  }

  Future<void> openSwitchForm() async {
    emit(
      state.copyWith(
        draft: PathwaySelectionModel(
          pathwayId: state.active.pathwayId,
          levelId: state.active.levelId,
          termId: state.active.termId,
        ),
        clearDraftInstitute: true,
      ),
    );

    await _loadInstitutes();
    if (isClosed) return;

    final String? pathwayId = state.draft.pathwayId;
    if (pathwayId != null && pathwayId.isNotEmpty) {
      await _loadClasses(pathwayId);
    }
  }

  void selectInstitution(String? pathwayId) {
    if (pathwayId == state.draft.pathwayId) return;

    emit(
      state.copyWith(
        draft: PathwaySelectionModel(pathwayId: pathwayId),
        clearDraftInstitute: true,
      ),
    );

    if (pathwayId != null) _loadClasses(pathwayId);
  }

  void selectLevel(String? levelId) {
    if (levelId == state.draft.levelId) return;

    emit(
      state.copyWith(
        draft: PathwaySelectionModel(
          pathwayId: state.draft.pathwayId,
          levelId: levelId,
        ),
      ),
    );
  }

  void selectTerm(String? termId) {
    if (termId == state.draft.termId) return;

    emit(
      state.copyWith(
        draft: PathwaySelectionModel(
          pathwayId: state.draft.pathwayId,
          levelId: state.draft.levelId,
          termId: termId,
        ),
      ),
    );
  }

  Future<void> _loadInstitutes() async {
    if (state.isLoadingInstitutes) return;

    emit(state.copyWith(isLoadingInstitutes: true));

    try {
      final List<EducationalPathwayModel> institutes = await repo
          .fetchInstitutes(state.visiblePathways);
      if (isClosed) return;

      emit(state.copyWith(isLoadingInstitutes: false, institutes: institutes));
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingInstitutes: false,
          errorKey: ErrorMapper.map(error),
          serverMessage: _serverMessage(error),
        ),
      );
    }
  }

  Future<void> _loadClasses(String pathwayId) async {
    final EducationalPathwayModel? institute = _instituteById(pathwayId);
    if (institute == null) return;

    emit(state.copyWith(isLoadingClasses: true));

    try {
      final EducationalPathwayModel loaded = await repo.fetchClasses(institute);
      if (isClosed) return;

      emit(state.copyWith(isLoadingClasses: false, draftInstitute: loaded));
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingClasses: false,
          errorKey: ErrorMapper.map(error),
          serverMessage: _serverMessage(error),
        ),
      );
    }
  }

  Future<void> switchPathway() async {
    if (state.isSwitching) return;

    final EducationalPathwayModel? institute = state.draftInstitute;
    if (institute == null || !state.draft.isComplete) {
      emit(state.copyWith(errorKey: 'pathway_selection_incomplete'));
      return;
    }

    emit(state.copyWith(isSwitching: true));

    try {
      final PathwaySubmissionModel result = await repo.submitSelection(
        institute,
        state.draft,
      );
      if (isClosed) return;

      if (result.isSwitched) {
        _reportSwitch(result.active!);
        return;
      }

      emit(
        state.copyWith(
          isSwitching: false,
          messageKey: 'enrollment_request_sent',
        ),
      );
      await loadPathways();
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSwitching: false,
          errorKey: ErrorMapper.map(error),
          serverMessage: _serverMessage(error),
        ),
      );
    }
  }

  void _reportSwitch(ActivePathwayModel active) => emit(
    state.copyWith(
      isSwitching: false,
      active: active,
      expandedNodeIds: _expansionFor(state.visiblePathways, active),
      messageKey: 'pathway_switched',
    ),
  );

  EducationalPathwayModel? _instituteById(String pathwayId) {
    for (final EducationalPathwayModel institute in state.visibleInstitutes) {
      if (institute.id == pathwayId) return institute;
    }
    return null;
  }

  static String? _serverMessage(Object error) =>
      error is AppException ? error.message : null;

  static Set<String> _expansionFor(
    List<EducationalPathwayModel> pathways,
    ActivePathwayModel active,
  ) {
    for (final EducationalPathwayModel pathway in pathways) {
      if (pathway.id != active.pathwayId) continue;

      for (final PathwayStageModel stage in pathway.stages) {
        for (final PathwayLevelModel level in stage.levels) {
          if (level.id != active.levelId) continue;

          return <String>{stage.id, level.id};
        }
      }
    }

    return const <String>{};
  }
}
