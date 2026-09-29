import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../core/engine_timeline.dart';
import '../../core/models/text_style_preset.dart';
import '../../core/models/video_filter.dart';
import '../controllers/editor_cubit.dart';

/// يعرض الإطار الحالي للفيديو النشط مع الفلتر، وطبقات النصوص المنسقة، والملصقات النشطة
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

        final activeStickerClips = timeline.tracks
            .where((t) => t.type == ClipType.sticker)
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
              ...activeTextClips.map((clip) {
                final stylePreset = textStylePresets.firstWhere(
                  (s) => s.id == clip.textStyleId,
                  orElse: () => textStylePresets.first,
                );
                return Positioned(
                  bottom: 40,
                  child: Container(
                    padding: stylePreset.padding,
                    color: stylePreset.backgroundColor,
                    child: Text(
                      clip.text ?? '',
                      textDirection: TextDirection.rtl,
                      style: stylePreset.style,
                    ),
                  ),
                );
              }),
              ...activeStickerClips.map(
                (clip) => Positioned(
                  top: 12,
                  right: 12,
                  child: Image.asset(clip.sourcePath!, width: 70, height: 70),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
