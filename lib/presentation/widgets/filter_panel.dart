import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/models/video_filter.dart';

/// لوحة اختيار الفلاتر: معاينات حية حقيقية للإطار الفعلي للفيديو مع كل فلتر، بلا أي أسماء نصية ظاهرة
class FilterPanel extends StatelessWidget {
  final VideoPlayerController? controller;
  final String? selectedFilterId;
  final ValueChanged<String?> onSelect;

  const FilterPanel({
    super.key,
    required this.controller,
    required this.selectedFilterId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 120,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: videoFilterPresets.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final preset = videoFilterPresets[index];
            final isOriginal = preset.id == 'original';
            final isSelected = (selectedFilterId == null && isOriginal) || selectedFilterId == preset.id;

            return GestureDetector(
              onTap: () => onSelect(isOriginal ? null : preset.id),
              child: Container(
                width: 64,
                height: 64,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.white24,
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: (controller != null && controller!.value.isInitialized)
                    ? ColorFiltered(
                        colorFilter: ColorFilter.matrix(preset.matrix),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: controller!.value.size.width == 0 ? 100 : controller!.value.size.width,
                            height: controller!.value.size.height == 0 ? 100 : controller!.value.size.height,
                            child: VideoPlayer(controller!),
                          ),
                        ),
                      )
                    : Container(color: Colors.black26),
              ),
            );
          },
        ),
      ),
    );
  }
}
