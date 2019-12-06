# spotify_sdk
[![](https://img.shields.io/badge/licence-MIT-blue.svg)](https://github.com/IamTobi/spotify_sdk/blob/master/LICENSE)
[![](https://img.shields.io/badge/pub-v0.0.3-blueviolet.svg)](https://pub.dev/packages/spotify_sdk)

## Description

This will be a spotify_sdk package for flutter using both the spotify-app-remote sdk and spotify-auth library. The auth library is needed to get the authentication token to work with the web api. 

## Instructions

tbd

## Api

| Function  | Description| Android | iOS |
|---|---|---|--|
| connectToSpotifyRemote  | Connects the App to Spotify | :heavy_check_mark: | :construction_worker:  |  
|  getAuthenticationToken | Gets the Authentication Token that you can use to work with the [Web Api](https://developer.spotify.com/documentation/web-api/) |:heavy_check_mark: |  :construction_worker: |  
|  queue | Queues given spotifyUri |:heavy_check_mark: | :construction_worker:  |
|  play | Plays the given spotifyUri |:heavy_check_mark: |  :construction_worker: |
|  pause | Pauses the current track  |:heavy_check_mark: | :construction_worker:  |
|  resume | Resumes the current track |:heavy_check_mark: |  :construction_worker: |
|  skipNext | Skips to next track | :heavy_check_mark: | :construction_worker:  |
|  skipPrevious | Skips to previous track |:heavy_check_mark:  |  :construction_worker: |
|  seekTo | Seeks the current track to the given position in milliseconds | :heavy_check_mark:   |:construction_worker: |   |
|  seekToRelativePosition | Adds to the current position of the track the given milliseconds |:heavy_check_mark:  |  :construction_worker: |
|  toggleShuffle | Cycles through the shuffle modes |:heavy_check_mark: |  :construction_worker: |
|  toggleRepeat | Cycles through the repeat modes | :heavy_check_mark: |  :construction_worker: |
|  addToLibrary | Adds the given spotifyUri to the users library |:heavy_check_mark:  |  :construction_worker: |
|  getCrossfadeState | Gets the current crossfade state |:heavy_check_mark:  |  :construction_worker: |
|  getPlayerState | Gets the current player state |:heavy_check_mark:  |  :construction_worker: |
|  getImage | Get the image from the given spotifyUri |:construction_worker: |  :construction_worker: |
|  logout | logs the user out and disconnects the app connection |:construction_worker: |  :construction_worker: |


## Docs

- [Auth](https://spotify.github.io/android-sdk/auth-lib/docs/index.html) 
- [App Remote](https://spotify.github.io/android-sdk/app-remote-lib/docs/index.html) 





