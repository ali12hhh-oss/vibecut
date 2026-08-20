import 'package:shared_preferences/shared_preferences.dart';

class EngineSettings {
  static const _languageKey = 'lang';
  static const _fontKey = 'font';

  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, langCode);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'ar';
  }

  Future<void> setFont(String fontName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontKey, fontName);
  }

  Future<String> getFont() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fontKey) ?? 'Tajawal';
  }
}
