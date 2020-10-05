# spotify_sdk

[![pub package](https://img.shields.io/badge/pub-1.0.0-orange)](https://pub.dev/packages/spotify_sdk)
[![Dry Run](https://github.com/brim-borium/spotify_sdk/workflows/Dry%20Run/badge.svg?branch=master)](https://github.com/brim-borium/spotify_sdk/actions?query=workflow%3A%22Dry+Run%22)
[![licence](https://img.shields.io/badge/licence-MIT-blue.svg)](https://github.com/IamTobi/spotify_sdk/blob/master/LICENSE)

## Description

This will be a spotify_sdk package for flutter using both the spotify-app-remote sdk and spotify-auth library. The auth library is needed to get the authentication token to work with the web api.

## Setup

### Android

From the [Spotify Android SDK Quick Start](https://developer.spotify.com/documentation/android/quick-start/). You need two things:

1. Register your app in the [spotify developer portal](https://developer.spotify.com/dashboard/). You also need to create a sha-1 fingerprint and add this and your package name to the app settings on the dashboard as well as a redirect url.
2. download the current [Spotify Android SDK](https://github.com/spotify/android-sdk/releases). Here you need the spotify-app-remote-*.aar and spotify-auth-*.aar.

After you are all setup you need to add the *.aar files to your Android Project as Modules. See the [Spotify Android SDK Quick Start](https://developer.spotify.com/documentation/android/quick-start/) for detailed information.

Important here is the naming so that the package can find the modules.

- Remote: spotify-app-remote
- Auth: spotify-auth

### iOS

From the [Spotify iOS SDK Quick Start](https://developer.spotify.com/documentation/ios/quick-start/). You need two things:

1. Register your app in the [spotify developer portal](https://developer.spotify.com/dashboard/). You also need to register your Bundle ID as well as a Redirect URI.
2. download the current [Spotify iOS SDK](https://github.com/spotify/ios-sdk/releases). Here you need `SpotifyiOS.framework` from the zip file.

After you are all setup you need to add `SpotifyiOS.framework` to your iOS Project. See the [Spotify iOS SDK Quick Start](https://developer.spotify.com/documentation/ios/quick-start/) for detailed information.

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
| connectToSpotifyRemote  | Connects the App to Spotify | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
|  getAuthenticationToken | Gets the Authentication Token that you can use to work with the [Web Api](https://developer.spotify.com/documentation/web-api/) |:heavy_check_mark: |  :heavy_check_mark: | :heavy_check_mark: |
|  disconnect | disconnects the app connection |:heavy_check_mark: |  :heavy_check_mark: | :heavy_check_mark: |

#### Player Api

| Function  | Description | Android | iOS | Web |
|---|---|---|---|---|
|  getPlayerState | Gets the current player state |:heavy_check_mark:  |  :heavy_check_mark: | :heavy_check_mark: |
|  pause | Pauses the current track  |:heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: |
|  play | Plays the given spotifyUri |:heavy_check_mark: |  :heavy_check_mark: | :heavy_check_mark: |
|  queue | Queues given spotifyUri |:heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: |
|  resume | Resumes the current track |:heavy_check_mark: |  :heavy_check_mark: | :heavy_check_mark: |
|  skipNext | Skips to next track | :heavy_check_mark: | :heavy_check_mark:  | :heavy_check_mark: |
|  skipPrevious | Skips to previous track |:heavy_check_mark:  |  :heavy_check_mark: | :heavy_check_mark: |
|  seekTo | Seeks the current track to the given position in milliseconds | :heavy_check_mark: |:heavy_check_mark: | :construction_worker: |
|  seekToRelativePosition | Adds to the current position of the track the given milliseconds |:heavy_check_mark: |  :x: | :construction_worker: |
|  subscribeToPlayerContext | Subscribes to the current player context |:heavy_check_mark:|:heavy_check_mark: | :heavy_check_mark: |
|  subscribeToPlayerState| Subscribes to the current player state |:heavy_check_mark:  | :heavy_check_mark: | :heavy_check_mark: |
|  getCrossfadeState | Gets the current crossfade state |:heavy_check_mark:  |  :heavy_check_mark: | :x: |
|  toggleShuffle | Cycles through the shuffle modes |:heavy_check_mark: |  :x: | :x: |
|  setShuffle | Set the shuffle mode | :heavy_check_mark: |  :heavy_check_mark: | :heavy_check_mark: |
|  toggleRepeat | Cycles through the repeat modes | :heavy_check_mark: |  :heavy_check_mark: | :x: |
|  setRepeatMode | Set the repeat mode | :heavy_check_mark: |  :heavy_check_mark: | :heavy_check_mark: |

#### Images Api

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
|  getImage | Get the image from the given spotifyUri |:heavy_check_mark: |  :heavy_check_mark: | :construction_worker: |

#### User Api

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
|  addToLibrary | Adds the given spotifyUri to the users library |:heavy_check_mark:  |  :heavy_check_mark: | :construction_worker: |
|  getCapabilities | Gets the current users capabilities |:heavy_check_mark:  |  :construction_worker: | :construction_worker: |
|  getLibraryState | Gets the current library state |:heavy_check_mark:  |  :construction_worker: | :construction_worker: |
|  removeFromLibrary | Removes the given spotifyUri to the users library |:heavy_check_mark:  |  :heavy_check_mark: | :construction_worker: |
|  subscribeToCapabilities |  Subscribes to the current users capabilities |:heavy_check_mark:  |  :construction_worker: | :construction_worker: |
|  subscribeToUserStatus |  Subscrives to  the current users status |:heavy_check_mark:  |  :construction_worker: | :construction_worker: |

#### Connect Api

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
|  connectSwitchToLocalDevice | Switch to play music on this (local) device |:construction_worker:  |  :construction_worker: | :construction_worker: |

#### Content Api

| Function  | Description| Android | iOS | Web |
|---|---|---|---|---|
| getChildrenOfItem | tbd |:construction_worker:  |  :construction_worker: | :construction_worker: |
| getRecommendedContentItems | tbd |:construction_worker:  |  :construction_worker: | :construction_worker: |
| playContentItem | tbd |:construction_worker:  |  :construction_worker: | :construction_worker: |

## Official Spotify Docs

- [Auth](https://spotify.github.io/android-sdk/auth-lib/docs/index.html)
- [App Remote](https://spotify.github.io/android-sdk/app-remote-lib/docs/index.html)
