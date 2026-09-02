import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../data/models/lesson_test_model.dart';
import '../../data/models/test_answer_model.dart';
import '../../data/models/test_pair_model.dart';
import '../../data/models/test_question_model.dart';
import '../../../../core/enums/test_question_type_enum.dart';
import '../../data/models/test_result_model.dart';
import '../../data/models/test_sentence_model.dart';
import '../../data/repos/lesson_test_repo.dart';
import '../refactor/test_shuffle.dart';

part 'lesson_test_state.dart';

class LessonTestCubit extends Cubit<LessonTestState> {
  LessonTestCubit({required this.lessonId, this.repo = const LessonTestRepo()})
    : super(const LessonTestState()) {
    loadTest();
  }

  final String lessonId;
  final LessonTestRepo repo;

  Timer? _ticker;

  Future<void> loadTest() async {
    emit(state.copyWith(status: LessonTestStatus.loading));

    try {
      final LessonTestModel test = await repo.fetchTest(lessonId: lessonId);

      emit(
        LessonTestState(
          status: LessonTestStatus.success,
          test: test,
          answers: _initialAnswers(test),
          matchOrder: _initialMatchOrder(test),
          remaining: test.duration,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: LessonTestStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  void startTest() {
    final LessonTestModel? test = state.test;
    if (test == null || !test.hasQuestions) return;

    emit(
      state.copyWith(
        phase: LessonTestPhase.running,
        currentIndex: 0,
        remaining: test.duration,
        questionElapsed: Duration.zero,
        clearSelectedBlank: true,
        clearSelectedPrompt: true,
      ),
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void selectOption(String optionId) {
    final TestQuestionModel? question = state.currentQuestion;
    if (question == null) return;

    final TestAnswerModel current = state.currentAnswer;

    if (!question.type.isMultiSelect) {
      _emitAnswer(current.copyWith(optionIds: <String>[optionId]));
      return;
    }

    final List<String> picked = List<String>.of(current.optionIds);
    picked.contains(optionId) ? picked.remove(optionId) : picked.add(optionId);

    _emitAnswer(current.copyWith(optionIds: picked));
  }

  void selectBlank(String blankId) => emit(
    state.selectedBlankId == blankId
        ? state.copyWith(clearSelectedBlank: true)
        : state.copyWith(selectedBlankId: blankId),
  );

  void assignWord(String optionId) {
    final TestQuestionModel? question = state.currentQuestion;
    if (question == null) return;

    final TestAnswerModel current = state.currentAnswer;
    final String? target = state.selectedBlankId ?? _firstEmptyBlank(question);
    if (target == null) return;

    final Map<String, String> blanks = Map<String, String>.of(current.blanks)
      ..[target] = optionId
      ..removeWhere(
        (String blankId, String value) =>
            value == optionId && blankId != target,
      );

    _emitAnswer(current.copyWith(blanks: blanks), clearSelectedBlank: true);
  }

  void clearBlank(String blankId) {
    final TestAnswerModel current = state.currentAnswer;
    if (!current.blanks.containsKey(blankId)) return;

    _emitAnswer(
      current.copyWith(
        blanks: Map<String, String>.of(current.blanks)..remove(blankId),
      ),
      clearSelectedBlank: true,
    );
  }

  void typeBlank({required String blankId, required String value}) {
    final TestAnswerModel current = state.currentAnswer;
    final Map<String, String> blanks = Map<String, String>.of(current.blanks);

    value.trim().isEmpty ? blanks.remove(blankId) : blanks[blankId] = value;

    _emitAnswer(current.copyWith(blanks: blanks));
  }

  void selectPrompt(String pairId) => emit(
    state.selectedPromptId == pairId
        ? state.copyWith(clearSelectedPrompt: true)
        : state.copyWith(selectedPromptId: pairId),
  );

  void linkMatch(String matchId) {
    final String? promptId = state.selectedPromptId;
    if (promptId == null) return;

    final TestAnswerModel current = state.currentAnswer;
    final Map<String, String> pairs = Map<String, String>.of(current.pairs)
      ..[promptId] = matchId
      ..removeWhere(
        (String pairId, String value) => value == matchId && pairId != promptId,
      );

    _emitAnswer(current.copyWith(pairs: pairs), clearSelectedPrompt: true);
  }

  void clearPair(String pairId) {
    final TestAnswerModel current = state.currentAnswer;
    if (!current.pairs.containsKey(pairId)) return;

    _emitAnswer(
      current.copyWith(
        pairs: Map<String, String>.of(current.pairs)..remove(pairId),
      ),
      clearSelectedPrompt: true,
    );
  }

  void reorderSentences(int oldIndex, int newIndex) {
    final TestAnswerModel current = state.currentAnswer;
    final List<String> order = List<String>.of(current.order);
    if (oldIndex < 0 || oldIndex >= order.length) return;

    final String moved = order.removeAt(oldIndex);
    order.insert(newIndex.clamp(0, order.length), moved);

    _emitAnswer(current.copyWith(order: order));
  }

  void goNext() {
    if (state.isLastQuestion) {
      submit();
      return;
    }

    _moveTo(state.currentIndex + 1);
  }

  void goPrevious() {
    if (state.isFirstQuestion) return;
    _moveTo(state.currentIndex - 1);
  }

  Future<void> submit({bool timedOut = false}) async {
    final LessonTestModel? test = state.test;
    if (test == null || state.phase == LessonTestPhase.result) return;

    _ticker?.cancel();

    try {
      final TestResultModel result = await repo.submitAttempt(
        test: test,
        answers: state.answers,
      );

      emit(
        state.copyWith(
          phase: LessonTestPhase.result,
          result: result,
          messageKey: timedOut ? 'test_time_up' : null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: LessonTestStatus.failure,
          errorKey: ErrorMapper.map(error),
        ),
      );
    }
  }

  void reportMessage(String messageKey) =>
      emit(state.copyWith(messageKey: messageKey));

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }

  void _tick() {
    if (state.phase != LessonTestPhase.running) return;

    final Duration remaining = state.remaining - const Duration(seconds: 1);

    if (remaining <= Duration.zero) {
      emit(state.copyWith(remaining: Duration.zero));
      submit(timedOut: true);
      return;
    }

    emit(
      state.copyWith(
        remaining: remaining,
        questionElapsed: state.questionElapsed + const Duration(seconds: 1),
      ),
    );
  }

  void _moveTo(int index) => emit(
    state.copyWith(
      currentIndex: index,
      questionElapsed: Duration.zero,
      clearSelectedBlank: true,
      clearSelectedPrompt: true,
    ),
  );

  void _emitAnswer(
    TestAnswerModel answer, {
    bool clearSelectedBlank = false,
    bool clearSelectedPrompt = false,
  }) {
    final TestQuestionModel? question = state.currentQuestion;
    if (question == null) return;

    emit(
      state.copyWith(
        answers: Map<String, TestAnswerModel>.of(state.answers)
          ..[question.id] = answer,
        clearSelectedBlank: clearSelectedBlank,
        clearSelectedPrompt: clearSelectedPrompt,
      ),
    );
  }

  String? _firstEmptyBlank(TestQuestionModel question) {
    final TestAnswerModel current = state.currentAnswer;

    for (final blank in question.blanks) {
      if (!current.blanks.containsKey(blank.id)) return blank.id;
    }
    return null;
  }

  Map<String, TestAnswerModel> _initialAnswers(LessonTestModel test) {
    final Map<String, TestAnswerModel> answers = <String, TestAnswerModel>{};

    for (final TestQuestionModel question in test.questions) {
      if (question.type != TestQuestionType.orderSentences) continue;

      answers[question.id] = TestAnswerModel(
        order: TestShuffle.deterministic(
          question.sentences
              .map((TestSentenceModel sentence) => sentence.id)
              .toList(growable: false),
          question.id,
        ),
      );
    }

    return answers;
  }

  Map<String, List<String>> _initialMatchOrder(LessonTestModel test) {
    final Map<String, List<String>> order = <String, List<String>>{};

    for (final TestQuestionModel question in test.questions) {
      if (question.type != TestQuestionType.matchPairs) continue;

      order[question.id] = TestShuffle.deterministic(
        question.pairs
            .map((TestPairModel pair) => pair.id)
            .toList(growable: false),
        '${question.id}-match',
      );
    }

    return order;
  }
}
