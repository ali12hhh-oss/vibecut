import 'package:flutter/material.dart';

/// لوحة تحكم التمويه/الضبابية للمقطع المحدد
class BlurPanel extends StatefulWidget {
  final double initialBlur;
  final ValueChanged<double> onChanged;

  const BlurPanel({super.key, required this.initialBlur, required this.onChanged});

  @override
  State<BlurPanel> createState() => _BlurPanelState();
}

class _BlurPanelState extends State<BlurPanel> {
  late double _blur = widget.initialBlur;

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
                const Icon(Icons.crop_original, color: Colors.white54, size: 20),
                Expanded(
                  child: Slider(
                    value: _blur,
                    min: 0.0,
                    max: 20.0,
                    divisions: 20,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                    onChanged: (v) {
                      setState(() => _blur = v);
                      widget.onChanged(v);
                    },
                  ),
                ),
                const Icon(Icons.blur_on, color: Colors.white70, size: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
