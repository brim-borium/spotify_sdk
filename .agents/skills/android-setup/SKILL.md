---
name: android-setup
description: Downloads and configures the Spotify App Remote SDK AAR file for the Android platform module in the spotify_sdk package. Use this skill when building the Android module or setting up the workspace on Android.
---

# Android Setup Skill for spotify_sdk

The Spotify App Remote SDK (`spotify-app-remote-*.aar`) is not checked into version control. It must be downloaded and set up locally for Android compilation.

## When to Use
- When you first clone the repository and need to compile or run the project on Android.
- If Android builds fail due to missing dependencies on `spotify-app-remote` or class/module import failures.

## Workflow

### 1. Setting up the Android SDK
Run the built-in Dart CLI setup script from the root of the project:
```bash
dart run spotify_sdk:android_setup
```

This script:
1. Connects to GitHub releases of the Spotify Android SDK.
2. Downloads the required `.aar` file.
3. Automatically places it in `android/spotify-app-remote/`.
4. Dynamically updates `android/settings.gradle` and `android/spotify-app-remote/build.gradle`.

### 2. Troubleshooting & Cleaning Up
If the Android setup or Gradle build gets into a broken state, run:
```bash
dart run spotify_sdk:android_setup --cleanup
```
And then re-run:
```bash
dart run spotify_sdk:android_setup --verbose
```

> [!TIP]
> The `--verbose` flag is highly recommended for troubleshooting network connection issues or Gradle dependency mapping issues during the SDK download.
