import 'package:flutter/material.dart';
import '../../core/engine_timeline.dart';

/// عرض متعدد المسارات للتايم لاين مع إمكانية المس للاختيار ورأس تشغيل مرئي
class TimelineView extends StatelessWidget {
  static const double pixelsPerSecond = 60.0;
  static const double trackHeight = 44.0;

  final EngineTimeline timeline;
  final double position;
  final String? selectedClipId;
  final ValueChanged<String> onClipTap;
  final ValueChanged<double> onSeek;

  const TimelineView({
    super.key,
    required this.timeline,
    required this.position,
    required this.selectedClipId,
    required this.onClipTap,
    required this.onSeek,
  });

  Color _colorForType(ClipType type) {
    switch (type) {
      case ClipType.video:
        return const Color(0xFF3D7EFF);
      case ClipType.audio:
        return const Color(0xFF32C48D);
      case ClipType.text:
        return const Color(0xFFFFB020);
      case ClipType.image:
      case ClipType.sticker:
        return const Color(0xFFC24DFF);
      case ClipType.pip:
        return const Color(0xFFFF6B6B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalWidth = (timeline.totalDuration + 5) * pixelsPerSecond;

    return Container(
      color: const Color(0xFF121212),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: GestureDetector(
          onTapUp: (details) {
            final seconds = details.localPosition.dx / pixelsPerSecond;
            onSeek(seconds.clamp(0.0, timeline.totalDuration));
          },
          child: SizedBox(
            width: totalWidth < 300.0 ? 300.0 : totalWidth,
            child: Stack(
              children: [
                Column(
                  children: timeline.tracks.map((track) {
                    return SizedBox(
                      height: trackHeight,
                      child: Stack(
                        children: track.clips.map((clip) {
                          final widthPx = clip.duration * pixelsPerSecond;
                          return Positioned(
                            left: clip.startOnTrack * pixelsPerSecond,
                            width: widthPx < 4.0 ? 4.0 : widthPx,
                            top: 2,
                            bottom: 2,
                            child: GestureDetector(
                              onTap: () => onClipTap(clip.id),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _colorForType(clip.type),
                                  border: Border.all(
                                    color: selectedClipId == clip.id ? Colors.white : Colors.black26,
                                    width: selectedClipId == clip.id ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: clip.type == ClipType.text
                                    ? Text(
                                        clip.text ?? '',
                                        style: const TextStyle(color: Colors.black87, fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
                Positioned(
                  left: position * pixelsPerSecond,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 2, color: Colors.redAccent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
