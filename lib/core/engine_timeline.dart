class TimelineSegment {
  TimelineSegment({
    required this.videoPath,
    required this.duration,
    this.label,
    this.transitionPath,
    this.startTime = 0.0,
  })  : assert(duration > 0, 'duration must be greater than zero'),
        assert(startTime >= 0, 'startTime cannot be negative');

  final String videoPath;
  final String? label;
  final String? transitionPath;
  final double startTime;
  final double duration;

  bool get isSample => videoPath.startsWith('sample://');

  String get displayName => label?.trim().isNotEmpty == true ? label!.trim() : videoPath.split('/').last;
}

class EngineTimeline {
  final List<TimelineSegment> _segments = [];

  void addSegment(TimelineSegment segment) {
    _segments.add(segment);
  }

  void removeSegment(int index) {
    if (index >= 0 && index < _segments.length) {
      _segments.removeAt(index);
    }
  }

  List<TimelineSegment> get segments => List.unmodifiable(_segments);

  void clearTimeline() {
    _segments.clear();
  }

  double get totalDuration {
    return _segments.fold(0.0, (sum, item) => sum + item.duration);
  }
}
