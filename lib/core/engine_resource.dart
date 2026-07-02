import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class EngineResource {
  // دالة لجلب مسار مجلد التحميلات الخارجي
  Future<String> getDownloadPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/downloads';
    final folder = Directory(path);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return path;
  }

  // دالة لجلب المسار الصحيح لأي مورد (تأثير، انتقال، إلخ)
  Future<String> getResourcePath(String folderPath, String fileName) async {
    String localPath = 'assets/core/$folderPath/$fileName';
    
    try {
      // محاولة التحقق من وجود الملف في المسار الأساسي (Offline)
      await rootBundle.load(localPath);
      return localPath;
    } catch (e) {
      // إذا لم يوجد، نعود بمسار المجلد الخارجي (Downloads)
      String downloadPath = await getDownloadPath();
      return '$downloadPath/$folderPath/$fileName';
    }
  }
}