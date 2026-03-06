enum Language {
  english(name: 'English', flag: '🇺🇸', code: 'en'),
  french(name: 'Français', flag: '🇫🇷', code: 'fr');

  // Constructor must be const for enums
  const Language({required this.name, required this.flag, required this.code});

  final String name;
  final String flag;
  final String code;
  static Language fromCode(String code) {
    switch (code) {
      case 'en':
        return Language.english;
      case 'fr':
        return Language.french;
      default:
        return Language.english;
    }
  }
}
