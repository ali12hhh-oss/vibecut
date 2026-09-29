import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/editor_cubit.dart';
import '../widgets/editor_toolbar.dart';
import '../widgets/preview_player.dart';
import '../widgets/timeline_view.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  Future<void> _promptAddText(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة نص'),
        content: TextField(controller: controller, autofocus: true, textDirection: TextDirection.rtl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('إضافة')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty && context.mounted) {
      context.read<EditorCubit>().addTextClip(result.trim());
    }
  }

  String _formatTime(double seconds) {
    final d = Duration(milliseconds: (seconds * 1000).round());
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _handleExport(BuildContext context) async {
    final cubit = context.read<EditorCubit>();
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
                Expanded(
                  child: PreviewPlayer(
                    timeline: timeline,
                    position: state.position,
                    isPlaying: state.isPlaying,
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
                  height: TimelineView.trackHeight * 3 + 10,
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
                  onSplit: cubit.splitSelectedClipAtPlayhead,
                  onDelete: cubit.deleteSelectedClip,
                  onAddText: () => _promptAddText(context),
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
