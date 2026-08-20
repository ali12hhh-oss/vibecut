import 'dart:io';

import 'engine_command.dart';
import 'engine_timeline.dart';

class EngineProcessor {
  EngineProcessor(this._timeline);

  final EngineCommand _command = EngineCommand();
  final EngineTimeline _timeline;

  Future<String> processProject(String outputPath) async {
    final segments = _timeline.segments;

    if (segments.isEmpty) {
      throw StateError('لا توجد مقاطع في التايم لاين.');
    }

    final realInputs = segments.where((segment) => !segment.isSample).toList();

    if (realInputs.isEmpty) {
      return _writeSampleManifest(outputPath, segments);
    }

    if (realInputs.length == 1) {
      final command = _command.buildTrimCommand(
        input: realInputs.first.videoPath,
        start: realInputs.first.startTime.toStringAsFixed(2),
        duration: realInputs.first.duration.toStringAsFixed(2),
        output: outputPath,
      );
      await _command.executeCommand(command);
      return outputPath;
    }

    final command = _command.buildConcatCommand(
      inputs: realInputs.map((segment) => segment.videoPath).toList(),
      output: outputPath,
    );
    await _command.executeCommand(command);
    return outputPath;
  }

  Future<String> _writeSampleManifest(String outputPath, List<TimelineSegment> segments) async {
    final manifestPath = outputPath.endsWith('.mp4') ? outputPath.replaceAll('.mp4', '.txt') : '$outputPath.txt';
    final file = File(manifestPath);
    final buffer = StringBuffer()
      ..writeln('VibeCut sample export manifest')
      ..writeln('This file is generated when sample:// clips are used instead of real media.')
      ..writeln('Segments: ${segments.length}');

    for (final segment in segments) {
      buffer.writeln('${segment.displayName} - ${segment.duration}s');
    }

    await file.create(recursive: true);
    await file.writeAsString(buffer.toString());
    return manifestPath;
  }
}
