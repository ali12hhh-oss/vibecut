# Build readiness checklist

The project is prepared for a Flutter Android build with free/permissive tooling and local FFmpeg processing.

## Required local tools

- Flutter SDK 3.x with Dart 3.x.
- Android Studio or Android command-line tools.
- Java 17, matching the Android Gradle configuration.

## Commands

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Release notes

Before publishing a release, run a license audit for all bundled fonts, stickers, LUTs, overlays, and transitions. Remove every asset whose redistribution or commercial use cannot be proven.
