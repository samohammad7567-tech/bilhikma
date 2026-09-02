import '../../../../core/utils/error_mapper.dart';
import '../../../enrollments/data/data_source/enrollments_data_source.dart';
import '../../../../core/models/active_context_model.dart';
import '../../../../core/models/enrollment_entity_model.dart';
import '../../../../core/models/enrollment_node_model.dart';
import '../../../../core/models/my_enrollments_model.dart';
import '../../../../core/models/public_category_model.dart';
import '../../../../core/models/public_entity_model.dart';
import '../models/active_pathway_model.dart';
import '../models/educational_pathway_model.dart';
import '../models/pathway_level_model.dart';
import '../models/pathway_selection_model.dart';
import '../models/pathway_stage_model.dart';
import '../models/pathway_submission_model.dart';
import '../models/pathway_term_model.dart';
import '../models/pathways_snapshot_model.dart';

class EducationalPathwaysDataSource {
  const EducationalPathwaysDataSource({
    this.enrollments = const EnrollmentsDataSource(),
  });

  final EnrollmentsDataSource enrollments;

  Future<PathwaysSnapshotModel> fetchPathways() async {
    final MyEnrollmentsModel enrolled = await enrollments.fetchMyEnrollments();
    final List<EducationalPathwayModel> pathways = _toPathways(enrolled);

    return PathwaysSnapshotModel(
      pathways: pathways,
      active: _activeFrom(pathways, enrolled.activeEnrollmentId),
    );
  }

  Future<List<EducationalPathwayModel>> fetchInstitutes(
    List<EducationalPathwayModel> enrolledIn,
  ) async {
    final List<PublicEntityModel> open = await enrollments
        .fetchPublicEntities();

    final Map<int, EducationalPathwayModel> byId =
        <int, EducationalPathwayModel>{
          for (final EducationalPathwayModel pathway in enrolledIn)
            pathway.entityId: pathway,
        };

    for (final PublicEntityModel entity in open) {
      byId.putIfAbsent(
        entity.id,
        () => EducationalPathwayModel(
          entityId: entity.id,
          institutionName: entity.name,
          logoUrl: entity.logoUrl,
        ),
      );
    }

    return byId.values.toList(growable: false);
  }

  Future<EducationalPathwayModel> fetchClasses(
    EducationalPathwayModel institute,
  ) async {
    final List<PublicCategoryModel> roots;
    try {
      roots = await enrollments.fetchPublicCategories(institute.entityId);
    } on AppException {
      return institute;
    }

    if (roots.isEmpty) return institute;

    final Map<int, PathwayTermModel> held = _enrolledByCategory(institute);

    return institute.copyWith(
      stages: <PathwayStageModel>[
        for (final PublicCategoryModel root in roots)
          _toPublicStage(root, held),
      ],
    );
  }

  Future<PathwaySubmissionModel> submitSelection(
    EducationalPathwayModel institute,
    PathwaySelectionModel selection,
  ) async {
    if (!selection.isComplete) {
      throw const AppException('pathway_selection_incomplete');
    }

    final PathwayLevelModel? level = institute.levelById(selection.levelId);
    final PathwayTermModel? term = level?.termById(selection.termId);

    if (level == null || term == null) {
      throw const AppException('pathway_selection_incomplete');
    }

    final int? enrollmentId = term.enrollmentId;
    if (enrollmentId != null && term.isSwitchable) {
      return PathwaySubmissionModel.switched(
        await _switchTo(institute, level, term, enrollmentId),
      );
    }

    if (!term.isJoinable) {
      throw const AppException('enrollment_not_available');
    }

    return PathwaySubmissionModel.applied(
      await enrollments.apply(
        entityId: institute.entityId,
        categoryId: term.categoryId,
      ),
    );
  }

  Future<ActivePathwayModel> _switchTo(
    EducationalPathwayModel institute,
    PathwayLevelModel level,
    PathwayTermModel term,
    int enrollmentId,
  ) async {
    final ActiveContextModel context = await enrollments.switchContext(
      enrollmentId,
    );

    return ActivePathwayModel(
      pathwayId: institute.id,
      levelId: level.id,
      termId: term.id,

      institutionName: context.entityName.isEmpty
          ? institute.institutionName
          : context.entityName,
      levelName: level.name,
      termName: context.categoryName.isEmpty ? term.name : context.categoryName,
    );
  }

