import 'effect_definition.dart';
import '../engine_timeline.dart';
import '../models/video_filter.dart';

/// المصدر الوحيد لترتيب التأثيرات المرئية لأي مقطع فيديو. كل من المعاينة الحية في المحرر،
/// ومرحلة التصدير في FFmpeg، تستدعي هذه الدالة وحدها لضمان تطابق ما يُرى مع ما يُصدر.
/// أي تأثير جديد (مثل تشبع/إضاءة...) يُضاف هنا فقط، وسيعمل تلقائياً في المكانين.
List<EffectDefinition> resolveVisualEffects(TimelineClip? clip) {
  if (clip == null) return const [];

  final effects = <EffectDefinition>[];

  if (clip.filterId != null) {
    final preset = videoFilterPresets.firstWhere(
      (f) => f.id == clip.filterId,
      orElse: () => videoFilterPresets.first,
    );
    effects.add(ColorFilterEffect(preset.matrix, preset.ffmpegFilter));
  }

  if (clip.blurAmount > 0) {
    effects.add(BlurEffect(clip.blurAmount));
  }

  return effects;
}
