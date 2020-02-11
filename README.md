# spotify_sdk

[![licence](https://img.shields.io/badge/licence-MIT-blue.svg)](https://github.com/IamTobi/spotify_sdk/blob/master/LICENSE)
[![pub package](https://img.shields.io/badge/pub-0.3.2-orange)](https://pub.dev/packages/spotify_sdk)

## Description

This will be a spotify_sdk package for flutter using both the spotify-app-remote sdk and spotify-auth library. The auth library is needed to get the authentication token to work with the web api.

## Setup

### Android

From the [Spotify Android SDK Quick Start](https://developer.spotify.com/documentation/android/quick-start/). You need two things:

1. register your app in the [spotify developer portal](https://developer.spotify.com/dashboard/). You also need to create a sha-1 fingerprint and add this and your package name to the app settings on the dashboard as well as a redirect url.
2. download the current [Spotify Android SDK](https://github.com/spotify/android-sdk/releases). Here you need the spotify-app-remote-*.aar and spotify-auth-*.aar.

After you are all setup you need to add the *.aar files to your Android Project as Modules. See the [Spotify Android SDK Quick Start](https://developer.spotify.com/documentation/android/quick-start/) for detailed information.

Important here is the naming so that the package can find the modules.

- Remote: spotify-app-remote
- Auth: spotify-auth

## Usage

To start using this package you first have to connect to Spotify. To only connect you can do this with connectToSpotifyRemote(...) or getAuthenticationToken(...) in both of these methods you need the client id, given in the spotify dashboard and the redirect url you set in the settings on the dashboard.

```dart
await SpotifySdk.connectToSpotifyRemote(clientId: "", redirectUrl: "")
```

If you want to use the web api aswell you have to use this method to get the authentication token.

```dart
var authenticationToken = await SpotifySdk.getAuthenticationToken(clientId: "", redirectUrl: "");
```

tbd...

Have a look [here](example/lib/main.dart) for a more detailed example.

### Api

#### Connecting/Authenticating

| Function  | Description| Android | iOS |
|---|---|---|--|
| connectToSpotifyRemote  | Connects the App to Spotify | :heavy_check_mark: | :construction_worker:  |  
|  getAuthenticationToken | Gets the Authentication Token that you can use to work with the [Web Api](https://developer.spotify.com/documentation/web-api/) |:heavy_check_mark: |  :construction_worker: |  
|  logout | logs the user out and disconnects the app connection |:construction_worker: |  :construction_worker: |

#### Player Api

| Function  | Description| Android | iOS |
|---|---|---|--|
|  getCrossfadeState | Gets the current crossfade state |:heavy_check_mark:  |  :construction_worker: |
|  getPlayerState | Gets the current player state |:heavy_check_mark:  |  :construction_worker: |
|  pause | Pauses the current track  |:heavy_check_mark: | :construction_worker:  |
|  play | Plays the given spotifyUri |:heavy_check_mark: |  :construction_worker: |
|  queue | Queues given spotifyUri |:heavy_check_mark: | :construction_worker:  |
|  resume | Resumes the current track |:heavy_check_mark: |  :construction_worker: |
|  skipNext | Skips to next track | :heavy_check_mark: | :construction_worker:  |
|  skipPrevious | Skips to previous track |:heavy_check_mark:  |  :construction_worker: |
|  seekTo | Seeks the current track to the given position in milliseconds | :heavy_check_mark:   |:construction_worker: |
|  seekToRelativePosition | Adds to the current position of the track the given milliseconds |:heavy_check_mark:  |  :construction_worker: |
|  subscribeToPlayerContext | Subscribes to the current player context |:heavy_check_mark:|:construction_worker: |
|  subscribeToPlayerState| Subscribes to the current player state |:heavy_check_mark:  |:construction_worker:|
|  getCrossfadeState | Gets the current crossfade state |:heavy_check_mark:  |  :construction_worker: |
|  toggleShuffle | Cycles through the shuffle modes |:heavy_check_mark: |  :construction_worker: |
|  toggleRepeat | Cycles through the repeat modes | :heavy_check_mark: |  :construction_worker: |

#### Images Api

| Function  | Description| Android | iOS |
|---|---|---|--|
|  getImage | Get the image from the given spotifyUri |:construction_worker: |  :construction_worker: |

#### User Api

| Function  | Description| Android | iOS |
|---|---|---|--|
|  addToLibrary | Adds the given spotifyUri to the users library |:heavy_check_mark:  |  :construction_worker: |
|  getCapabilities | Gets the current users capabilities |:heavy_check_mark:  |  :construction_worker: |
|  getLibraryState | Gets the current library state |:heavy_check_mark:  |  :construction_worker: |
|  removeFromLibrary | Removes the given spotifyUri to the users library |:heavy_check_mark:  |  :construction_worker: |
|  subscribeToCapabilities |  Subscribes to the current users capabilities |:heavy_check_mark:  |  :construction_worker: |
|  subscribeToUserStatus |  Subscrives to  the current users status |:heavy_check_mark:  |  :construction_worker: |

#### Connect Api

| Function  | Description| Android | iOS |
|---|---|---|--|
|  connectSwitchToLocalDevice | Switch to play music on this (local) device |:construction_worker:  |  :construction_worker: |

#### Content Api

| Function  | Description| Android | iOS |
|---|---|---|--|
| getChildrenOfItem | tbd |:construction_worker:  |  :construction_worker: |
| getRecommendedContentItems | tbd |:construction_worker:  |  :construction_worker: |
| playContentItem | tbd |:construction_worker:  |  :construction_worker: |

## Official Spotify Docs

- [Auth](https://spotify.github.io/android-sdk/auth-lib/docs/index.html)
- [App Remote](https://spotify.github.io/android-sdk/app-remote-lib/docs/index.html)
