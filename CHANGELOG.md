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
