import 'package:flutter/material.dart';
import '../../core/models/text_style_preset.dart';

/// لوحة اختيار شكل النص: تعرض النص الذي كتبه المستخدم فعلاً بكل نمط، بلا أي اسم
class TextStylePanel extends StatelessWidget {
  final String sampleText;

  const TextStylePanel({super.key, required this.sampleText});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 130,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: textStylePresets.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final preset = textStylePresets[index];
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(preset.id),
              child: Container(
                constraints: const BoxConstraints(minWidth: 80, maxWidth: 140),
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: preset.padding,
                  color: preset.backgroundColor,
                  child: Text(
                    sampleText,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: preset.style,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
