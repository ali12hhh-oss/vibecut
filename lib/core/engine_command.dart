import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';

class EngineCommand {
  
  /// تنفيذ أمر FFmpeg والتحقق من النتيجة
  Future<bool> executeCommand(String command) async {
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print("Command executed successfully: $command");
      return true;
    } else {
      final failStackTrace = await session.getFailStackTrace();
      print("Command failed: $command with error: $failStackTrace");
      return false;
    }
  }

  /// بناء أمر انتقال احترافي (يجمع بين الفيديو والانتقال)
  String buildTransitionCommand({
    required String video1,
    required String video2,
    required String transition,
    required String output,
    String duration = "1.0",
  }) {
    // نستخدم مرشحات FFmpeg المتقدمة لدمج الفيديوهات مع الانتقال
    return '-i "$video1" -i "$video2" -i "$transition" '
           '-filter_complex "[0:v][1:v]xfade=transition=slideleft:duration=$duration:offset=4[v]" '
           '-map "[v]" -c:v libx264 -preset ultrafast "$output"';
  }

  /// أمر قص الفيديو مع الحفاظ على الجودة
  String buildTrimCommand({
    required String input,
    required String start,
    required String duration,
    required String output,
  }) {
    return '-ss $start -i "$input" -t $duration -c:v copy -c:a copy "$output"';
  }

  /// أمر دمج أصوات أو تأثيرات صوتية
  String buildAudioMixCommand(String videoInput, String audioInput, String output) {
    return '-i "$videoInput" -i "$audioInput" -c:v copy -filter_complex "[0:a][1:a]amerge=inputs=2[a]" -map 0:v -map "[a]" -ac 2 "$output"';
  }
}