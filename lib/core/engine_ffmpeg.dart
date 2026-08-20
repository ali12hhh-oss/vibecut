import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full/return_code.dart';

class EngineFFmpeg {
  Future<void> trimVideo(String input, String output, String start, String duration) async {
    final command = '-i "$input" -ss $start -t $duration -c copy "$output"';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      throw Exception(await session.getFailStackTrace() ?? 'Trim operation failed');
    }
  }

  Future<void> addTextOverlay(String input, String output, String text, String position) async {
    final command = '-i "$input" -vf "drawtext=text=\'$text\':x=$position" -c:a copy "$output"';
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      throw Exception(await session.getFailStackTrace() ?? 'Text overlay failed');
    }
  }
}
