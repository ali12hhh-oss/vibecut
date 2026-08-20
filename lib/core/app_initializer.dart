import 'package:flutter/foundation.dart';

class AppInitializer {
  static Future<void> initAll() async {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };
  }
}
