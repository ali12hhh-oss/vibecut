import 'package:flutter/material.dart';

class TextEffects {
  // تأثير نار بسيط للنصوص
  static Shader fireShader(Rect bounds) {
    return LinearGradient(
      colors: [Colors.red, Colors.orange, Colors.yellow],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ).createShader(bounds);
  }
}