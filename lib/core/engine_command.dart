import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';

class EngineCommand {
  Future<bool> executeCommand(String command) async {
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return true;
    }

    final failStackTrace = await session.getFailStackTrace();
    throw Exception(failStackTrace ?? 'FFmpeg command failed');
  }

  String buildConcatCommand({
    required List<String> inputs,
    required String output,
  }) {
    final inputArgs = inputs.map((input) => '-i "${_escape(input)}"').join(' ');
    final streams = List.generate(inputs.length, (index) => '[$index:v:0][$index:a:0]').join();
    return '$inputArgs -filter_complex "${streams}concat=n=${inputs.length}:v=1:a=1[v][a]" '
        '-map "[v]" -map "[a]" -c:v libx264 -preset veryfast -crf 23 -c:a aac "${_escape(output)}"';
  }

  String buildTransitionCommand({
    required String video1,
    required String video2,
    required String output,
    String transition = 'slideleft',
    String duration = '1.0',
    String offset = '4.0',
  }) {
    return '-i "${_escape(video1)}" -i "${_escape(video2)}" '
        '-filter_complex "[0:v][1:v]xfade=transition=$transition:duration=$duration:offset=$offset[v]" '
        '-map "[v]" -c:v libx264 -preset veryfast -crf 23 "${_escape(output)}"';
  }

  String buildTrimCommand({
    required String input,
    required String start,
    required String duration,
    required String output,
  }) {
    return '-ss $start -i "${_escape(input)}" -t $duration -c:v copy -c:a copy "${_escape(output)}"';
  }

  String buildAudioMixCommand(String videoInput, String audioInput, String output) {
    return '-i "${_escape(videoInput)}" -i "${_escape(audioInput)}" '
        '-c:v copy -filter_complex "[0:a][1:a]amix=inputs=2:duration=longest[a]" '
        '-map 0:v -map "[a]" -ac 2 "${_escape(output)}"';
  }

  String _escape(String value) => value.replaceAll('"', '\\"');
}
