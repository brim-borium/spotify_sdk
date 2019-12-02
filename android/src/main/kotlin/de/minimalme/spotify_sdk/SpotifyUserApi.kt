package de.minimalme.spotify_sdk

import com.spotify.android.appremote.api.SpotifyAppRemote
import io.flutter.plugin.common.MethodChannel

class SpotifyUserApi(spotifyAppRemote: SpotifyAppRemote?, result: MethodChannel.Result) : BaseSpotifyApi(spotifyAppRemote, result) {

    private val errorAddToLibrary = "addToLibraryError"

    private val userApi = spotifyAppRemote?.userApi

    fun addToUserLibrary(spotifyUri: String?) {
        if (userApi != null && !spotifyUri.isNullOrBlank()) {
            userApi.addToLibrary(spotifyUri)
                    .setResultCallback {result.success(true)}
                    .setErrorCallback { throwable -> result.error(errorAddToLibrary, "error when adding uri to user library", throwable.message) }
        } else if (spotifyUri.isNullOrBlank()) {
            result.error(errorAddToLibrary, "spotifyUri has invalid format", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }
}