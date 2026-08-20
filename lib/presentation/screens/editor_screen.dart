import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/engine_timeline.dart';
import '../controllers/editor_cubit.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditorCubit, EditorState>(
      listener: (context, state) {
        if (state is EditorFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is EditorSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم التصدير إلى ${state.outputPath}')));
        }
      },
      builder: (context, state) {
        final cubit = context.read<EditorCubit>();
        final segments = cubit.currentSegments;

        return Scaffold(
          appBar: AppBar(
            title: const Text('محرر VibeCut'),
            actions: [
              TextButton.icon(
                onPressed: state is EditorProcessing ? null : cubit.exportToDefaultLocation,
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('تصدير'),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill, size: 72, color: Colors.white70),
                      Positioned(
                        bottom: 16,
                        child: Text(
                          '${segments.length} مقاطع • ${cubit.totalDuration.toStringAsFixed(1)} ثانية',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state is EditorProcessing) const LinearProgressIndicator(),
              _ToolRail(onAddSampleClip: cubit.addSampleClip),
              Expanded(
                flex: 4,
                child: _TimelinePanel(segments: segments),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ToolRail extends StatelessWidget {
  const _ToolRail({required this.onAddSampleClip});

  final VoidCallback onAddSampleClip;

  @override
  Widget build(BuildContext context) {
    final tools = [
      _EditorTool('إضافة', Icons.add_photo_alternate_outlined, onAddSampleClip),
      _EditorTool('قص', Icons.content_cut, () {}),
      _EditorTool('نص', Icons.text_fields, () {}),
      _EditorTool('فلتر', Icons.filter_vintage, () {}),
      _EditorTool('ملصق', Icons.emoji_emotions_outlined, () {}),
      _EditorTool('صوت', Icons.graphic_eq, () {}),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: tools.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final tool = tools[index];
          return FilledButton.tonalIcon(
            onPressed: tool.onPressed,
            icon: Icon(tool.icon),
            label: Text(tool.label),
          );
        },
      ),
    );
  }
}

class _EditorTool {
  const _EditorTool(this.label, this.icon, this.onPressed);

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({required this.segments});

  final List<TimelineSegment> segments;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      return const Center(child: Text('أضف مقطعًا للبدء في بناء التايم لاين.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: segments.length,
      itemBuilder: (context, index) {
        final segment = segments[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.movie_outlined),
            title: Text(segment.displayName),
            subtitle: Text('المدة: ${segment.duration.toStringAsFixed(1)} ثانية'),
            trailing: segment.transitionPath == null ? null : const Icon(Icons.swap_horiz),
          ),
        );
      },
    );
  }
}
