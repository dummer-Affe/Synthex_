import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguageOption {
  const LanguageOption({
    required this.label,
    required this.translateLanguage,
    required this.defaultTtsLocale,
  });

  final String label;
  final TranslateLanguage translateLanguage;
  final String defaultTtsLocale;

  String get bcpCode => translateLanguage.bcpCode;

  static LanguageOption get defaultSource => supportedLanguages.firstWhere(
    (LanguageOption language) =>
        language.translateLanguage == TranslateLanguage.english,
  );

  static LanguageOption get defaultTarget => supportedLanguages.firstWhere(
    (LanguageOption language) =>
        language.translateLanguage == TranslateLanguage.german,
  );

  static const List<LanguageOption> supportedLanguages = <LanguageOption>[
    LanguageOption(
      label: 'English',
      translateLanguage: TranslateLanguage.english,
      defaultTtsLocale: 'en-US',
    ),
    LanguageOption(
      label: 'Turkish',
      translateLanguage: TranslateLanguage.turkish,
      defaultTtsLocale: 'tr-TR',
    ),
    LanguageOption(
      label: 'Spanish',
      translateLanguage: TranslateLanguage.spanish,
      defaultTtsLocale: 'es-ES',
    ),
    LanguageOption(
      label: 'French',
      translateLanguage: TranslateLanguage.french,
      defaultTtsLocale: 'fr-FR',
    ),
    LanguageOption(
      label: 'German',
      translateLanguage: TranslateLanguage.german,
      defaultTtsLocale: 'de-DE',
    ),
    LanguageOption(
      label: 'Italian',
      translateLanguage: TranslateLanguage.italian,
      defaultTtsLocale: 'it-IT',
    ),
    LanguageOption(
      label: 'Portuguese',
      translateLanguage: TranslateLanguage.portuguese,
      defaultTtsLocale: 'pt-PT',
    ),
    LanguageOption(
      label: 'Hindi',
      translateLanguage: TranslateLanguage.hindi,
      defaultTtsLocale: 'hi-IN',
    ),
    LanguageOption(
      label: 'Japanese',
      translateLanguage: TranslateLanguage.japanese,
      defaultTtsLocale: 'ja-JP',
    ),
    LanguageOption(
      label: 'Korean',
      translateLanguage: TranslateLanguage.korean,
      defaultTtsLocale: 'ko-KR',
    ),
  ];

  static LanguageOption fromLocaleTag(String? localeTag) {
    final normalizedTag = localeTag
        ?.replaceAll('_', '-')
        .toLowerCase()
        .split('-')
        .first;

    return supportedLanguages.firstWhere(
      (LanguageOption language) => language.bcpCode == normalizedTag,
      orElse: () => supportedLanguages.first,
    );
  }

  static LanguageOption defaultTargetFor(LanguageOption sourceLanguage) {
    if (sourceLanguage.translateLanguage == TranslateLanguage.english) {
      return defaultTarget;
    }

    if (sourceLanguage.translateLanguage == TranslateLanguage.german) {
      return defaultSource;
    }

    return defaultSource;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LanguageOption &&
            translateLanguage == other.translateLanguage &&
            label == other.label;
  }

  @override
  int get hashCode => Object.hash(label, translateLanguage);
}
