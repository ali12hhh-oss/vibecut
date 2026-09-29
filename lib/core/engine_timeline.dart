import 'dart:math';

/// أنواع المقاطع التي يدعمها المحرر
enum ClipType { video, audio, text, image, sticker }

/// مقطع واحد على الخط الزمني (فيديو، صوت، نص، ملصق...)
class TimelineClip {
  final String id;
  final ClipType type;
  final String? sourcePath;
  final double sourceDuration;
  double trimStart;
  double trimEnd;
  double startOnTrack;

  // خصائص النص (لمقاطع النوع text فقط)
  String? text;
  int? textColorValue;
  double? fontSize;
  String? textStyleId;

  // معرف الفلتر المطبق (لمقاطع الفيديو)
  String? filterId;

  // معرف الانتقال من هذا المقطع إلى المقطع التالي له في نفس المسار
  String? transitionOutId;

  // مستوى الصوت (لمقاطع النوع audio)
  double volume;

  // معامل السرعة (لمقاطع النوع video فقط؛ 1.0 طبيعي)
  double speed;

  TimelineClip({
    required this.id,
    required this.type,
    this.sourcePath,
    required this.sourceDuration,
    required this.trimStart,
    required this.trimEnd,
    required this.startOnTrack,
    this.text,
    this.textColorValue,
    this.fontSize,
    this.textStyleId,
    this.filterId,
    this.transitionOutId,
    this.volume = 1.0,
    this.speed = 1.0,
  });

  /// طول المقطع في المصدر قبل تطبيق السرعة (ما يُقص فعلياً من الملف الأصلي)
  double get sourceSpan => (trimEnd - trimStart).clamp(0.0, sourceDuration);

  /// طول المقطع على التايم لاين بعد تطبيق السرعة
  double get duration => sourceSpan / speed;
  double get endOnTrack => startOnTrack + duration;
}

/// مسار واحد في التايم لاين (فيديو أو صوت أو نص أو ملصق)
class TimelineTrack {
  final String id;
  final ClipType type;
  final List<TimelineClip> clips;

  TimelineTrack({required this.id, required this.type, List<TimelineClip>? clips})
      : clips = clips ?? [];

  double get trackDuration {
    if (clips.isEmpty) return 0.0;
    return clips.map((c) => c.endOnTrack).reduce(max);
  }
}

/// التايم لاين الكامل للمشروع
class EngineTimeline {
  final List<TimelineTrack> tracks;

  EngineTimeline()
      : tracks = [
          TimelineTrack(id: 'video_main', type: ClipType.video),
          TimelineTrack(id: 'audio_main', type: ClipType.audio),
          TimelineTrack(id: 'text_main', type: ClipType.text),
          TimelineTrack(id: 'sticker_main', type: ClipType.sticker),
        ];

  TimelineTrack trackOfType(ClipType type) =>
      tracks.firstWhere((t) => t.type == type, orElse: () => tracks.first);

  double get totalDuration {
    if (tracks.every((t) => t.clips.isEmpty)) return 0.0;
    return tracks.map((t) => t.trackDuration).reduce(max);
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}';

  TimelineClip addVideoClip({required String path, required double sourceDuration}) {
    final track = trackOfType(ClipType.video);
    final clip = TimelineClip(
      id: _newId(),
      type: ClipType.video,
      sourcePath: path,
      sourceDuration: sourceDuration,
      trimStart: 0.0,
      trimEnd: sourceDuration,
      startOnTrack: track.trackDuration,
    );
    track.clips.add(clip);
    return clip;
  }

  TimelineClip addAudioClip({
    required String path,
    required double sourceDuration,
    double? startOnTrack,
  }) {
    final track = trackOfType(ClipType.audio);
    final clip = TimelineClip(
      id: _newId(),
      type: ClipType.audio,
      sourcePath: path,
      sourceDuration: sourceDuration,
      trimStart: 0.0,
      trimEnd: sourceDuration,
      startOnTrack: startOnTrack ?? track.trackDuration,
    );
    track.clips.add(clip);
    return clip;
  }

