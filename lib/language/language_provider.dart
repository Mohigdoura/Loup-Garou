import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/language/language.dart';
import 'package:loup_garou/providers/shared_prefs_provider.dart';

final languageProvider = NotifierProvider<LanguageNotifier, Language>(() {
  return LanguageNotifier();
});

class LanguageNotifier extends Notifier<Language> {
  static const String _languageKey = 'language';

  @override
  Language build() {
    final prefs = ref.read(sharedPrefsProvider);

    // Fall back to device language instead of hardcoded 'en'
    final deviceLocale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final languageCode = prefs.getString(_languageKey) ?? deviceLocale;

    return Language.fromCode(languageCode);
  }

  Future<void> setLanguage(Language language) async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_languageKey, language.code);
    state = language;
  }
}
