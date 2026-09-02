part of 'educational_pathways_cubit.dart';

enum EducationalPathwaysStatus { initial, loading, success, failure }

final class EducationalPathwaysState {
  const EducationalPathwaysState({
    this.status = EducationalPathwaysStatus.initial,
    this.pathways,
    this.active = const ActivePathwayModel(),
    this.expandedNodeIds = const <String>{},
    this.institutes,
    this.isLoadingInstitutes = false,
    this.draftInstitute,
    this.isLoadingClasses = false,
    this.draft = const PathwaySelectionModel(),
    this.isSwitching = false,
    this.errorKey,
    this.messageKey,
    this.serverMessage,
  });

  final EducationalPathwaysStatus status;

  final List<EducationalPathwayModel>? pathways;
  final ActivePathwayModel active;
  final Set<String> expandedNodeIds;

  final List<EducationalPathwayModel>? institutes;
  final bool isLoadingInstitutes;

  final EducationalPathwayModel? draftInstitute;
  final bool isLoadingClasses;

  final PathwaySelectionModel draft;
  final bool isSwitching;
  final String? errorKey;
  final String? messageKey;

  final String? serverMessage;

  bool get isFirstLoad =>
      status == EducationalPathwaysStatus.loading && pathways == null;

  bool get hasFailed =>
      status == EducationalPathwaysStatus.failure && pathways == null;

  List<EducationalPathwayModel> get visiblePathways =>
      pathways ?? const <EducationalPathwayModel>[];

  bool get hasActivePathway => !active.isEmpty;

  bool isExpanded(String nodeId) => expandedNodeIds.contains(nodeId);

  List<EducationalPathwayModel> get visibleInstitutes =>
      institutes ?? const <EducationalPathwayModel>[];

  List<PathwayOption> get institutionOptions => <PathwayOption>[
    for (final EducationalPathwayModel institute in visibleInstitutes)
      PathwayOption(id: institute.id, label: institute.institutionName),
  ];

  List<PathwayOption> get levelOptions {
    final EducationalPathwayModel? institute = draftInstitute;
    if (institute == null) return const <PathwayOption>[];

    final bool qualify = institute.stages.length > 1;

    return <PathwayOption>[
      for (final PathwayStageModel stage in institute.stages)
        for (final PathwayLevelModel level in stage.levels)
          PathwayOption(
            id: level.id,
            label: qualify ? '${stage.name} - ${level.name}' : level.name,
          ),
    ];
  }

  List<PathwayOption> get termOptions => <PathwayOption>[
    for (final PathwayTermModel term
        in draftInstitute?.levelById(draft.levelId)?.offerableTerms ??
            const <PathwayTermModel>[])
      PathwayOption(id: term.id, label: term.name),
  ];

  bool get canSubmitSwitch =>
      draft.isComplete && !isSwitching && !isLoadingClasses;

  EducationalPathwaysState copyWith({
    EducationalPathwaysStatus? status,
    List<EducationalPathwayModel>? pathways,
    ActivePathwayModel? active,
    Set<String>? expandedNodeIds,
    List<EducationalPathwayModel>? institutes,
    bool? isLoadingInstitutes,
    EducationalPathwayModel? draftInstitute,
    bool clearDraftInstitute = false,
    bool? isLoadingClasses,
    PathwaySelectionModel? draft,
    bool? isSwitching,
    String? errorKey,
    String? messageKey,
    String? serverMessage,
  }) => EducationalPathwaysState(
    status: status ?? this.status,
    pathways: pathways ?? this.pathways,
    active: active ?? this.active,
    expandedNodeIds: expandedNodeIds ?? this.expandedNodeIds,
    institutes: institutes ?? this.institutes,
    isLoadingInstitutes: isLoadingInstitutes ?? this.isLoadingInstitutes,
    draftInstitute: clearDraftInstitute
        ? null
        : draftInstitute ?? this.draftInstitute,
    isLoadingClasses: isLoadingClasses ?? this.isLoadingClasses,
    draft: draft ?? this.draft,
    isSwitching: isSwitching ?? this.isSwitching,

    errorKey: errorKey,
    messageKey: messageKey,
    serverMessage: serverMessage,
  );
}
