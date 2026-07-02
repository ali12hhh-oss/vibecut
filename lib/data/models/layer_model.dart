class LayerModel {
  final String id;
  final String path;
  final Duration startTime;
  final Duration duration;

  LayerModel({
    required this.id, 
    required this.path, 
    required this.startTime, 
    required this.duration,
  });
}