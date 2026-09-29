import 'package:flutter/material.dart';

/// معرف انتقال + اسمه في FFmpeg xfade + أيقونة توضيحية (لا تُستخدم كنص ظاهر)
class TransitionPreset {
  final String id;
  final String ffmpegName;
  final IconData icon;

  const TransitionPreset({required this.id, required this.ffmpegName, required this.icon});
}

final List<TransitionPreset> transitionPresets = [
  const TransitionPreset(id: 'fade', ffmpegName: 'fade', icon: Icons.blur_on),
  const TransitionPreset(id: 'slide_left', ffmpegName: 'slideleft', icon: Icons.arrow_back),
  const TransitionPreset(id: 'slide_right', ffmpegName: 'slideright', icon: Icons.arrow_forward),
  const TransitionPreset(id: 'wipe_left', ffmpegName: 'wipeleft', icon: Icons.swipe),
  const TransitionPreset(id: 'zoom_in', ffmpegName: 'zoomin', icon: Icons.zoom_in),
  const TransitionPreset(id: 'circle_open', ffmpegName: 'circleopen', icon: Icons.lens_blur),
];
