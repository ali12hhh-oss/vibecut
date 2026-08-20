class ProjectSettings {
  const ProjectSettings({
    this.languageCode = 'ar',
    this.activeFont = 'Tajawal',
    this.isDarkMode = true,
    this.width = 1080,
    this.height = 1920,
    this.framesPerSecond = 30,
    this.videoBitrate = '8M',
    this.audioBitrate = '192k',
  });

  final String languageCode;
  final String activeFont;
  final bool isDarkMode;
  final int width;
  final int height;
  final int framesPerSecond;
  final String videoBitrate;
  final String audioBitrate;

  double get aspectRatio => width / height;
}
