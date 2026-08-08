package de.minimalme.spotify_sdk.handlers

import com.google.gson.Gson
import de.minimalme.spotify_sdk.RemoteManager
import io.flutter.plugin.common.MethodChannel.Result

class LibraryHandler(private val remoteManager: RemoteManager) {

    fun addToUserLibrary(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error("addToLibraryError", "spotifyUri has invalid format or is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.userApi.addToLibrary(spotifyUri)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("addToLibraryError", "error when adding to user library: $spotifyUri", throwable.toString()) }
        }
    }

    fun removeFromUserLibrary(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error("removeFromLibraryError", "spotifyUri has invalid format or is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.userApi.removeFromLibrary(spotifyUri)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("removeFromLibraryError", "error when removing from user library: $spotifyUri", throwable.toString()) }
        }
    }

    fun getCapabilities(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.userApi.capabilities
                .setResultCallback { capabilities -> result.success(Gson().toJson(capabilities)) }
                .setErrorCallback { throwable -> result.error("getCapabilitiesError", "error when getting user capabilities", throwable.toString()) }
        }
    }

    fun getLibraryState(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error("getLibraryStateError", "spotifyUri has invalid format or is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.userApi.getLibraryState(spotifyUri)
                .setResultCallback { libraryState -> result.success(Gson().toJson(libraryState)) }
                .setErrorCallback { throwable -> result.error("getLibraryStateError", "error when getting library state for uri: $spotifyUri", throwable.toString()) }
        }
    }
}
