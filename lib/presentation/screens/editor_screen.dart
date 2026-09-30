import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/engine_timeline.dart';
import '../controllers/editor_cubit.dart';
import '../widgets/blur_panel.dart';
import '../widgets/editor_toolbar.dart';
import '../widgets/filter_panel.dart';
import '../widgets/opacity_panel.dart';
import '../widgets/preview_player.dart';
import '../widgets/speed_panel.dart';
import '../widgets/sticker_panel.dart';
import '../widgets/text_style_panel.dart';
import '../widgets/timeline_view.dart';
import '../widgets/transition_panel.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final GlobalKey _previewBoundaryKey = GlobalKey();

  Future<Uint8List?> _captureCurrentFrame() async {
    try {
      final boundary =
          _previewBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  void _pausePlaybackIfNeeded(EditorCubit cubit) {
    if (cubit.state.isPlaying) {
      cubit.togglePlay();
    }
  }

  Future<void> _promptAddText(BuildContext context) async {
    final cubit = context.read<EditorCubit>();
    _pausePlaybackIfNeeded(cubit);

    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة نص'),
        content: TextField(controller: controller, autofocus: true, textDirection: TextDirection.rtl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('التالي')),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty || !context.mounted) return;

    final styleId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TextStylePanel(sampleText: text.trim()),
    );

    if (!context.mounted) return;
    cubit.addTextClip(text.trim(), styleId: styleId);
  }

  Future<void> _openFilterPanel(BuildContext context) async {
    final cubit = context.read<EditorCubit>();
    _pausePlaybackIfNeeded(cubit);

    final state = cubit.state;
    final activeClip = state.selectedClipId != null
        ? cubit.timeline.findClip(state.selectedClipId!)
        : cubit.timeline.activeClipOnTrack(ClipType.video, state.position);

    if (activeClip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف فيديو أولاً لتطبيق الفلاتر')),
      );
      return;
    }

    final frameBytes = await _captureCurrentFrame();
    if (!context.mounted) return;

    cubit.pushUndoCheckpoint();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FilterPanel(
        imageBytes: frameBytes,
        selectedFilterId: activeClip.filterId,
        onSelect: (id) => cubit.applyFilterToActiveOrSelectedClip(id),
      ),
    );
  }

  Future<void> _openBlurPanel(BuildContext context) async {
    final cubit = context.read<EditorCubit>();
    _pausePlaybackIfNeeded(cubit);

    final state = cubit.state;
    final activeClip = state.selectedClipId != null
        ? cubit.timeline.findClip(state.selectedClipId!)
        : cubit.timeline.activeClipOnTrack(ClipType.video, state.position);

    if (activeClip == null || activeClip.type != ClipType.video) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف فيديو أو حدده أولاً لتطبيق التمويه')),
      );
      return;
    }

    cubit.pushUndoCheckpoint();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlurPanel(
        initialBlur: activeClip.blurAmount,
        onChanged: (v) => cubit.setBlurForActiveOrSelectedClip(v),
      ),
    );
  }

  Future<void> _openTransitionPanel(BuildContext context) async {
    final cubit = context.read<EditorCubit>();
    _pausePlaybackIfNeeded(cubit);

    final id = cubit.state.selectedClipId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدد مقطع فيديو أولاً لإضافة انتقال بعده')),
      );
      return;
    }
    final clip = cubit.timeline.findClip(id);
    if (clip == null || clip.type != ClipType.video) return;

    final videoTrack = cubit.timeline.trackOfType(ClipType.video);
    final index = videoTrack.clips.indexWhere((c) => c.id == id);
    if (index == -1 || index >= videoTrack.clips.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد مقطع تالٍ لهذا المقطع لإضافة انتقال معه')),
      );
      return;
    }

    cubit.pushUndoCheckpoint();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TransitionPanel(
        selectedTransitionId: clip.transitionOutId,
        onSelect: (transitionId) => cubit.applyTransitionAfterSelectedClip(transitionId),
      ),
    );
  }

  Future<void> _openStickerPanel(BuildContext context) async {
    final cubit = context.read<EditorCubit>();
    _pausePlaybackIfNeeded(cubit);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StickerPanel(onSelect: (path) => cubit.addStickerClip(path)),
    );
  }

  Future<void> _openOpacityPanelFor(BuildContext context, String clipId, double initial) async {
    if (!context.mounted) return;
    final cubit = context.read<EditorCubit>();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OpacityPanel(
        initialOpacity: initial,
        onChanged: (v) => cubit.setOverlayOpacity(clipId, v),
      ),
    );
  }

  Future<void> _pickImageOverlay(BuildContext context) async {
    final cubit = context.read<EditorCubit>();
    _pausePlaybackIfNeeded(cubit);

    final clipId = await cubit.pickAndAddImageOverlay();
    if (clipId == null || !context.mounted) return;
    await _openOpacityPanelFor(context, clipId, 1.0);
  }

  Future<void> _pickPipVideo(BuildContext context) async {
    final cubit = context.read<EditorCubit>();
    _pausePlaybackIfNeeded(cubit);

    final clipId = await cubit.pickAndAddPipVideo();
    if (clipId == null || !context.mounted) return;
    await _openOpacityPanelFor(context, clipId, 1.0);
  }

  Future<void> _openSpeedPanel(BuildContext context) async {
    final cubit = context.read<EditorCubit>();
    _pausePlaybackIfNeeded(cubit);

    final id = cubit.state.selectedClipId;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدد مقطع فيديو أولاً لتغيير سرعته')),
      );
      return;
    }
    final clip = cubit.timeline.findClip(id);
    if (clip == null || clip.type != ClipType.video) return;

    cubit.pushUndoCheckpoint();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SpeedPanel(
        initialSpeed: clip.speed,
        onChanged: (v) => cubit.setClipSpeed(id, v),
      ),
    );
  }

  String _formatTime(double seconds) {
    final d = Duration(milliseconds: (seconds * 1000).round());
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _handleExport(BuildContext context) async {
    final cubit = context.read<EditorCubit>();
    _pausePlaybackIfNeeded(cubit);
    await cubit.exportVideo();
    if (!context.mounted) return;
    final s = cubit.state;
    final message = s.exportStatus == ExportStatus.success
        ? 'تم التصدير: ${s.exportedPath}'
        : 'فشل التصدير: ${s.errorMessage ?? ''}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: BlocBuilder<EditorCubit, EditorState>(
          builder: (context, state) {
            final cubit = context.read<EditorCubit>();
            final timeline = cubit.timeline;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.undo, color: cubit.canUndo ? Colors.white : Colors.white24),
                        tooltip: 'تراجع',
                        onPressed: cubit.canUndo ? cubit.undo : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.redo, color: cubit.canRedo ? Colors.white : Colors.white24),
                        tooltip: 'إعادة',
                        onPressed: cubit.canRedo ? cubit.redo : null,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RepaintBoundary(
                    key: _previewBoundaryKey,
                    child: const PreviewPlayer(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          color: Colors.white,
                          size: 36,
                        ),
                        onPressed: cubit.togglePlay,
                      ),
                      Text(
                        '${_formatTime(state.position)} / ${_formatTime(timeline.totalDuration)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const Spacer(),
                      if (state.exportStatus == ExportStatus.exporting)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: TimelineView.trackHeight * timeline.tracks.length + 10,
                  child: TimelineView(
                    timeline: timeline,
                    position: state.position,
                    selectedClipId: state.selectedClipId,
                    onClipTap: cubit.selectClip,
                    onSeek: cubit.seekTo,
                  ),
                ),
                EditorToolbar(
                  hasSelection: state.selectedClipId != null,
                  onAddVideo: cubit.pickAndAddVideo,
                  onAddAudio: cubit.pickAndAddAudio,
                  onSplit: cubit.splitSelectedClipAtPlayhead,
                  onDelete: cubit.deleteSelectedClip,
                  onAddText: () => _promptAddText(context),
                  onFilters: () => _openFilterPanel(context),
                  onBlur: () => _openBlurPanel(context),
                  onTransitions: () => _openTransitionPanel(context),
                  onStickers: () => _openStickerPanel(context),
                  onImageOverlay: () => _pickImageOverlay(context),
                  onPip: () => _pickPipVideo(context),
                  onSpeed: () => _openSpeedPanel(context),
                  onExport: () => _handleExport(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
