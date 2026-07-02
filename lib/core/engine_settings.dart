import 'package:shared_preferences/shared_preferences.dart';

class EngineSettings {
  // حفظ اللغة المستخدمة
  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', langCode);
  }

  // استرجاع اللغة
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lang') ?? 'en';
  }

  // حفظ الخط المختار
  Future<void> setFont(String fontName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('font', fontName);
  }
}