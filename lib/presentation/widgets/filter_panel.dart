import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/models/video_filter.dart';

/// لوحة اختيار الفلاتر: تستخدم لقطة ثابتة ملتقطة من المعاينة (لا تكرر Texture حية متعددة لضمان الاستقرار)
class FilterPanel extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? selectedFilterId;
  final ValueChanged<String?> onSelect;

  const FilterPanel({
    super.key,
    required this.imageBytes,
    required this.selectedFilterId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 156,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  tooltip: 'إغلاق',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: videoFilterPresets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final preset = videoFilterPresets[index];
                  final isOriginal = preset.id == 'original';
                  final isSelected =
                      (selectedFilterId == null && isOriginal) || selectedFilterId == preset.id;

                  return GestureDetector(
                    onTap: () => onSelect(isOriginal ? null : preset.id),
                    child: Container(
                      width: 64,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white24,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: imageBytes != null
                          ? ColorFiltered(
                              colorFilter: ColorFilter.matrix(preset.matrix),
                              child: Image.memory(imageBytes!, fit: BoxFit.cover),
                            )
                          : Container(color: Colors.black26),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
