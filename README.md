# Podomoro

Podomoro is a Flutter Pomodoro timer with music playback, notification sounds, session statistics, and English or Indonesian UI.

## Features

- Focus and break timer
- Music queue synced with the timer
- Session statistics
- Notification sound preview and playback
- English and Indonesian language support

## Run Locally

Requirements:

- Flutter stable
- Android SDK for Android builds

Commands:

```bash
flutter pub get
flutter run
```

## Android Release

This project includes a GitHub Actions workflow that:

- runs only when the `version:` value in `pubspec.yaml` changes
- runs only for pushes to `main`
- builds a signed `apk --release`
- publishes the APK to GitHub Releases

Release tag format:

- `v<version-from-pubspec>`

Required GitHub Secrets:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Output file:

- `podomoro-<version>-android-release.apk`
