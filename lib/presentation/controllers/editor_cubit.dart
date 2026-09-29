import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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

  VideoPlayerController? _pipController;
  String? _pipControllerClipId;

  VideoPlayerController? get activeController => _activeController;
  VideoPlayerController? get pipController => _pipController;

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
    _syncPipController();
  }

  Future<void> _syncActiveController() async {
    final clip = timeline.activeClipOnTrack(ClipType.video, state.position);

    if (clip == null || clip.sourcePath == null) {
      await _activeController?.pause();
      return;
    }

    final sourceOffset = clip.trimStart + (state.position - clip.startOnTrack) * clip.speed;

    if (clip.id != _activeControllerClipId) {
      _activeControllerClipId = clip.id;
      final oldController = _activeController;
      final newController = VideoPlayerController.file(File(clip.sourcePath!));
      _activeController = newController;
      try {
        await newController.initialize();
        await newController.setPlaybackSpeed(clip.speed);
        await newController.seekTo(Duration(milliseconds: (sourceOffset * 1000).round()));
        if (state.isPlaying) await newController.play();
      } catch (_) {
        // تجاهل أخطاء تهيئة الفيديو الفردية
      }
      await oldController?.dispose();
      if (!isClosed) emit(state.copyWith(revision: state.revision + 1));
    } else {
      final controller = _activeController;
      if (controller != null && controller.value.isInitialized) {
        if (controller.value.playbackSpeed != clip.speed) {
          await controller.setPlaybackSpeed(clip.speed);
        }
        final currentMs = controller.value.position.inMilliseconds;
        final targetMs = (sourceOffset * 1000).round();
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

  /// مزامنة متحكم فيديو PIP مع المقطع النشط في مسار PIP (بنفس منطق المزامنة المستخدم للفيديو الرئيسي)
  Future<void> _syncPipController() async {
    final clip = timeline.activeClipOnTrack(ClipType.pip, state.position);

    if (clip == null || clip.sourcePath == null) {
      await _pipController?.pause();
      return;
    }

    final sourceOffset = clip.trimStart + (state.position - clip.startOnTrack);

    if (clip.id != _pipControllerClipId) {
      _pipControllerClipId = clip.id;
      final oldController = _pipController;
      final newController = VideoPlayerController.file(File(clip.sourcePath!));
      _pipController = newController;
      try {
        await newController.initialize();
        await newController.setVolume(0); // لا نريد خلط صوت مقطع PIP مع الصوت الرئيسي أثناء المعاينة
        await newController.seekTo(Duration(milliseconds: (sourceOffset * 1000).round()));
        if (state.isPlaying) await newController.play();
      } catch (_) {
        // تجاهل أخطاء تهيئة فيديو PIP
      }
      await oldController?.dispose();
      if (!isClosed) emit(state.copyWith(revision: state.revision + 1));
    } else {
      final controller = _pipController;
      if (controller != null && controller.value.isInitialized) {
        final currentMs = controller.value.position.inMilliseconds;
        final targetMs = (sourceOffset * 1000).round();
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

  Future<void> pickAndAddAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    final path = result?.files.single.path;
    if (path == null) return;

    double duration = 5.0;
    final probe = VideoPlayerController.file(File(path));
    try {
      await probe.initialize();
      duration = probe.value.duration.inMilliseconds / 1000.0;
    } catch (_) {
      // بعض تنسيقات الصوت قد لا تُهيأ عبر video_player، نستخدم مدة افتراضية عندئذ
    } finally {
      await probe.dispose();
    }

    final endOfTimeline = timeline.totalDuration;
    timeline.addAudioClip(
      path: path,
      sourceDuration: duration,
      startOnTrack: state.position.clamp(0.0, endOfTimeline),
    );
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

  /// يختار صورة حقيقية من الجهاز ويُركّبها فوق الفيديو، ويُعيد معرف المقطع الجديد لفتح لوحة الشفافية
  Future<String?> pickAndAddImageOverlay() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    final endOfTimeline = timeline.totalDuration;
    final clip = timeline.addImageOverlayClip(
      path: picked.path,
      duration: 3.0,
      startOnTrack: state.position.clamp(0.0, endOfTimeline),
    );
    _bump();
    return clip.id;
  }

  /// يختار فيديو من الجهاز ويُضيفه كمقطع صغير (Picture-in-Picture) فوق الفيديو الرئيسي
  Future<String?> pickAndAddPipVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return null;

    final probe = VideoPlayerController.file(File(picked.path));
    await probe.initialize();
    final duration = probe.value.duration.inMilliseconds / 1000.0;
    await probe.dispose();

    final endOfTimeline = timeline.totalDuration;
    final clip = timeline.addPipClip(
      path: picked.path,
      sourceDuration: duration,
      startOnTrack: state.position.clamp(0.0, endOfTimeline),
    );
    _bump();
    return clip.id;
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
    final clip = timeline.findClip(id);
    final wasVideo = clip?.type == ClipType.video;
    timeline.removeClip(id);
    if (wasVideo) {
      timeline.reflowVideoTrack();
    }
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

  void setClipSpeed(String clipId, double speed) {
    final clip = timeline.findClip(clipId);
    if (clip == null || clip.type != ClipType.video) return;
    clip.speed = speed.clamp(0.1, 4.0);
    timeline.reflowVideoTrack();
    _bump();
  }

  /// يضبط مقدار التمويه للمقطع المحدد أو المقطع النشط إن لم يوجد تحديد
  void setBlurForActiveOrSelectedClip(double amount) {
    final clip = state.selectedClipId != null
        ? timeline.findClip(state.selectedClipId!)
        : timeline.activeClipOnTrack(ClipType.video, state.position);
    if (clip == null || clip.type != ClipType.video) return;
    clip.blurAmount = amount.clamp(0.0, 20.0);
    _bump();
  }

  /// يضبط شفافية مقطع طبقة (ملصق/صورة/PIP)
  void setOverlayOpacity(String clipId, double opacity) {
    final clip = timeline.findClip(clipId);
    if (clip == null) return;
    clip.overlayOpacity = opacity.clamp(0.0, 1.0);
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
    _pipController?.dispose();
    return super.close();
  }
}
