package de.minimalme.spotify_sdk.handlers

import com.google.gson.Gson
import de.minimalme.spotify_sdk.RemoteManager
import de.minimalme.spotify_sdk.SpotifySdkConstants
import io.flutter.plugin.common.MethodChannel.Result

class LibraryHandler(private val remoteManager: RemoteManager) {

    fun addToUserLibrary(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error(SpotifySdkConstants.ERROR_ADD_TO_LIBRARY, "spotifyUri has invalid format or is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.userApi.addToLibrary(spotifyUri)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_ADD_TO_LIBRARY, "error when adding to user library: $spotifyUri", throwable.toString()) }
        }
    }

    fun removeFromUserLibrary(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error(SpotifySdkConstants.ERROR_REMOVE_FROM_LIBRARY, "spotifyUri has invalid format or is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.userApi.removeFromLibrary(spotifyUri)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_REMOVE_FROM_LIBRARY, "error when removing from user library: $spotifyUri", throwable.toString()) }
        }
    }

    fun getCapabilities(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.userApi.capabilities
                .setResultCallback { capabilities -> result.success(Gson().toJson(capabilities)) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_GET_CAPABILITIES, "error when getting user capabilities", throwable.toString()) }
        }
    }

    fun getLibraryState(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error(SpotifySdkConstants.ERROR_GET_LIBRARY_STATE, "spotifyUri has invalid format or is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.userApi.getLibraryState(spotifyUri)
                .setResultCallback { libraryState -> result.success(Gson().toJson(libraryState)) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_GET_LIBRARY_STATE, "error when getting library state for uri: $spotifyUri", throwable.toString()) }
        }
    }
}
