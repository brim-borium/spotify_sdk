# spotify_sdk

[![pub package](https://img.shields.io/badge/pub-1.0.1-orange)](https://pub.dev/packages/spotify_sdk)
[![build](https://github.com/brim-borium/spotify_sdk/workflows/spotify_sdk/badge.svg?branch=master)](https://github.com/brim-borium/spotify_sdk/actions?query=workflow%3Aspotify_sdk)
[![licence](https://img.shields.io/badge/licence-MIT-blue.svg)](https://github.com/IamTobi/spotify_sdk/blob/master/LICENSE)

## Description

This is a flutter package that wraps the native [iOS](https://github.com/spotify/ios-sdk) and [Android](https://github.com/spotify/android-sdk) Spotify "remote" SDKs as well as the [Spotify Web Playback SDK](https://developer.spotify.com/documentation/web-playback-sdk/) for web.

## Installation

To use this plugin, add `spotify_sdk` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

## Setup

### Android

This package is using both the spotify-app-remote sdk and spotify-auth library. The auth library is needed to get the authentication token to work with the web api.

From the [Spotify Android SDK Quick Start](https://developer.spotify.com/documentation/android/quick-start/). You need two things:

1. Register your app in the [spotify developer portal](https://developer.spotify.com/dashboard/). You also need to create a sha-1 fingerprint and add this and your package name to the app settings on the dashboard as well as a redirect url.
2. download the current [Spotify Android SDK](https://github.com/spotify/android-sdk/releases). Here you need the spotify-app-remote-*.aar and spotify-auth-*.aar.

After you are all setup you need to add the *.aar files to your Android Project as Modules. See the [Spotify Android SDK Quick Start](https://developer.spotify.com/documentation/android/quick-start/) for detailed information.

Important here is the naming so that the package can find the modules.

- Remote: spotify-app-remote
- Auth: spotify-auth

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

[You need Spotify Premium to access the Web SDK.](https://developer.spotify.com/documentation/web-playback-sdk/quick-start/)

## Usage

To start using this package you first have to connect to Spotify. To only connect you can do this with connectToSpotifyRemote(...) or getAuthenticationToken(...) in both of these methods you need the client id, given in the spotify dashboard and the redirect url you set in the settings on the dashboard.
You can also optionally pass an accessToken and on iOS it avoids having to switch to the Spotify app for establishing the connection.
```dart
  await SpotifySdk.connectToSpotifyRemote(clientId: "", redirectUrl: "")
```

If you want to use the web api as well you have to use this method to get the authentication token. 
You can specify multiple scopes by separating them with a comma "," as shown below. For more information on scopes you can refer to [Spotify Authorization Scopes Guide](https://developer.spotify.com/documentation/general/guides/scopes/)

```dart
  var authenticationToken = await SpotifySdk.getAuthenticationToken(clientId: "", redirectUrl: "", scope: "app-remote-control,user-modify-playback-state,playlist-read-private");
```

Have a look [in the example](example/lib/main.dart) for detailed insights on how you can use this package.

### Api

#### Connecting/Authenticating

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
| connectToSpotifyRemote  | Connects the App to Spotify | ✔ | ✔ | ✔ |
|  getAuthenticationToken | Gets the Authentication Token that you can use to work with the [Web Api](https://developer.spotify.com/documentation/web-api/) |✔ |  ✔ | ✔ |
|  disconnect | disconnects the app connection |✔ |  ✔ | ✔ |

#### Player Api

| Function  | Description | Android | iOS | Web |
|---|---|---|---|---|
|  getPlayerState | Gets the current player state |✔  |  ✔ | ✔ |
|  pause | Pauses the current track  |✔ | ✔  | ✔ |
|  play | Plays the given spotifyUri |✔ |  ✔ | ✔ |
|  queue | Queues given spotifyUri |✔ | ✔  | ✔ |
|  resume | Resumes the current track |✔ |  ✔ | ✔ |
|  skipNext | Skips to next track | ✔ | ✔  | ✔ |
|  skipPrevious | Skips to previous track |✔  |  ✔ | ✔ |
|  seekTo | Seeks the current track to the given position in milliseconds | ✔ | ✔ | 🚧 |
|  seekToRelativePosition | Adds to the current position of the track the given milliseconds | ✔ | ❌ | 🚧 |
|  subscribeToPlayerContext | Subscribes to the current player context | ✔ | ✔ | ✔ |
|  subscribeToPlayerState| Subscribes to the current player state | ✔  | ✔ | ✔ |
|  getCrossfadeState | Gets the current crossfade state | ✔  | ✔ | ❌ |
|  toggleShuffle | Cycles through the shuffle modes | ✔ | ❌ | ❌ |
|  setShuffle | Set the shuffle mode | ✔ |  ✔ | ✔ |
|  toggleRepeat | Cycles through the repeat modes | ✔ |  ✔ | ❌ |
|  setRepeatMode | Set the repeat mode | ✔ |  ✔ | ✔ |

#### Images Api

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
|  getImage | Get the image from the given spotifyUri | ✔ |  ✔ | 🚧 |

#### User Api

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
|  addToLibrary | Adds the given spotifyUri to the users library | ✔ | ✔ | 🚧 |
|  getCapabilities | Gets the current users capabilities | ✔ | 🚧 | 🚧 |
|  getLibraryState | Gets the current library state | ✔ | 🚧 | 🚧 |
|  removeFromLibrary | Removes the given spotifyUri to the users library | ✔ | ✔ | 🚧 |
|  subscribeToCapabilities |  Subscribes to the current users capabilities | ✔ | 🚧 | 🚧 |
|  subscribeToUserStatus |  Subscrives to  the current users status | ✔ | 🚧 | 🚧 |

#### Connect Api

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
|  connectSwitchToLocalDevice | Switch to play music on this (local) device | 🚧 | 🚧 | 🚧 |

#### Content Api

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
| getChildrenOfItem | tbd | 🚧 | 🚧 | 🚧 |
| getRecommendedContentItems | tbd | 🚧 | 🚧 | 🚧 |
| playContentItem | tbd | 🚧 | 🚧 | 🚧 |

## Official Spotify Docs

- [Auth](https://spotify.github.io/android-sdk/auth-lib/docs/index.html)
- [App Remote](https://spotify.github.io/android-sdk/app-remote-lib/docs/index.html)
