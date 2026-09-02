import '../../../../core/network/json_reader.dart';
import '../../../../core/models/active_context_model.dart';
import 'resume_lesson_model.dart';
import '../../../../core/models/subject_model.dart';
import 'subjects_summary_model.dart';

class HomeOverviewModel {
  const HomeOverviewModel({
    this.summary = const SubjectsSummaryModel(),
    this.resume,
    this.context,
    this.subjects = const <SubjectModel>[],
  });

  final SubjectsSummaryModel summary;

  final ResumeLessonModel? resume;

  final ActiveContextModel? context;

  final List<SubjectModel> subjects;

  bool get hasResume => resume != null;

  bool get isAwaitingApproval => context == null && subjects.isEmpty;

  factory HomeOverviewModel.fromData(Map<String, dynamic> data) =>
      HomeOverviewModel(
        summary: SubjectsSummaryModel.fromJson(Json.asMap(data['summary'])),
        resume: data['resume'] is Map
            ? ResumeLessonModel.fromJson(Json.asMap(data['resume']))
            : null,
        context: data['context'] is Map
            ? ActiveContextModel.fromJson(Json.asMap(data['context']))
            : null,
        subjects: SubjectModel.listFrom(data['items']),
      );
}
