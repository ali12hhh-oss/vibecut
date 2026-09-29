import 'package:flutter/painting.dart';

/// فلتر لون جاهز للمعاينة الحية (مصفوفة ألوان Flutter) وللتصدير النهائي (مرشح FFmpeg مقابل)
class VideoFilterPreset {
  final String id;
  final String label; // للوصولية فقط، لا يظهر كنص دائم في الواجهة
  final List<double> matrix;
  final String? ffmpegFilter;

  const VideoFilterPreset({
    required this.id,
    required this.label,
    required this.matrix,
    this.ffmpegFilter,
  });
}

const List<double> _identityMatrix = [
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 1, 0, //
];

final List<VideoFilterPreset> videoFilterPresets = [
  const VideoFilterPreset(id: 'original', label: 'الأصلي', matrix: _identityMatrix),
  const VideoFilterPreset(
    id: 'bw',
    label: 'أبيض وأسود',
    matrix: [
      0.33, 0.59, 0.11, 0, 0, //
      0.33, 0.59, 0.11, 0, 0, //
      0.33, 0.59, 0.11, 0, 0, //
      0, 0, 0, 1, 0, //
    ],
    ffmpegFilter: 'hue=s=0',
  ),
  const VideoFilterPreset(
    id: 'sepia',
    label: 'سيبيا',
    matrix: [
      0.393, 0.769, 0.189, 0, 0, //
      0.349, 0.686, 0.168, 0, 0, //
      0.272, 0.534, 0.131, 0, 0, //
      0, 0, 0, 1, 0, //
    ],
    ffmpegFilter: 'colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131:0',
  ),
  const VideoFilterPreset(
    id: 'vivid',
    label: 'حيوي',
    matrix: [
      1.3, -0.1, -0.1, 0, 0, //
      -0.1, 1.3, -0.1, 0, 0, //
      -0.1, -0.1, 1.3, 0, 0, //
      0, 0, 0, 1, 0, //
    ],
    ffmpegFilter: 'eq=saturation=1.5:contrast=1.15',
  ),
  const VideoFilterPreset(
    id: 'cool',
    label: 'بارد',
    matrix: [
      0.9, 0, 0, 0, 0, //
      0, 1.0, 0, 0, 0, //
      0, 0, 1.2, 0, 10, //
      0, 0, 0, 1, 0, //
    ],
    ffmpegFilter: 'colorbalance=bs=0.2:ms=0.1',
  ),
  const VideoFilterPreset(
    id: 'warm',
    label: 'دافئ',
    matrix: [
      1.2, 0, 0, 0, 10, //
      0, 1.05, 0, 0, 0, //
      0, 0, 0.85, 0, 0, //
      0, 0, 0, 1, 0, //
    ],
    ffmpegFilter: 'colorbalance=rs=0.2:ys=0.1',
  ),
  const VideoFilterPreset(
    id: 'fade',
    label: 'باهت',
    matrix: [
      0.9, 0.05, 0.05, 0, 15, //
      0.05, 0.9, 0.05, 0, 15, //
      0.05, 0.05, 0.9, 0, 15, //
      0, 0, 0, 1, 0, //
    ],
    ffmpegFilter: 'eq=saturation=0.7:brightness=0.05:contrast=0.9',
  ),
  const VideoFilterPreset(
    id: 'noir',
    label: 'نوار',
    matrix: [
      0.33, 0.59, 0.11, 0, -20, //
      0.33, 0.59, 0.11, 0, -20, //
      0.33, 0.59, 0.11, 0, -20, //
      0, 0, 0, 1, 0, //
    ],
    ffmpegFilter: 'hue=s=0,eq=contrast=1.3:brightness=-0.08',
  ),
];
