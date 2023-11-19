# spotify_sdk

<p align="center">
<a href="https://pub.dev/packages/spotify_sdk"><img src="https://img.shields.io/badge/pub-3.0.0.dev.3-orange" alt="build"></a>
<a href="https://github.com/brim-borium/spotify_sdk"><img src="https://img.shields.io/github/stars/brim-borium/spotify_sdk?color=deeppink" alt="build"></a>
<a href="https://github.com/brim-borium/spotify_sdk/actions?query=workflow%3Aspotify_sdk"><img src="https://img.shields.io/github/actions/workflow/status/brim-borium/spotify_sdk/spotify_sdk.yml" alt="build"></a>
<a href="https://github.com/brim-borium/spotify_sdk/blob/main/LICENSE"><img src="https://img.shields.io/github/license/brim-borium/spotify_sdk?color=blue" alt="build"></a>
</p>

---

## Description

This is a flutter package that wraps the native [iOS](https://github.com/spotify/ios-sdk) and [Android](https://github.com/spotify/android-sdk) Spotify "remote" SDKs as well as the [Spotify Web Playback SDK](https://developer.spotify.com/documentation/web-playback-sdk/) for web. Since it wraps the native SDKs it has the same features and limitations.

## Setup

### Android

This package is using both the spotify-app-remote sdk and spotify-auth library. The auth library is needed to get the access token to work with the web api.

From the [Spotify Android SDK Quick Start](https://developer.spotify.com/documentation/android/quick-start/). You need two things:

1. Register your app in the [spotify developer portal](https://developer.spotify.com/dashboard/). You also need to create a sha-1 fingerprint and add this and your package name to the app settings on the dashboard as well as a redirect url.
2. Follow the steps below for either [Option A: Auto setup](#option-a-auto-setup) or [Option B: Manual setup](#option-b-manual-setup-instructions-for-android-studio-42).

#### Option A: Auto setup

Use the provided setup script to automatically download the latest version of the spotify-app-remote sdk from GitHub and setup the gradle files inside your android project. Run the following command in the root folder of your flutter project.

```bash
dart run spotify_sdk:android_setup
```

Use the `--help` flag to see all available options.

#### Option B: Manual setup, instructions for Android Studio 4.2+

Download the current [Spotify Android SDK](https://github.com/spotify/android-sdk/releases). Here you need the `spotify-app-remote-\*.aar``.

After you are all setup you need to add the SDKs `\*.aar`` file to your Android Project as Module. See the [Spotify Android SDK Quick Start](https://developer.spotify.com/documentation/android/quick-start/) for detailed information.

Since Android Studio 4.2 you need to manually perform these steps in order to add .jar/.aar files:

1. Open the android folder of your flutter project as an Android Studio project
2. In the android root folder create a single folder for `spotify-app-remote`, place the corresponding aar file and create an empty build.gradle file, like on the screenshot below:
   ![image](https://user-images.githubusercontent.com/42183561/125422846-24e03bf0-ec7f-409f-b382-0ef2d0213d08.png)
   
3.  Content of the `spotify-app-remote/build.gradle` file:

```groovy
configurations.maybeCreate("default")
artifacts.add("default", file('spotify-app-remote-release-x.x.x.aar'))
```

4. In the android root folder find `settings.gradle` file, open it and add the following line at the top of the file:

```groovy
include ':spotify-app-remote'
```

5. In the app/build.gradle add the following to the default config

```groovy
defaultConfig {
        manifestPlaceholders = [redirectSchemeName: "spotify-sdk", redirectHostName: "auth"]
        ...
    }
```

### iOS

Register your app in the [spotify developer portal](https://developer.spotify.com/dashboard/). You also need to register your Bundle ID as well as a Redirect URI.

Follow the instructions in the section `Setup the iOS SDK` of [Spotify iOS SDK Quick Start](https://developer.spotify.com/documentation/ios/quick-start/).

### Web

1. Register your app in the [spotify developer portal](https://developer.spotify.com/dashboard/). You need to provide a redirect URL which points to a dedicated page on a website you own.

2. Paste the following onto the webpage, which you linked to in your redirect URL.  
```html
<!DOCTYPE html>
<html>
  <head>
    <title>Authenticating Spotify</title>
  </head>
  <body>
	<p>Please wait while we authenticate Spotify...</p>
	<script type="text/javascript">
		if(window.opener) {
			window.opener.postMessage('?' + window.location.href.split('?')[1], "*");
		} else {
			window.close();
		}
	</script>
  </body>
</html>
```

3. Optionally add this to your Flutter app web/index.html to avoid a Javascript `TypeError: r.__extends is not a function` error in development mode.

```html
<script src="https://sdk.scdn.co/spotify-player.js"></script>
<script>
  window.onSpotifyWebPlaybackSDKReady = (evt) => {};
</script>
```

[You need Spotify Premium to access the Web SDK.](https://developer.spotify.com/documentation/web-playback-sdk/quick-start/)

## Usage

To start using this package first import it in your Dart file.

```dart
import 'package:spotify_sdk/spotify_sdk.dart';
```

To connect to the Spotify app you can call connectToSpotifyRemote(...) or getAccessToken(...). In both of these methods you need the client id, which you will find in the Spotify developer dashboard and the redirect url you set there for that specific client.

```dart
await SpotifySdk.connectToSpotifyRemote(clientId: "", redirectUrl: "")
```

Subscribe to `PlayerState` or `PlayerContext` streams only after connecting successfully

```dart
SpotifySdk.subscribePlayerState();
SpotifySdk.subscribePlayerContext();
```

If you want to use the web api as well you have to use this method to get the access token. 
You can specify multiple scopes by separating them with a comma "," as shown below. For more information on scopes you can refer to [Spotify Authorization Scopes Guide](https://developer.spotify.com/documentation/general/guides/authorization/scopes/)

```dart
final accessToken = await SpotifySdk.getAccessToken(clientId: "", redirectUrl: "", scope: "app-remote-control,user-modify-playback-state,playlist-read-private");
```

On Web you can use the token that you get from `getAccessToken(...)` and then pass it to `connectToSpotifyRemote(...)`. This will avoid having to send user through two Spotify OAuth prompts. You should not persist this token, nor supply a different token, because the refresh token is only set interally by `getAccessToken` or `connectToSpotifyRemote`.

On iOS you can store the token that you get from `getAccessToken(...)` and then pass it to `connectToSpotifyRemote(...)` during the next session. This will avoid having to switch to the Spotify app for establishing the connection. This library does not handle storing the token. It is up to you to persist it wherever you see fit. Keep in mind that this feature is currently quite buggy in the native iOS SDK and has many side effects like random disconnections. Proceed with caution.

On iOS Spotify starts playing music when attempting connection. This is a default behavior and there is no official way to prevent this with the currently supported authentication flows. You have the option to pass a Spotify URI upon connection or set it to a blank string to play the last played song. There is an undocumented workaround if you don't want music to start playing which is to pass an invalid Spotify URI instead. This is not officially supported by the Spotify SDK or this library and it can fail or stop working at any time!

Have a look [in the example](example/lib/main.dart) for detailed insights on how you can use this package.

### Token Swap

You can optionally specify "token swap" URLs to manage tokens with a backend service that protects your OAuth client secret. For more information refer to the [Spotify Token Swap and Refresh Guide](https://developer.spotify.com/documentation/ios/guides/token-swap-and-refresh/)

```dart
SpotifySdkPlugin.tokenSwapURL = 'https://example.com/api/spotify/token';
SpotifySdkPlugin.tokenRefreshURL = 'https://example.com/api/spotify/refresh';
````

On web, this package will perform an Authorization Code (without PKCE) flow, then exchange the code and refresh the token with a backend service you run at the URLs provided.

Token Swap is for now "web only". While the iOS SDK also supports the "token swap", this flow is not yet supported.

### Api

#### Connecting/Authenticating

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
| connectToSpotifyRemote  | Connects the App to Spotify | ✔ | ✔ | ✔ |
|  getAccessToken | Gets the Access Token that you can use to work with the [Web Api](https://developer.spotify.com/documentation/web-api/) | ✔ |  ✔ | ✔ |
|  disconnect | Disconnects the app connection | ✔ |  ✔ | ✔ |
|  isSpotifyAppActive | Checks if the Spotify app is active. The Spotify app will be considered active if music is playing. | ✔ |  ✔ | 🚧 |
|  subscribeConnectionStatus | Subscribes to the current player state. | ✔ |  ✔ | 🚧 |

#### Player Api

The playerApi as described [here](https://spotify.github.io/android-sdk/app-remote-lib/docs/com/spotify/android/appremote/api/PlayerApi.html).

| Function                | Description | Android | iOS | Web |
|-------------------------|---|--|---|---|
| getCrossfadeState       | Gets the current crossfade state | ✔ | ✔ | ❌ |
| getPlayerState          | Gets the current player state |✔ |  ✔ | ✔ |
| pause                   | Pauses the current track  |✔ | ✔  | ✔ |
| play                    | Plays the given spotifyUri |✔ |  ✔ | ✔ |
| playWithStreamType      | Play the given Spotify uri with specific behaviour for that streamtype | 🚧 |  🚧 | 🚧 |
| queue                   | Queues given spotifyUri |✔ | ✔  | ✔ |
| resume                  | Resumes the current track |✔ |  ✔ | ✔ |
| seekTo                  | Seeks the current track to the given position in milliseconds | ✔ | ✔ | 🚧 |
| seekToRelativePosition  | Adds to the current position of the track the given milliseconds | ✔ | ❌ | 🚧 |
| setPodcastPlaybackSpeed | Set playback speed for Podcast  | ✔ | 🚧 | 🚧 |
| setRepeatMode           | Set the repeat mode | ✔ |  ✔ | ✔ |
| setShuffle              | Set the shuffle mode | ✔ |  ✔ | ✔ |
| skipNext                | Skips to next track | ✔ | ✔  | ✔ |
| skipPrevious            | Skips to previous track |✔ |  ✔ | ✔ |
| skipToIndex             | Skips to track at specified index in album or playlist |✔ |  ✔ | 🚧  |
| subscribePlayerContext  | Subscribes to the current player context | ✔ | ✔ | ✔ |
| subscribePlayerState    | Subscribes to the current player state | ✔ | ✔ | ✔ |
| toggleRepeat            | Cycles through the repeat modes | ✔ |  ✔ | ❌ |
| toggleShuffle           | Cycles through the shuffle modes | ✔ | ❌ | ❌ |

On Web, an automatic call to play may not work due to media activation policies which send an error: "Authentication Error: Browser prevented autoplay due to lack of interaction". This error is ignored by the SDK so you can still present a button for the user to click to `play` or `resume` to start playback. See the [Web SDK Troubleshooting guide](https://developer.spotify.com/documentation/web-playback-sdk/reference/#troubleshooting) for more details.

#### Images Api

The imagesApi as described [here](https://spotify.github.io/android-sdk/app-remote-lib/docs/com/spotify/android/appremote/api/ImagesApi.html).

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
|  getImage | Get the image from the given spotifyUri | ✔ |  ✔ | 🚧 |

#### User Api

The userApi as described [here](https://spotify.github.io/android-sdk/app-remote-lib/docs/com/spotify/android/appremote/api/UserApi.html).

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
|  addToLibrary | Adds the given spotifyUri to the users library | ✔ | ✔ | 🚧 |
|  getCapabilities | Gets the current users capabilities | ✔ | ✔ | 🚧 |
|  getLibraryState | Gets the current library state | ✔ | ✔ | 🚧 |
|  removeFromLibrary | Removes the given spotifyUri to the users library | ✔ | ✔ | 🚧 |
|  subscribeCapabilities |  Subscribes to the current users capabilities | ✔ | 🚧 | 🚧 |
|  subscribeUserStatus |  Subscribes to  the current users status | ✔ | 🚧 | 🚧 |

#### Connect Api

The connectApi as described [here](https://spotify.github.io/android-sdk/app-remote-lib/docs/com/spotify/android/appremote/api/ConnectApi.html).

| Function                   | Description                                | Android | iOS | Web |
|----------------------------|--------------------------------------------|---|---|---|
| connectDecreaseVolume      | Decrease volume by a step size determined  | 🚧 | 🚧 | 🚧 |
| connectIncreaseVolume      | Increase volume by a step size determined  | 🚧 | 🚧 | 🚧 |
| connectSetVolume           | Set a volume on the currently active device | 🚧 | 🚧 | 🚧 |
| connectSwitchToLocalDevice | Switch to play music on this (local) device | ✔ | 🚧 | 🚧 |
| subscribeToVolumeState     | Subscribe to volume state                  | 🚧 | 🚧 | 🚧 |

#### Content Api

The contentApi as described [here](https://spotify.github.io/android-sdk/app-remote-lib/docs/com/spotify/android/appremote/api/ContentApi.html).

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
| getChildrenOfItem | tbd | 🚧 | 🚧 | 🚧 |
| getRecommendedContentItems | tbd | 🚧 | 🚧 | 🚧 |
| playContentItem | tbd | 🚧 | 🚧 | 🚧 |

## Migration 

### spotify-auth: moving from locally sourced aar to maven central
`spotify-auth` SDK is now retrieved via Maven Central instead of being sourced from an AAR file
* Steps to remove the locally sourced `spotify-auth` SDK:
   * android/settings.gradle -> remove `':spotify-auth'`
   * android/spotify-auth/build.gradle -> remove file
   * android/spotify-auth/spotify-auth-release-x.x.x.aar -> remove file

## Official Spotify Docs

- [Auth](https://spotify.github.io/android-sdk/auth-lib/docs/index.html)
- [App Remote](https://spotify.github.io/android-sdk/app-remote-lib/docs/index.html)
- [Web Playback SDK](https://developer.spotify.com/documentation/web-playback-sdk/)


