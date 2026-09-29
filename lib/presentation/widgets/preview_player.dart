import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/engine_timeline.dart';

/// يعرض الإطار الحالي للفيديو النشط عند موضع رأس التشغيل، مع طبقات النصوص النشطة فوقه
class PreviewPlayer extends StatefulWidget {
  final EngineTimeline timeline;
  final double position;
  final bool isPlaying;

  const PreviewPlayer({
    super.key,
    required this.timeline,
    required this.position,
    required this.isPlaying,
  });

  @override
  State<PreviewPlayer> createState() => _PreviewPlayerState();
}

class _PreviewPlayerState extends State<PreviewPlayer> {
  VideoPlayerController? _controller;
  String? _activeClipId;

  @override
  void initState() {
    super.initState();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant PreviewPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController();
  }

  void _syncController() {
    final activeClip = widget.timeline.activeClipOnTrack(ClipType.video, widget.position);

    if (activeClip == null) {
      _controller?.pause();
      return;
    }

    if (activeClip.id != _activeClipId) {
      _activeClipId = activeClip.id;
      final oldController = _controller;
      final newController = VideoPlayerController.file(File(activeClip.sourcePath!));
      _controller = newController;
      newController.initialize().then((_) {
        if (!mounted) return;
        final offset = (widget.position - activeClip.startOnTrack) + activeClip.trimStart;
        newController.seekTo(Duration(milliseconds: (offset * 1000).round()));
        if (widget.isPlaying) newController.play();
        setState(() {});
      });
      oldController?.dispose();
    } else {
      final controller = _controller;
      if (controller != null && controller.value.isInitialized) {
        final offset = (widget.position - activeClip.startOnTrack) + activeClip.trimStart;
        final currentMs = controller.value.position.inMilliseconds;
        final targetMs = (offset * 1000).round();
        if (!widget.isPlaying || (currentMs - targetMs).abs() > 400) {
          controller.seekTo(Duration(milliseconds: targetMs));
        }
        if (widget.isPlaying && !controller.value.isPlaying) {
          controller.play();
        } else if (!widget.isPlaying && controller.value.isPlaying) {
          controller.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final activeTextClips = widget.timeline.tracks
        .where((t) => t.type == ClipType.text)
        .expand((t) => t.clips)
        .where((c) => widget.position >= c.startOnTrack && widget.position < c.endOnTrack);

    return Container(
      color: Colors.black,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (controller != null && controller.value.isInitialized)
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
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
  }
}
