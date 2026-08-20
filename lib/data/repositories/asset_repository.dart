import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class AssetRepository {
  Future<List<String>> getLocalAssets(String assetPath) async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifestMap = jsonDecode(manifestContent) as Map<String, dynamic>;

      return manifestMap.keys
          .where((key) => key.startsWith(assetPath))
          .map((key) => key.split('/').last)
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> getDownloadedAssets(String folderName) async {
    final directory = Directory(folderName);
    if (!await directory.exists()) {
      return [];
    }

    return directory
        .listSync()
        .whereType<File>()
        .map((item) => item.path.split(Platform.pathSeparator).last)
        .toList()
      ..sort();
  }
}
