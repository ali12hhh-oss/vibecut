import 'package:flutter/material.dart';
import '../../core/models/transition_type.dart';
import 'transition_preview_tile.dart';

/// لوحة اختيار الانتقالات: معاينات حية متحركة توضح نوع الانتقال، بلا أي أسماء
class TransitionPanel extends StatelessWidget {
  final String? selectedTransitionId;
  final ValueChanged<String?> onSelect;

  const TransitionPanel({super.key, required this.selectedTransitionId, required this.onSelect});

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
          itemCount: transitionPresets.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return TransitionPreviewTile(
                preset: null,
                isSelected: selectedTransitionId == null,
                onTap: () => onSelect(null),
              );
            }
            final preset = transitionPresets[index - 1];
            return TransitionPreviewTile(
              preset: preset,
              isSelected: selectedTransitionId == preset.id,
              onTap: () => onSelect(preset.id),
            );
          },
        ),
      ),
    );
  }
}
