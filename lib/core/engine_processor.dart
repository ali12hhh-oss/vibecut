import 'dart:io';
import 'package:flutter/material.dart' show Color;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'engine_command.dart';
import 'engine_text.dart';
import 'engine_timeline.dart';
import 'models/text_style_preset.dart';
import 'models/transition_type.dart';
import 'models/video_filter.dart';

/// ينفذ خط أنابيب التصدير الكامل: قص المقاطع (مع الفلتر) → دمجها (مع الانتقالات) → تركيب النصوص → تركيب الملصقات
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

    final hasAnyTransition = videoTrack.clips
        .take(videoTrack.clips.length - 1)
        .any((c) => c.transitionOutId != null);

    String mergedPath;
    if (trimmedPaths.length == 1) {
      mergedPath = trimmedPaths.first;
    } else if (!hasAnyTransition) {
      final listFile = File('${workDir.path}/concat_list.txt');
      final listContent = trimmedPaths.map((p) => "file '$p'").join('\n');
      await listFile.writeAsString(listContent);
      final path = '${workDir.path}/merged.mp4';
      final concatCmd = '-f concat -safe 0 -i "${listFile.path}" -c copy "$path"';
      final ok = await _command.executeCommand(concatCmd);
      if (!ok) throw Exception('فشل دمج المقاطع في فيديو واحد');
      mergedPath = path;
    } else {
      mergedPath = await _mergeWithTransitions(videoTrack.clips, trimmedPaths, workDir.path);
    }

    final textTrack = timeline.trackOfType(ClipType.text);
    String finalPath = mergedPath;

    if (textTrack.clips.isNotEmpty) {
      try {
        final fontPath = await _extractAsset('assets/core/fonts/Cairo-Regular.ttf', workDir.path);
        final drawTextFilters = textTrack.clips.map((clip) => _drawTextFilterFor(clip, fontPath)).join(',');

        final withTextPath = '${workDir.path}/with_text.mp4';
        final textCmd = '-i "$finalPath" -vf "$drawTextFilters" -c:a copy "$withTextPath"';
        final textOk = await _command.executeCommand(textCmd);
        if (textOk) {
          finalPath = withTextPath;
        }
      } catch (_) {
        // إن فشلت مرحلة النص، نُبقي على الفيديو المدموج بلا نص بدلاً من إفشال التصدير بالكامل
      }
    }

    final stickerTrack = timeline.trackOfType(ClipType.sticker);
    if (stickerTrack.clips.isNotEmpty) {
      try {
        final assetPaths = <String>[];
        final stickerClips = <TimelineClip>[];
        for (final clip in stickerTrack.clips) {
          if (clip.sourcePath == null) continue;
          assetPaths.add(await _extractAsset(clip.sourcePath!, workDir.path));
          stickerClips.add(clip);
        }
        if (assetPaths.isNotEmpty) {
          final inputsArgs = assetPaths.map((p) => '-i "$p"').join(' ');
          final buffer = StringBuffer();
          String prevLabel = '0:v';
          for (int i = 0; i < stickerClips.length; i++) {
            final clip = stickerClips[i];
            final outLabel = (i == stickerClips.length - 1) ? 'vout' : 's$i';
            buffer.write(
              '[$prevLabel][${i + 1}:v]overlay=x=main_w-overlay_w-30:y=30:'
              "enable='between(t,${clip.startOnTrack},${clip.endOnTrack})'[$outLabel];",
            );
            prevLabel = outLabel;
          }
          var filterComplex = buffer.toString();
          if (filterComplex.endsWith(';')) {
            filterComplex = filterComplex.substring(0, filterComplex.length - 1);
          }
          final withStickersPath = '${workDir.path}/with_stickers.mp4';
          final stickerCmd = '-i "$finalPath" $inputsArgs -filter_complex "$filterComplex" '
              '-map "[vout]" -map 0:a? -c:a copy "$withStickersPath"';
          final stickerOk = await _command.executeCommand(stickerCmd);
          if (stickerOk) {
            finalPath = withStickersPath;
          }
        }
      } catch (_) {
        // إن فشلت مرحلة الملصقات، نُبقي على الفيديو بدونها بدلاً من إفشال التصدير بالكامل
      }
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${docsDir.path}/VibeCut/exports');
    await exportsDir.create(recursive: true);
    final finalOutput = '${exportsDir.path}/vibecut_${DateTime.now().millisecondsSinceEpoch}.mp4';
    await File(finalPath).copy(finalOutput);

    return finalOutput;
  }

  String _drawTextFilterFor(TimelineClip clip, String fontPath) {
    final preset = textStylePresets.firstWhere(
      (s) => s.id == clip.textStyleId,
      orElse: () => textStylePresets.first,
    );
    final reshaped = _engineText.processArabic(clip.text ?? '');
    final safeText = reshaped.replaceAll("'", "\\'").replaceAll(':', '\\:');

    final color = preset.style.color ?? const Color(0xFFFFFFFF);
    final fontColorHex = '0x${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    final fontSize = (preset.style.fontSize ?? 32).round();

    String boxPart = '';
    if (preset.backgroundColor != null) {
      final bgHex = '0x${preset.backgroundColor!.value.toRadixString(16).padLeft(8, '0').substring(2)}';
      boxPart = 'box=1:boxcolor=$bgHex@0.55:boxborderw=10:';
    }

    return "drawtext=fontfile='$fontPath':text='$safeText':fontcolor=$fontColorHex:fontsize=$fontSize:"
        "x=(w-text_w)/2:y=h-th-80:$boxPart"
        "enable='between(t,${clip.startOnTrack},${clip.endOnTrack})'";
  }

  /// يدمج المقاطع المقصوصة مع انتقالات xfade حقيقية بين المقاطع التي طلب لها المستخدم ذلك
  Future<String> _mergeWithTransitions(
    List<TimelineClip> clips,
    List<String> trimmedPaths,
    String workDirPath,
  ) async {
    const defaultTransitionDuration = 0.6;
    const hardCutDuration = 0.05;

    final durations = clips.map((c) => c.duration).toList();
    final n = trimmedPaths.length;

    final inputsArgs = trimmedPaths.map((p) => '-i "$p"').join(' ');

    final buffer = StringBuffer();
    for (int i = 0; i < n; i++) {
      buffer.write('[$i:v]setpts=PTS-STARTPTS[v$i];');
    }

    double cum = durations[0];
    String prevLabel = 'v0';
    for (int i = 0; i < n - 1; i++) {
      final transId = clips[i].transitionOutId;
      final preset = transId != null
          ? transitionPresets.firstWhere((t) => t.id == transId, orElse: () => transitionPresets.first)
          : null;
      final xfadeName = preset?.ffmpegName ?? 'fade';
      final transDuration = preset != null ? defaultTransitionDuration : hardCutDuration;
      final offset = cum - transDuration;
      final outLabel = (i == n - 2) ? 'vout' : 'vx$i';
      buffer.write(
        '[$prevLabel][v${i + 1}]xfade=transition=$xfadeName:duration=${transDuration.toStringAsFixed(3)}:'
        'offset=${offset.toStringAsFixed(3)}[$outLabel];',
      );
      cum = cum + durations[i + 1] - transDuration;
      prevLabel = outLabel;
    }

    var filterComplex = buffer.toString();
    if (filterComplex.endsWith(';')) {
      filterComplex = filterComplex.substring(0, filterComplex.length - 1);
    }

    final videoOnlyPath = '$workDirPath/video_transitions.mp4';
    final videoCmd = '$inputsArgs -filter_complex "$filterComplex" -map "[vout]" '
        '-c:v libx264 -preset veryfast -an "$videoOnlyPath"';
    final videoOk = await _command.executeCommand(videoCmd);
    if (!videoOk) {
      throw Exception('فشل تركيب الانتقالات بين المقاطع');
    }

    final listFile = File('$workDirPath/audio_concat_list.txt');
    final listContent = trimmedPaths.map((p) => "file '$p'").join('\n');
    await listFile.writeAsString(listContent);
    final audioOnlyPath = '$workDirPath/audio_concat.m4a';
    final audioCmd = '-f concat -safe 0 -i "${listFile.path}" -vn -c:a copy "$audioOnlyPath"';
    final audioOk = await _command.executeCommand(audioCmd);

    if (!audioOk || !await File(audioOnlyPath).exists()) {
      return videoOnlyPath;
    }

    final combinedPath = '$workDirPath/merged.mp4';
    final combineCmd = '-i "$videoOnlyPath" -i "$audioOnlyPath" '
        '-c:v copy -c:a aac -shortest "$combinedPath"';
    final combineOk = await _command.executeCommand(combineCmd);

    return combineOk ? combinedPath : videoOnlyPath;
  }

  Future<String> _extractAsset(String assetPath, String workDirPath) async {
    final data = await rootBundle.load(assetPath);
    final fileName = assetPath.split('/').last;
    final file = File('$workDirPath/$fileName');
    await file.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    return file.path;
  }
}
