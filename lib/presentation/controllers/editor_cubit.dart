import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../core/engine_processor.dart';
import '../../core/engine_timeline.dart';

enum ExportStatus { idle, exporting, success, error }

class EditorState {
  final int revision;
  final double position;
  final bool isPlaying;
  final String? selectedClipId;
  final ExportStatus exportStatus;
  final String? exportedPath;
  final String? errorMessage;

  const EditorState({
    required this.revision,
    required this.position,
    required this.isPlaying,
    this.selectedClipId,
    required this.exportStatus,
    this.exportedPath,
    this.errorMessage,
  });

  factory EditorState.initial() => const EditorState(
        revision: 0,
        position: 0.0,
        isPlaying: false,
        exportStatus: ExportStatus.idle,
      );

  EditorState copyWith({
    int? revision,
    double? position,
    bool? isPlaying,
    String? selectedClipId,
    bool clearSelection = false,
    ExportStatus? exportStatus,
    String? exportedPath,
    String? errorMessage,
  }) {
    return EditorState(
      revision: revision ?? this.revision,
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
      selectedClipId: clearSelection ? null : (selectedClipId ?? this.selectedClipId),
      exportStatus: exportStatus ?? this.exportStatus,
      exportedPath: exportedPath ?? this.exportedPath,
      errorMessage: errorMessage,
    );
  }
}

class EditorCubit extends Cubit<EditorState> {
  final EngineTimeline timeline = EngineTimeline();
  final EngineProcessor _processor = EngineProcessor();
  final ImagePicker _picker = ImagePicker();

  Timer? _playbackTimer;
  DateTime? _lastTick;

  VideoPlayerController? _activeController;
  String? _activeControllerClipId;

  VideoPlayerController? get activeController => _activeController;

  EditorCubit() : super(EditorState.initial());

  void _bump({
    double? position,
    bool? isPlaying,
    String? selectedClipId,
    bool clearSelection = false,
  }) {
    emit(state.copyWith(
      revision: state.revision + 1,
      position: position,
      isPlaying: isPlaying,
      selectedClipId: selectedClipId,
      clearSelection: clearSelection,
    ));
    _syncActiveController();
  }

  Future<void> _syncActiveController() async {
    final clip = timeline.activeClipOnTrack(ClipType.video, state.position);

    if (clip == null || clip.sourcePath == null) {
      await _activeController?.pause();
      return;
    }

    if (clip.id != _activeControllerClipId) {
      _activeControllerClipId = clip.id;
      final oldController = _activeController;
      final newController = VideoPlayerController.file(File(clip.sourcePath!));
      _activeController = newController;
      try {
        await newController.initialize();
        final offset = (state.position - clip.startOnTrack) + clip.trimStart;
        await newController.seekTo(Duration(milliseconds: (offset * 1000).round()));
        if (state.isPlaying) await newController.play();
      } catch (_) {
        // تجاهل أخطاء تهيئة الفيديو الفردية
      }
      await oldController?.dispose();
      if (!isClosed) emit(state.copyWith(revision: state.revision + 1));
    } else {
      final controller = _activeController;
      if (controller != null && controller.value.isInitialized) {
        final offset = (state.position - clip.startOnTrack) + clip.trimStart;
        final currentMs = controller.value.position.inMilliseconds;
        final targetMs = (offset * 1000).round();
        if (!state.isPlaying || (currentMs - targetMs).abs() > 400) {
          await controller.seekTo(Duration(milliseconds: targetMs));
        }
        if (state.isPlaying && !controller.value.isPlaying) {
          await controller.play();
        } else if (!state.isPlaying && controller.value.isPlaying) {
          await controller.pause();
        }
      }
    }
  }

  Future<void> pickAndAddVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    final probe = VideoPlayerController.file(File(picked.path));
    await probe.initialize();
    final duration = probe.value.duration.inMilliseconds / 1000.0;
    await probe.dispose();

    timeline.addVideoClip(path: picked.path, sourceDuration: duration);
    _bump();
  }

  void addTextClip(String text, {String? styleId}) {
    final endOfTimeline = timeline.totalDuration;
    timeline.addTextClip(
      text: text,
      duration: 3.0,
      startOnTrack: state.position.clamp(0.0, endOfTimeline),
      styleId: styleId,
    );
    _bump();
  }

  void addStickerClip(String assetPath) {
    final endOfTimeline = timeline.totalDuration;
    timeline.addStickerClip(
      assetPath: assetPath,
      duration: 3.0,
      startOnTrack: state.position.clamp(0.0, endOfTimeline),
    );
    _bump();
  }

  void selectClip(String? clipId) {
    _bump(selectedClipId: clipId, clearSelection: clipId == null);
  }

  void seekTo(double position) {
    final clamped = position.clamp(0.0, timeline.totalDuration);
    _bump(position: clamped);
  }

  void togglePlay() {
    final playing = !state.isPlaying;
    _bump(isPlaying: playing);

    _playbackTimer?.cancel();
    if (playing) {
      _lastTick = DateTime.now();
      _playbackTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
        final now = DateTime.now();
        final delta = now.difference(_lastTick ?? now).inMilliseconds / 1000.0;
        _lastTick = now;
        _advancePlayback(delta);
      });
    }
  }

  void _advancePlayback(double deltaSeconds) {
    if (!state.isPlaying) return;
    final total = timeline.totalDuration;
    final next = state.position + deltaSeconds;
    if (next >= total) {
      _playbackTimer?.cancel();
      _bump(position: total, isPlaying: false);
    } else {
      _bump(position: next);
    }
  }

  void splitSelectedClipAtPlayhead() {
    final id = state.selectedClipId;
    if (id == null) return;
    final newClip = timeline.splitClip(id, state.position);
    if (newClip != null) {
      _bump(selectedClipId: newClip.id);
    }
  }

  void deleteSelectedClip() {
    final id = state.selectedClipId;
    if (id == null) return;
    timeline.removeClip(id);
    _bump(clearSelection: true);
  }

  void applyFilterToActiveOrSelectedClip(String? filterId) {
    final clip = state.selectedClipId != null
        ? timeline.findClip(state.selectedClipId!)
        : timeline.activeClipOnTrack(ClipType.video, state.position);
    if (clip == null || clip.type != ClipType.video) return;
    clip.filterId = filterId;
    _bump();
  }

  void applyTransitionAfterSelectedClip(String? transitionId) {
    final id = state.selectedClipId;
    if (id == null) return;
    final clip = timeline.findClip(id);
    if (clip == null || clip.type != ClipType.video) return;
    clip.transitionOutId = transitionId;
    _bump();
  }

  Future<void> exportVideo() async {
    emit(state.copyWith(exportStatus: ExportStatus.exporting));
    try {
      final outputPath = await _processor.processTimeline(timeline);
      emit(state.copyWith(exportStatus: ExportStatus.success, exportedPath: outputPath));
    } catch (e) {
      emit(state.copyWith(exportStatus: ExportStatus.error, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _playbackTimer?.cancel();
    _activeController?.dispose();
    return super.close();
  }
}
