/// Localization keys as constants, so no UI file carries a raw translation
/// string.
///
/// Both `assets/translations/ar.json` and `assets/translations/en.json` must
/// hold every key listed here.
///
/// Usage: `LangKeys.somethingWentWrong.tr()`.
///
/// Much of this app still passes raw key strings (`'something_went_wrong'.tr()`)
/// and error keys straight from `ErrorMapper`. Add the constant here as you
/// touch each place, rather than in one sweep.
class LangKeys {
  LangKeys._();

  /// Generic failure shown when nothing more specific is known.
  static const String somethingWentWrong = 'something_went_wrong';
}
