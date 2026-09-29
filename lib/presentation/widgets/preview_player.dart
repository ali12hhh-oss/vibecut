import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../core/engine_timeline.dart';
import '../../core/models/text_style_preset.dart';
import '../../core/models/video_filter.dart';
import '../controllers/editor_cubit.dart';

/// يعرض الإطار الحالي للفيديو مع الفلتر/التمويه، وطبقات النصوص، والملصقات، وصور التركيب، وفيديو PIP
class PreviewPlayer extends StatelessWidget {
  const PreviewPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, state) {
        final cubit = context.read<EditorCubit>();
        final controller = cubit.activeController;
        final pipController = cubit.pipController;
        final timeline = cubit.timeline;
        final activeClip = timeline.activeClipOnTrack(ClipType.video, state.position);
        final preset = videoFilterPresets.firstWhere(
          (f) => f.id == activeClip?.filterId,
          orElse: () => videoFilterPresets.first,
        );
        final blurAmount = activeClip?.blurAmount ?? 0.0;

        final activeTextClips = timeline.tracks
            .where((t) => t.type == ClipType.text)
            .expand((t) => t.clips)
            .where((c) => state.position >= c.startOnTrack && state.position < c.endOnTrack);

        final activeStickerClips = timeline.tracks
            .where((t) => t.type == ClipType.sticker)
            .expand((t) => t.clips)
            .where((c) => state.position >= c.startOnTrack && state.position < c.endOnTrack);

        final activeImageClips = timeline.tracks
            .where((t) => t.type == ClipType.image)
            .expand((t) => t.clips)
            .where((c) => state.position >= c.startOnTrack && state.position < c.endOnTrack);

        final activePipClip = timeline.activeClipOnTrack(ClipType.pip, state.position);

        Widget videoWidget = (controller != null && controller.value.isInitialized)
            ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              )
            : const Icon(Icons.movie_creation_outlined, color: Colors.white24, size: 64);

        videoWidget = ColorFiltered(colorFilter: ColorFilter.matrix(preset.matrix), child: videoWidget);

        if (blurAmount > 0) {
          videoWidget = ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
            child: videoWidget,
          );
        }

        return Container(
          color: Colors.black,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              videoWidget,
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
              ...activeImageClips.map(
                (clip) => Positioned(
                  top: 12,
                  right: 12,
                  child: Opacity(
                    opacity: clip.overlayOpacity,
                    child: Image.file(File(clip.sourcePath!), width: 110),
                  ),
                ),
              ),
              if (activePipClip != null && pipController != null && pipController.value.isInitialized)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Opacity(
                    opacity: activePipClip.overlayOpacity,
                    child: Container(
                      width: 110,
                      decoration: BoxDecoration(border: Border.all(color: Colors.white70, width: 1.5)),
                      child: AspectRatio(
                        aspectRatio: pipController.value.aspectRatio,
                        child: VideoPlayer(pipController),
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
