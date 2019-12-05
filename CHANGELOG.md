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

* Added latests spotify-app-remote (v7.0.0) and spotify-auth (v1.1.0)  from https://github.com/spotify/android-sdk/releases
* finished android native implementation for
    * authorization with token response 
    * play
    * pause
    * queue
    * toggleShuffle
    * toggleRepeat
    * addToLibrary


