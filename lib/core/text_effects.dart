import 'package:flutter/material.dart';

class TextEffects {
  static Shader fireShader(Rect bounds) {
    return const LinearGradient(
      colors: [Colors.red, Colors.orange, Colors.yellow],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ).createShader(bounds);
  }
}
