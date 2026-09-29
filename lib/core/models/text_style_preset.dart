import 'package:flutter/material.dart';

/// نمط شكل جاهز للنص يُعاين بالنص الفعلي الذي كتبه المستخدم
class TextStylePreset {
  final String id;
  final TextStyle style;
  final Color? backgroundColor;
  final EdgeInsets padding;

  const TextStylePreset({
    required this.id,
    required this.style,
    this.backgroundColor,
    this.padding = EdgeInsets.zero,
  });
}

final List<TextStylePreset> textStylePresets = [
  const TextStylePreset(
    id: 'classic',
    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
    backgroundColor: Colors.black,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  ),
  const TextStylePreset(
    id: 'bold_yellow',
    style: TextStyle(color: Color(0xFFFFD400), fontSize: 22, fontWeight: FontWeight.w900),
  ),
  const TextStylePreset(
    id: 'outline',
    style: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(offset: Offset(-1, -1), color: Colors.black),
        Shadow(offset: Offset(1, -1), color: Colors.black),
        Shadow(offset: Offset(-1, 1), color: Colors.black),
        Shadow(offset: Offset(1, 1), color: Colors.black),
      ],
    ),
  ),
  const TextStylePreset(
    id: 'neon',
    style: TextStyle(
      color: Color(0xFF00F0FF),
      fontSize: 20,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(color: Color(0xFF00F0FF), blurRadius: 12),
        Shadow(color: Color(0xFF00F0FF), blurRadius: 20),
      ],
    ),
  ),
  const TextStylePreset(
    id: 'soft_pink_box',
    style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
    backgroundColor: Color(0xFFFFC1D9),
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  ),
];