  List<EducationalPathwayModel> _toPathways(
    MyEnrollmentsModel enrolled,
  ) => <EducationalPathwayModel>[
    for (final EnrollmentEntityModel entity in enrolled.entities)
      EducationalPathwayModel(
        entityId: entity.entityId,
        institutionName: entity.entityName,
        logoUrl: entity.logoUrl,
        stages: <PathwayStageModel>[
          for (final EnrollmentNodeModel root in entity.tree) _toStage(root),
        ],
      ),
  ];

  PathwayStageModel _toStage(EnrollmentNodeModel node) => PathwayStageModel(
    categoryId: node.categoryId,
    name: node.name,
    levels: node.hasChildren
        ? <PathwayLevelModel>[
            for (final EnrollmentNodeModel child in node.children)
              _toLevel(child),
          ]
        : _standIn(node, _toLevel),
  );

  PathwayLevelModel _toLevel(EnrollmentNodeModel node) => PathwayLevelModel(
    categoryId: node.categoryId,
    name: node.name,
    terms: node.hasChildren
        ? <PathwayTermModel>[
            for (final EnrollmentNodeModel child in node.children)
              _toTerm(child),
          ]
        : _standIn(node, _toTerm),
  );

  PathwayTermModel _toTerm(EnrollmentNodeModel node) => PathwayTermModel(
    categoryId: node.categoryId,
    name: node.name,
    enrollmentId: node.enrollmentId,
    isSwitchable: node.isSelectable,

    isJoinable: !node.hasChildren && !node.isGroup,
    isActive: node.isActive,
  );

  List<T> _standIn<T>(
    EnrollmentNodeModel node,
    T Function(EnrollmentNodeModel) map,
  ) => node.isGroup ? <T>[] : <T>[map(node)];

  PathwayStageModel _toPublicStage(
    PublicCategoryModel node,
    Map<int, PathwayTermModel> held,
  ) => PathwayStageModel(
    categoryId: node.id,
    name: node.name,
    levels: node.hasChildren
        ? <PathwayLevelModel>[
            for (final PublicCategoryModel child in node.children)
              _toPublicLevel(child, held),
          ]
        : <PathwayLevelModel>[_toPublicLevel(node, held)],
  );

  PathwayLevelModel _toPublicLevel(
    PublicCategoryModel node,
    Map<int, PathwayTermModel> held,
  ) => PathwayLevelModel(
    categoryId: node.id,
    name: node.name,
    terms: node.hasChildren
        ? <PathwayTermModel>[
            for (final PublicCategoryModel child in node.children)
              _toPublicTerm(child, held),
          ]
        : <PathwayTermModel>[_toPublicTerm(node, held)],
  );

  PathwayTermModel _toPublicTerm(
    PublicCategoryModel node,
    Map<int, PathwayTermModel> held,
  ) {
    final PathwayTermModel? enrolled = held[node.id];

    return PathwayTermModel(
      categoryId: node.id,
      name: node.name,
      enrollmentId: enrolled?.enrollmentId,
      isSwitchable: enrolled?.isSwitchable ?? false,
      isJoinable: node.isSelectable,
      isActive: enrolled?.isActive ?? false,
    );
  }

  Map<int, PathwayTermModel> _enrolledByCategory(
    EducationalPathwayModel institute,
  ) => <int, PathwayTermModel>{
    for (final PathwayStageModel stage in institute.stages)
      for (final PathwayLevelModel level in stage.levels)
        for (final PathwayTermModel term in level.terms)
          if (term.isEnrolled) term.categoryId: term,
  };

  ActivePathwayModel _activeFrom(
    List<EducationalPathwayModel> pathways,
    int? activeEnrollmentId,
  ) {
    if (activeEnrollmentId == null) return const ActivePathwayModel();

    for (final EducationalPathwayModel pathway in pathways) {
      for (final PathwayStageModel stage in pathway.stages) {
        for (final PathwayLevelModel level in stage.levels) {
          for (final PathwayTermModel term in level.terms) {
            if (term.enrollmentId != activeEnrollmentId) continue;

            return ActivePathwayModel(
              pathwayId: pathway.id,
              levelId: level.id,
              termId: term.id,
              institutionName: pathway.institutionName,
              levelName: level.name,
              termName: term.name,
            );
          }
        }
      }
    }

    return const ActivePathwayModel();
  }
}
