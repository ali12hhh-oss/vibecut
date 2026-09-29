import 'package:flutter/material.dart';

/// لوحة تحكم بالشفافية (للملصقات/الصور/PIP)، مع معاينة فورية لأن المعاينة تتحدث فوراً في المشروع
class OpacityPanel extends StatefulWidget {
  final double initialOpacity;
  final ValueChanged<double> onChanged;

  const OpacityPanel({super.key, required this.initialOpacity, required this.onChanged});

  @override
  State<OpacityPanel> createState() => _OpacityPanelState();
}

class _OpacityPanelState extends State<OpacityPanel> {
  late double _opacity = widget.initialOpacity;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 4, 12, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Row(
              children: [
                const Icon(Icons.opacity, color: Colors.white54, size: 20),
                Expanded(
                  child: Slider(
                    value: _opacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                    onChanged: (v) {
                      setState(() => _opacity = v);
                      widget.onChanged(v);
                    },
                  ),
                ),
                const Icon(Icons.circle, color: Colors.white, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
