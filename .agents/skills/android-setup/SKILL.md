---
name: android-setup
description: Explains how the Spotify App Remote SDK AAR is automatically resolved and configured on Android in the spotify_sdk package.
---

# Android Setup Skill for spotify_sdk

As of version **4.0.0-dev**, the Spotify App Remote SDK (`spotify-app-remote-*.aar`) is **automatically downloaded** during compile time by the plugin's Gradle build script. Running manual setup commands is no longer required.

## Gradle Auto-Download Workflow

When the project builds:
1. The plugin checks if the AAR exists in its local Maven layout (`packages/spotify_sdk_android/android/m2repository/`).
2. If missing, it downloads it directly from Spotify's GitHub Releases tag `v0.8.0-appremote_v2.1.0-auth`.
3. It creates a local POM file and registers this directory as a Maven repository in the `rootProject.allprojects` block, allowing the client application to resolve it transitively.

## Required Developer Configuration

The only manual setup step required for Android is declaring the redirect receiver activity in your app's `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name="com.spotify.sdk.android.auth.browser.RedirectUriReceiverActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <category android:name="android.intent.category.BROWSABLE"/>
        <data
            android:scheme="spotify-sdk"
            android:host="auth"/>
    </intent-filter>
</activity>
```

> [!WARNING]
> Since Spotify Android Auth library version 5.0.0, the activity must use the `.auth.browser.RedirectUriReceiverActivity` package path. Do not use the old `manifestPlaceholders` in `build.gradle` as they are no longer supported.
