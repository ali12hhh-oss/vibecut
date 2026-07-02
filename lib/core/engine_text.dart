import 'package:flutter/material.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';

class EngineText {
  static const String defaultFont = 'assets/core/fonts/Roboto-Regular.ttf';

  String processArabic(String text) {
    return ArabicReshaper().reshape(text);
  }

  TextStyle getTextStyle({required String fontPath, double size = 16.0}) {
    return TextStyle(
      fontFamily: fontPath,
      fontSize: size,
    );
  }
}