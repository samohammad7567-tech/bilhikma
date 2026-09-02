class SubjectContentArgs {
  const SubjectContentArgs({required this.categorySubjectId});

  final int categorySubjectId;

  bool get isValid => categorySubjectId > 0;

  factory SubjectContentArgs.fromRoute(Object? arguments) {
    if (arguments is SubjectContentArgs) return arguments;

    return SubjectContentArgs(
      categorySubjectId: switch (arguments) {
        final int id => id,
        final String id => int.tryParse(id) ?? 0,
        _ => 0,
      },
    );
  }
}
