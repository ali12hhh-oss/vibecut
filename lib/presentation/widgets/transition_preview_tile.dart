import 'package:flutter/material.dart';
import '../../core/models/transition_type.dart';

/// يعرض معاينة حية متكررة (مربعان ملونان) توضح فعلياً شكل حركة الانتقال، بلا أي نص
class TransitionPreviewTile extends StatefulWidget {
  final TransitionPreset? preset; // null = قطع مباشر
  final bool isSelected;
  final VoidCallback onTap;

  const TransitionPreviewTile({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<TransitionPreviewTile> createState() => _TransitionPreviewTileState();
}

class _TransitionPreviewTileState extends State<TransitionPreviewTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedDemo() {
    final preset = widget.preset;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final raw = _controller.value;
        final t = raw < 0.5 ? (raw * 2) : (1 - (raw - 0.5) * 2);

        if (preset == null) {
          final showSecond = raw >= 0.5;
          return Container(color: showSecond ? const Color(0xFFFFB020) : const Color(0xFF3D7EFF));
        }

        switch (preset.id) {
          case 'fade':
            return Stack(
              children: [
                Container(color: const Color(0xFF3D7EFF)),
                Opacity(opacity: t, child: Container(color: const Color(0xFFFFB020))),
              ],
            );
          case 'slide_left':
            return ClipRect(
              child: Stack(
                children: [
                  Container(color: const Color(0xFF3D7EFF)),
                  FractionalTranslation(
                    translation: Offset(1 - t, 0),
                    child: Container(color: const Color(0xFFFFB020)),
                  ),
                ],
              ),
            );
          case 'slide_right':
            return ClipRect(
              child: Stack(
                children: [
                  Container(color: const Color(0xFF3D7EFF)),
                  FractionalTranslation(
                    translation: Offset(-(1 - t), 0),
                    child: Container(color: const Color(0xFFFFB020)),
                  ),
                ],
              ),
            );
          case 'wipe_left':
            return ClipRect(
              child: Stack(
                children: [
                  Container(color: const Color(0xFF3D7EFF)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: t.clamp(0.001, 1.0),
                      heightFactor: 1,
                      child: Container(color: const Color(0xFFFFB020)),
                    ),
                  ),
                ],
              ),
            );
          case 'zoom_in':
            return Stack(
              children: [
                Container(color: const Color(0xFF3D7EFF)),
                Opacity(
                  opacity: t,
                  child: Transform.scale(
                    scale: 0.4 + (t * 0.6),
                    child: Container(color: const Color(0xFFFFB020)),
                  ),
                ),
              ],
            );
          case 'circle_open':
            return ClipRect(
              child: Stack(
                children: [
                  Container(color: const Color(0xFF3D7EFF)),
                  Center(
                    child: Transform.scale(
                      scale: t * 1.8,
                      child: ClipOval(
                        child: Container(width: 64, height: 64, color: const Color(0xFFFFB020)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          default:
            return Container(color: const Color(0xFF3D7EFF));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 64,
        height: 64,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isSelected ? Colors.white : Colors.white24,
            width: widget.isSelected ? 2.5 : 1,
          ),
        ),
        child: _buildAnimatedDemo(),
      ),
    );
  }
}
