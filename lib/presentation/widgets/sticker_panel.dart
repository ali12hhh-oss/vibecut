import 'package:flutter/material.dart';
import '../../core/models/sticker_assets.dart';

/// شبكة ملصقات حقيقية (صور فعلية)، بلا أي أسماء نصية تحتها
class StickerPanel extends StatelessWidget {
  final ValueChanged<String> onSelect;

  const StickerPanel({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 260,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(14),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: stickerAssetPaths.length,
          itemBuilder: (context, index) {
            final path = stickerAssetPaths[index];
            return GestureDetector(
              onTap: () {
                onSelect(path);
                Navigator.of(context).maybePop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(path, fit: BoxFit.contain),
              ),
            );
          },
        ),
      ),
    );
  }
}
