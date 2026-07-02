class TimelineSegment {
  final String videoPath;
  final String? transitionPath;
  final double startTime;
  final double duration;

  TimelineSegment({
    required this.videoPath,
    this.transitionPath,
    this.startTime = 0.0,
    required this.duration,
  });
}

class EngineTimeline {
  List<TimelineSegment> _segments = [];

  // إضافة مقطع جديد للتايم لاين
  void addSegment(TimelineSegment segment) {
    _segments.add(segment);
  }

  // حذف مقطع
  void removeSegment(int index) {
    if (index >= 0 && index < _segments.length) {
      _segments.removeAt(index);
    }
  }

  // الحصول على كل المقاطع الحالية
  List<TimelineSegment> get segments => _segments;

  // مسح التايم لاين بالكامل
  void clearTimeline() {
    _segments.clear();
  }

  // حساب إجمالي مدة المشروع بناءً على كل المقاطع
  double get totalDuration {
    return _segments.fold(0.0, (sum, item) => sum + item.duration);
  }
}