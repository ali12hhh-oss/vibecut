import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:flutter/material.dart';

class EngineText {
  static const String defaultFontFamily = 'Tajawal';

  String processArabic(String text) {
    if (text.trim().isEmpty) {
      return text;
    }
    return ArabicReshaper().reshape(text);
  }

  TextStyle getTextStyle({String fontFamily = defaultFontFamily, double size = 16.0}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
    );
  }
}
