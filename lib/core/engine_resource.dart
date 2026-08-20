import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class EngineResource {
  Future<String> getDownloadPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/downloads';
    final folder = Directory(path);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return path;
  }

  Future<String?> getBundledAssetPath(String folderPath, String fileName) async {
    if (fileName.trim().isEmpty) {
      return null;
    }

    final localPath = 'assets/core/$folderPath/$fileName';
    try {
      await rootBundle.load(localPath);
      return localPath;
    } catch (_) {
      return null;
    }
  }

  Future<String> getDownloadedResourcePath(String folderPath, String fileName) async {
    final downloadPath = await getDownloadPath();
    return '$downloadPath/$folderPath/$fileName';
  }

  Future<String> getResourcePath(String folderPath, String fileName) async {
    final bundledAsset = await getBundledAssetPath(folderPath, fileName);
    if (bundledAsset != null) {
      return bundledAsset;
    }
    return getDownloadedResourcePath(folderPath, fileName);
  }
}
