import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/engine_processor.dart';
import '../../core/engine_timeline.dart';

abstract class EditorState {
  const EditorState();
}

class EditorInitial extends EditorState {
  const EditorInitial();
}

class EditorReady extends EditorState {
  const EditorReady();
}

class EditorProcessing extends EditorState {
  const EditorProcessing();
}

class EditorSuccess extends EditorState {
  const EditorSuccess(this.outputPath);

  final String outputPath;
}

class EditorFailure extends EditorState {
  const EditorFailure(this.message);

  final String message;
}

class EditorCubit extends Cubit<EditorState> {
  EditorCubit(this._timeline, this._processor) : super(const EditorInitial());

  final EngineTimeline _timeline;
  final EngineProcessor _processor;

  void createSampleProject() {
    _timeline.clearTimeline();
    addVideo(
      path: 'sample://intro',
      duration: 4,
      label: 'مقدمة المشروع',
    );
  }

  void addSampleClip() {
    addVideo(
      path: 'sample://clip-${_timeline.segments.length + 1}',
      duration: 5,
      label: 'مقطع عينة ${_timeline.segments.length + 1}',
    );
  }

  void addVideo({required String path, required double duration, String? label}) {
    _timeline.addSegment(
      TimelineSegment(
        videoPath: path,
        duration: duration,
        label: label ?? path.split('/').last,
      ),
    );
    emit(const EditorReady());
  }

  Future<void> exportToDefaultLocation() async {
    final directory = await getApplicationDocumentsDirectory();
    final outputPath = '${directory.path}/vibecut_export_${DateTime.now().millisecondsSinceEpoch}.mp4';
    await exportVideo(outputPath);
  }

  Future<void> exportVideo(String outputPath) async {
    emit(const EditorProcessing());
    try {
      final exportedPath = await _processor.processProject(outputPath);
      emit(EditorSuccess(exportedPath));
    } catch (error) {
      emit(EditorFailure('تعذر تصدير الفيديو: $error'));
    }
  }

  List<TimelineSegment> get currentSegments => List.unmodifiable(_timeline.segments);

  double get totalDuration => _timeline.totalDuration;
}
