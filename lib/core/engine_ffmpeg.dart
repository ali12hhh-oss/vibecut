// المحرك المساعد المبني على ffmpeg_kit_flutter_new (نسخة مُدارة من ffmpeg-kit)
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

class EngineFFmpeg {
  
  // دالة القص (Trim)
  Future<void> trimVideo(String input, String output, String start, String duration) async {
    final command = '-i "$input" -ss $start -t $duration -c copy "$output"';
    
    await FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        print("Trim operation successful");
      }
    });
  }

  // دالة دمج فيديو مع نص (Arabic/English)
  Future<void> addTextOverlay(String input, String output, String text, String position) async {
    // FFmpeg يدعم الخطوط والـ Drawtext
    final escapedText = text.replaceAll("'", "\\'").replaceAll(':', '\\:');
    final command = '-i "$input" -vf "drawtext=text=\'$escapedText\':x=$position" -c:a copy "$output"';
    await FFmpegKit.execute(command);
  }
}
