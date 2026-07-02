import 'engine_command.dart';
import 'engine_timeline.dart';

class EngineProcessor {
  final EngineCommand _command = EngineCommand();
  final EngineTimeline _timeline;

  EngineProcessor(this._timeline);

  /// دالة المعالجة الرئيسية
  Future<void> processProject(String outputPath) async {
    List<TimelineSegment> segments = _timeline.segments;

    if (segments.isEmpty) return;

    print("بدء معالجة المشروع: ${segments.length} مقاطع");

    // هنا نقوم بإنشاء سلسلة الأوامر
    // في النسخة القادمة سنربط هذه الدالة بـ FFmpegKit
    for (int i = 0; i < segments.length; i++) {
      var segment = segments[i];
      print("معالجة المقطع ${i + 1}: ${segment.videoPath}");
      
      if (segment.transitionPath != null) {
        print("تطبيق انتقال: ${segment.transitionPath}");
        // سيتم استدعاء buildTransitionCommand هنا لاحقاً
      }
    }

    print("اكتملت المعالجة بنجاح في: $outputPath");
  }
}