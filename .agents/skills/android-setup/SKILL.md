---
name: android-setup
description: Configure or clean Spotify App Remote SDK AAR resolution on Android.
---

# Android Setup (`android-setup`)

The Spotify App Remote SDK (`spotify-app-remote-*.aar`) is automatically downloaded at compile time by the plugin's Gradle build script.

## Gradle Resolution

When the project builds:
1. The plugin checks for the AAR in `packages/spotify_sdk_android/android/m2repository/`.
2. If missing, Gradle fetches it from Spotify GitHub Releases (`v0.8.0-appremote_v2.1.0-auth`).
3. Registers local Maven repository in `rootProject.allprojects` for transitive resolution.

## Manifest Configuration

Declare the redirect receiver in `android/app/src/main/AndroidManifest.xml`:

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
> Use `com.spotify.sdk.android.auth.browser.RedirectUriReceiverActivity`. Legacy `manifestPlaceholders` are unsupported.

