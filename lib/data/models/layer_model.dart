enum LayerType { video, audio, text, sticker, overlay, adjustment }

class LayerModel {
  const LayerModel({
    required this.id,
    required this.type,
    required this.path,
    required this.startTime,
    required this.duration,
    this.name,
    this.opacity = 1,
    this.isLocked = false,
  });

  final String id;
  final LayerType type;
  final String path;
  final Duration startTime;
  final Duration duration;
  final String? name;
  final double opacity;
  final bool isLocked;
}
