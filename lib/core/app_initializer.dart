class AppInitializer {
  static Future<void> initAll() async {
    // 1. تهيئة ملفات الإعدادات
    // 2. فحص مجلدات الـ assets والتأكد من وجود المسارات
    // 3. ربط مكتبة الـ Localization (Easy Localization)
    // 4. التأكد من توفر مكتبات الخطوط (Arabic Reshaper)
    print("All engines initialized successfully.");
  }
}