import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../core/engine_timeline.dart';
import '../../core/models/video_filter.dart';
import '../controllers/editor_cubit.dart';

/// يعرض الإطار الحالي للفيديو النشط مع الفلتر المطبق عليه حياً، وطبقات النصوص النشطة
class PreviewPlayer extends StatelessWidget {
  const PreviewPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, state) {
        final cubit = context.read<EditorCubit>();
        final controller = cubit.activeController;
        final timeline = cubit.timeline;
        final activeClip = timeline.activeClipOnTrack(ClipType.video, state.position);
        final preset = videoFilterPresets.firstWhere(
          (f) => f.id == activeClip?.filterId,
          orElse: () => videoFilterPresets.first,
        );

        final activeTextClips = timeline.tracks
            .where((t) => t.type == ClipType.text)
            .expand((t) => t.clips)
            .where((c) => state.position >= c.startOnTrack && state.position < c.endOnTrack);

        return Container(
          color: Colors.black,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (controller != null && controller.value.isInitialized)
                ColorFiltered(
                  colorFilter: ColorFilter.matrix(preset.matrix),
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                )
              else
                const Icon(Icons.movie_creation_outlined, color: Colors.white24, size: 64),
              ...activeTextClips.map(
                (clip) => Positioned(
                  bottom: 40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.black45,
                    child: Text(
                      clip.text ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
