import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/engine_timeline.dart';
import '../../core/engine_processor.dart';

// حالات التطبيق (States)
abstract class EditorState {}
class EditorInitial extends EditorState {}
class EditorProcessing extends EditorState {}
class EditorSuccess extends EditorState {}

class EditorCubit extends Cubit<EditorState> {
  final EngineTimeline _timeline;
  final EngineProcessor _processor;

  EditorCubit(this._timeline, this._processor) : super(EditorInitial());

  /// إضافة فيديو جديد للتايم لاين
  void addVideo(String path, double duration) {
    _timeline.addSegment(TimelineSegment(videoPath: path, duration: duration));
    emit(EditorInitial()); // تحديث الواجهة
  }

  /// تنفيذ عملية تصدير الفيديو (المونتاج النهائي)
  Future<void> exportVideo(String outputPath) async {
    emit(EditorProcessing());
    try {
      await _processor.processProject(outputPath);
      emit(EditorSuccess());
    } catch (e) {
      emit(EditorInitial()); // العودة للحالة الأصلية عند الخطأ
    }
  }

  // الحصول على المقاطع الحالية لعرضها في الشاشة
  List<TimelineSegment> get currentSegments => _timeline.segments;
}