  TimelineClip addTextClip({
    required String text,
    double duration = 3.0,
    double? startOnTrack,
    String? styleId,
  }) {
    final track = trackOfType(ClipType.text);
    final clip = TimelineClip(
      id: _newId(),
      type: ClipType.text,
      sourceDuration: duration,
      trimStart: 0.0,
      trimEnd: duration,
      startOnTrack: startOnTrack ?? 0.0,
      text: text,
      textStyleId: styleId,
    );
    track.clips.add(clip);
    return clip;
  }

  TimelineClip addStickerClip({
    required String assetPath,
    double duration = 3.0,
    double? startOnTrack,
  }) {
    final track = trackOfType(ClipType.sticker);
    final clip = TimelineClip(
      id: _newId(),
      type: ClipType.sticker,
      sourcePath: assetPath,
      sourceDuration: duration,
      trimStart: 0.0,
      trimEnd: duration,
      startOnTrack: startOnTrack ?? 0.0,
    );
    track.clips.add(clip);
    return clip;
  }

  TimelineTrack? trackOfClip(String clipId) {
    for (final track in tracks) {
      if (track.clips.any((c) => c.id == clipId)) return track;
    }
    return null;
  }

  TimelineClip? findClip(String clipId) {
    for (final track in tracks) {
      for (final clip in track.clips) {
        if (clip.id == clipId) return clip;
      }
    }
    return null;
  }

  void removeClip(String clipId) {
    for (final track in tracks) {
      track.clips.removeWhere((c) => c.id == clipId);
    }
  }

  TimelineClip? splitClip(String clipId, double atTimelinePosition) {
    final track = trackOfClip(clipId);
    if (track == null) return null;
    final index = track.clips.indexWhere((c) => c.id == clipId);
    if (index == -1) return null;
    final clip = track.clips[index];

    if (atTimelinePosition <= clip.startOnTrack || atTimelinePosition >= clip.endOnTrack) {
      return null;
    }

    // المقدار الزمني على التايم لاين يُحوّل إلى مقدار في المصدر مراعاة للسرعة
    final splitOffsetOnTrack = atTimelinePosition - clip.startOnTrack;
    final splitSourcePoint = clip.trimStart + splitOffsetOnTrack * clip.speed;

    final secondHalf = TimelineClip(
      id: _newId(),
      type: clip.type,
      sourcePath: clip.sourcePath,
      sourceDuration: clip.sourceDuration,
      trimStart: splitSourcePoint,
      trimEnd: clip.trimEnd,
      startOnTrack: atTimelinePosition,
      text: clip.text,
      textColorValue: clip.textColorValue,
      fontSize: clip.fontSize,
      textStyleId: clip.textStyleId,
      filterId: clip.filterId,
      transitionOutId: clip.transitionOutId,
      volume: clip.volume,
      speed: clip.speed,
    );

    clip.trimEnd = splitSourcePoint;
    clip.transitionOutId = null;
    track.clips.insert(index + 1, secondHalf);
    return secondHalf;
  }

  TimelineClip? activeClipOnTrack(ClipType type, double position) {
    final track = trackOfType(type);
    for (final clip in track.clips) {
      if (position >= clip.startOnTrack && position < clip.endOnTrack) {
        return clip;
      }
    }
    return null;
  }

  /// يعيد ترتيب مواضع مقاطع مسار الفيديو لتبقى متتابعة بلا فراغات، يُستدعى بعد أي حذف أو تغيير في المدة (السرعة)
  void reflowVideoTrack() {
    final track = trackOfType(ClipType.video);
    double cursor = 0.0;
    for (final clip in track.clips) {
      clip.startOnTrack = cursor;
      cursor += clip.duration;
    }
  }
}
