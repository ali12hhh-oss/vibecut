import 'package:flutter/material.dart';

/// لوحة تحكم بسرعة المقطع: شريط تمرير بين أيقونتي بطيء/سريع
class SpeedPanel extends StatefulWidget {
  final double initialSpeed;
  final ValueChanged<double> onChanged;

  const SpeedPanel({super.key, required this.initialSpeed, required this.onChanged});

  @override
  State<SpeedPanel> createState() => _SpeedPanelState();
}

class _SpeedPanelState extends State<SpeedPanel> {
  late double _speed = widget.initialSpeed;

  static const List<double> _ticks = [0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0];

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
            Text(
              '${_speed.toStringAsFixed(_ticks.contains(_speed) && _speed == _speed.roundToDouble() ? 0 : 2)}x',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.slow_motion_video, color: Colors.white54, size: 22),
                Expanded(
                  child: Slider(
                    value: _speed,
                    min: 0.25,
                    max: 4.0,
                    divisions: 15,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                    onChanged: (v) {
                      setState(() => _speed = v);
                      widget.onChanged(v);
                    },
                  ),
                ),
                const Icon(Icons.fast_forward, color: Colors.white54, size: 22),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _ticks.map((t) {
                  final selected = (t - _speed).abs() < 0.05;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _speed = t);
                      widget.onChanged(t);
                    },
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? Colors.white : Colors.white24,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
