/// {@template language_detector}
/// Detects whether a given text input is primarily Arabic or English.
///
/// This is a lightweight, offline heuristic detector used to decide
/// which AI prompt language to use and how to pre-process user input.
/// {@endtemplate}
class LanguageDetector {
  /// Creates a [LanguageDetector] instance.
  const LanguageDetector();

  /// Arabic Unicode range: U+0600 to U+06FF (Arabic block).
  static final RegExp _arabicRegExp = RegExp(
    r'[\u0600-\u06FF]',
  );

  /// English alphabetic characters (A-Z, a-z).
  static final RegExp _englishRegExp = RegExp(
    r'[a-zA-Z]',
  );

  /// Detects the dominant language of [input].
  ///
  /// Returns:
  /// - `"ar"` if Arabic characters dominate.
  /// - `"en"` if English characters dominate.
  /// - `"en"` as the fallback for empty or ambiguous input.
  ///
  /// The detection is based on counting Arabic vs. English alphabetic
  /// characters. Non-alphabetic characters (numbers, punctuation, emojis)
  /// are ignored.
  String detect(String input) {
    if (input.trim().isEmpty) {
      return 'en';
    }

    final arabicCount = _arabicRegExp.allMatches(input).length;
    final englishCount = _englishRegExp.allMatches(input).length;

    if (arabicCount > englishCount) {
      return 'ar';
    }

    return 'en';
  }

  /// Returns `true` if [input] is detected as Arabic.
  bool isArabic(String input) => detect(input) == 'ar';

  /// Returns `true` if [input] is detected as English.
  bool isEnglish(String input) => detect(input) == 'en';
}
