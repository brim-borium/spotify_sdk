package de.minimalme.spotify_sdk

import com.spotify.android.appremote.api.SpotifyAppRemote
import io.flutter.plugin.common.MethodChannel

class SpotifyUserApi(private val spotifyAppRemote: SpotifyAppRemote?) {

    private val errorAppRemoteNull = "spotifyAppRemoteNull"
    private val errorAddToLibrary = "addToLibraryError"

    fun addToUserLibrary(spotifyUri: String?, result: MethodChannel.Result) {
        if (spotifyAppRemote != null && !spotifyUri.isNullOrBlank()) {
            spotifyAppRemote.userApi.addToLibrary(spotifyUri)
                    .setResultCallback {
                        result.success(true)
                        result.error(errorAddToLibrary, "error when adding uri to user library", "")
                    }
        } else if (spotifyUri.isNullOrBlank()) {
            result.error(errorAddToLibrary, "spotifyUri has invalid format", "")
        } else {
            spotifyRemoteAppNotSetError(result)
        }
    }

    private fun spotifyRemoteAppNotSetError(result: MethodChannel.Result) {
        result.error(errorAppRemoteNull, "spotifyAppRemote is null", "")
    }
}