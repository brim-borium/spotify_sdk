## 2.1.0
* BREAKING: setShuffle now does not expect a named argument
* fixes accessToken being ignored in connectToSpotify()
* exposes spotifyURI on connectToSpotify() method
* fixes the web implementation not using the authentication scopes supplied by the user
* fix a crash when calling subscribeToConnectionStatus
* fix a bug where the webplayer would not dispose
* add null safety to example app

## 2.0.0
* BREAKING: opt into null safety
* upgrade Dart SDK constraints to >=2.12.0-0 <3.0.0

## 1.0.2
* fixes image dimension exception on getImage

## 1.0.1
* improves error reporting on iOS
* supports adding additional scopes for iOS
* offers option to start radio while connecting to Spotify
* updates packages

## 1.0.0
* __adds support for iOS__ 🎉 (thanks [fotiDim](https://github.com/fotiDim))
* adapts to breaking changes in the spotify android sdk (thanks [itsMatoosh](https://github.com/itsMatoosh))
* implements PKCE auth flow for the web implementation (thanks [itsMatoosh](https://github.com/itsMatoosh))
* adds the `setShuffle()` and `setRepeatMode()` APIs for Android (thanks [Joran-Dob](https://github.com/Joran-Dob))
* renames logout to disconnect
* adds `accessToken` as an optional parameter to `connectToSpotifyRemote()` (only supported on iOS)
* some minor bug fixing

## 0.5.0
* adds support for web (thanks [itsMatoosh](https://github.com/itsMatoosh))
* adds custom scopes for the web api (thanks [arnav-sh](https://github.com/arnav-sh))
* adds logout functionality for android
* moved from [pedantic](https://pub.dev/packages/pedantic) to [lint](https://pub.dev/packages/lint) for static analyses
* some minor bug fixing

## 0.3.4

* adds handling of unexpected disconnects from Spotify via subscribeConnectionStatus()-Stream(thanks [itsMatoosh](https://github.com/itsMatoosh))
* adds usage of .env file for the example project
* fixes some minor error message issues

## 0.3.3

* adds getImage to get an Image from any spotifyURI (thanks [eddwhite](https://github.com/eddwhite))
* fixes some minor issues
* raised dart-sdk version to 2.7.0

## 0.3.2

* fixes compatibility with spotify-auth dependency above version 1.2.0 (thanks [itsMatoosh](https://github.com/itsMatoosh))
  * spotify introduced some breaking changes: Rename classes from Authentication<code>ClassName</code> to Authorization<code>ClassName</code>

## 0.3.1

* fixes wrong links and incorrect docs

## 0.3.0

* android user api implementation finished
  * remove from library
  * subscribe to user status
  * subscribe to capabilities
  * get librarystate
* updated package references

## 0.2.0

* android player api implementation subscriptions finished
  * subscribe to playerContext and playerState now possible
* added more instructions for android
* code refactoring
* extended the example
* extended the documentation

## 0.1.0

* android player api implementation finished
* error handling finished
* setup instructions for android finished
* naming for modules finished

## 0.0.4

* added instructions for android
* fixed naming for modules

## 0.0.3

* added the following implementations for android:
  * getCrossfadeState
  * getPlayerState
* general refactoring of the native android implementation
* adds documentation to all methods
* adds json_annotation: ^3.0.0, build_runner: ^1.0.0, json_serializable: ^3.2.0 to make use of some json serializing functionality for the crossfadeState and PlayerState

## 0.0.2

* added the following implementations for android:
  * resume
  * skip next
  * skip previous
  * seek to
  * seek to relative
* splitted remote authorization and token retrieval in two seperate functions
* implemented the example project
* added logger package for prettier logs

## 0.0.1

* Added latests spotify-app-remote (v7.0.0) and spotify-auth (v1.1.0)  from <https://github.com/spotify/android-sdk/releases>
* finished android native implementation for
  * authorization with token response
  * play
  * pause
  * queue
  * toggleShuffle
  * toggleRepeat
  * addToLibrary
