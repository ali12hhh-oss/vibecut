import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// تعريف تأثير واحد: نفس التعريف يُستخدم لتطبيقه في المعاينة الحية (Flutter) وفي التصدير النهائي (FFmpeg)،
/// بدلاً من إعادة كتابة منطق التأثير مرتين منفصلتين. هذا هو النمط الذي تعتمده المحررات الاحترافية
/// (catalog-driven effects, matched preview/render).
abstract class EffectDefinition {
  const EffectDefinition();

  /// يلف الويدجت المعطى بالتأثير للمعاينة الحية
  Widget applyPreview(Widget child);

  /// يعيد مقطع مرشح FFmpeg المقابل للتصدير؛ null يعني أن التأثير لا يضيف شيئاً (مثلاً تمويه بقيمة 0)
  String? ffmpegFilter();
}

/// تأثير لون قائم على مصفوفة ألوان (الفلاتر)
class ColorFilterEffect extends EffectDefinition {
  final List<double> matrix;
  final String? ffmpeg;

  const ColorFilterEffect(this.matrix, this.ffmpeg);

  @override
  Widget applyPreview(Widget child) =>
      ColorFiltered(colorFilter: ColorFilter.matrix(matrix), child: child);

  @override
  String? ffmpegFilter() => ffmpeg;
}

/// تأثير التمويه/الضبابية
class BlurEffect extends EffectDefinition {
  final double sigma;

  const BlurEffect(this.sigma);

  @override
  Widget applyPreview(Widget child) {
    if (sigma <= 0) return child;
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    );
  }

  @override
  String? ffmpegFilter() => sigma <= 0 ? null : 'boxblur=${sigma.toStringAsFixed(1)}:1';
}
