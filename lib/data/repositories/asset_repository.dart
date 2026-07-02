import 'dart:io';
import 'package:flutter/services.dart';

class AssetRepository {
  
  /// جلب قائمة أسماء الملفات من مجلد محدد داخل assets
  Future<List<String>> getLocalAssets(String assetPath) async {
    try {
      // ملاحظة: في Flutter، لا يمكن قراءة مجلد assets مباشرة كملف نظام،
      // لذا نستخدم 'AssetManifest' لجلب أسماء الملفات المسجلة
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = Uri.decodeComponent(manifestContent) as Map<String, dynamic>;
      
      return manifestMap.keys
          .where((key) => key.startsWith(assetPath))
          .map((key) => key.split('/').last)
          .toList();
    } catch (e) {
      print("Error loading assets: $e");
      return [];
    }
  }

  /// جلب قائمة الملفات التي حملها المستخدم (Downloads)
  Future<List<String>> getDownloadedAssets(String folderName) async {
    final directory = Directory(folderName);
    if (await directory.exists()) {
      return directory.listSync()
          .where((item) => item is File)
          .map((item) => item.path.split('/').last)
          .toList();
    }
    return [];
  }
}