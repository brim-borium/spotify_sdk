package de.minimalme.spotify_sdk

import com.google.gson.Gson
import com.spotify.android.appremote.api.SpotifyAppRemote
import io.flutter.plugin.common.MethodChannel

class SpotifyUserApi(spotifyAppRemote: SpotifyAppRemote?, result: MethodChannel.Result) : BaseSpotifyApi(spotifyAppRemote, result) {

    private val errorAddToLibrary = "addToLibraryError"
    private val errorRemoveFromLibrary = "removeFromLibraryError"
    private val errorGettingCapabilities = "getCapabilitiesError"
    private val errorGettingLibraryState = "getLibraryStateError"

    private val userApi = spotifyAppRemote?.userApi

    fun addToUserLibrary(spotifyUri: String?) {
        if (userApi != null && !spotifyUri.isNullOrBlank()) {
            userApi.addToLibrary(spotifyUri)
                    .setResultCallback {result.success(true)}
                    .setErrorCallback { throwable -> result.error(errorAddToLibrary, "error when adding uri to user library", throwable.toString()) }
        } else if (spotifyUri.isNullOrBlank()) {
            result.error(errorAddToLibrary, "spotifyUri has invalid format", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    fun removeFromUserLibrary(spotifyUri: String?){
        if (userApi != null && !spotifyUri.isNullOrBlank()) {
            userApi.removeFromLibrary(spotifyUri)
                    .setResultCallback {result.success(true)}
                    .setErrorCallback { throwable -> result.error(errorRemoveFromLibrary, "error when removing uri from user library", throwable.toString()) }
        } else if (spotifyUri.isNullOrBlank()) {
            result.error(errorRemoveFromLibrary, "spotifyUri has invalid format", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    fun getCapabilities(){
        if (userApi != null) {
            userApi.capabilities
                    .setResultCallback {capabilities ->  result.success(Gson().toJson(capabilities))}
                    .setErrorCallback { throwable -> result.error(errorGettingCapabilities, "error when getting capabilities", throwable.toString()) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    fun getLibraryState(spotifyUri: String?){
        if (userApi != null && !spotifyUri.isNullOrBlank()) {
            userApi.getLibraryState(spotifyUri)
                    .setResultCallback {libraryState ->  result.success(Gson().toJson(libraryState))}
                    .setErrorCallback { throwable -> result.error(errorGettingLibraryState, "error when getting the library state", throwable.toString()) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }
}