import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'engine_command.dart';
import 'engine_text.dart';
import 'engine_timeline.dart';
import 'models/video_filter.dart';

/// ينفذ خط أنابيب التصدير الكامل: قص كل مقطع (مع فلتره إن وجد) ثم دمجها ثم تركيب النصوص
class EngineProcessor {
  final EngineCommand _command = EngineCommand();
  final EngineText _engineText = EngineText();

  Future<String> processTimeline(EngineTimeline timeline) async {
    final videoTrack = timeline.trackOfType(ClipType.video);
    if (videoTrack.clips.isEmpty) {
      throw Exception('لا توجد مقاطع فيديو في المشروع لتصديرها');
    }

    final tempDir = await getTemporaryDirectory();
    final workDir = Directory('${tempDir.path}/vibecut_export_${DateTime.now().millisecondsSinceEpoch}');
    await workDir.create(recursive: true);

    final trimmedPaths = <String>[];
    for (int i = 0; i < videoTrack.clips.length; i++) {
      final clip = videoTrack.clips[i];
      if (clip.sourcePath == null) continue;
      final outPath = '${workDir.path}/part_$i.mp4';

      final preset = clip.filterId != null
          ? videoFilterPresets.firstWhere(
              (f) => f.id == clip.filterId,
              orElse: () => videoFilterPresets.first,
            )
          : null;
      final filterArg = (preset?.ffmpegFilter != null) ? '-vf "${preset!.ffmpegFilter}" ' : '';

      final trimCmd = '-i "${clip.sourcePath}" -ss ${clip.trimStart} -t ${clip.duration} '
          '$filterArg-c:v libx264 -preset veryfast -c:a aac -avoid_negative_ts make_zero "$outPath"';
      final ok = await _command.executeCommand(trimCmd);
      if (!ok) {
        throw Exception('فشل قص المقطع رقم ${i + 1}');
      }
      trimmedPaths.add(outPath);
    }

    if (trimmedPaths.isEmpty) {
      throw Exception('تعذر تجهيز أي مقطع للتصدير');
    }

    final listFile = File('${workDir.path}/concat_list.txt');
    final listContent = trimmedPaths.map((p) => "file '$p'").join('\n');
    await listFile.writeAsString(listContent);

    final mergedPath = '${workDir.path}/merged.mp4';
    final concatCmd = '-f concat -safe 0 -i "${listFile.path}" -c copy "$mergedPath"';
    final concatOk = await _command.executeCommand(concatCmd);
    if (!concatOk) {
      throw Exception('فشل دمج المقاطع في فيديو واحد');
    }

    final textTrack = timeline.trackOfType(ClipType.text);
    String finalPath = mergedPath;

    if (textTrack.clips.isNotEmpty) {
      try {
        final fontPath = await _extractFont(workDir.path);
        final drawTextFilters = textTrack.clips.map((clip) {
          final reshaped = _engineText.processArabic(clip.text ?? '');
          final safeText = reshaped.replaceAll("'", "\\'").replaceAll(':', '\\:');
          return "drawtext=fontfile='$fontPath':text='$safeText':fontcolor=white:fontsize=48:"
              "x=(w-text_w)/2:y=h-th-80:box=1:boxcolor=black@0.4:boxborderw=10:"
              "enable='between(t,${clip.startOnTrack},${clip.endOnTrack})'";
        }).join(',');

        final withTextPath = '${workDir.path}/final.mp4';
        final textCmd = '-i "$mergedPath" -vf "$drawTextFilters" -c:a copy "$withTextPath"';
        final textOk = await _command.executeCommand(textCmd);
        if (textOk) {
          finalPath = withTextPath;
        }
      } catch (_) {
        // إن فشلت مرحلة النص، نُبقي على الفيديو المدموج بلا نص بدلاً من إفشال التصدير بالكامل
      }
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${docsDir.path}/VibeCut/exports');
    await exportsDir.create(recursive: true);
    final finalOutput = '${exportsDir.path}/vibecut_${DateTime.now().millisecondsSinceEpoch}.mp4';
    await File(finalPath).copy(finalOutput);

    return finalOutput;
  }

  Future<String> _extractFont(String workDirPath) async {
    final fontData = await rootBundle.load('assets/core/fonts/Cairo-Regular.ttf');
    final fontFile = File('$workDirPath/Cairo-Regular.ttf');
    await fontFile.writeAsBytes(
      fontData.buffer.asUint8List(fontData.offsetInBytes, fontData.lengthInBytes),
    );
    return fontFile.path;
  }
}
