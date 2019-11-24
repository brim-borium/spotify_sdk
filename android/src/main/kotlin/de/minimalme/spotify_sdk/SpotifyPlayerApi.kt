package de.minimalme.spotify_sdk

import com.spotify.android.appremote.api.SpotifyAppRemote
import io.flutter.plugin.common.MethodChannel

class SpotifyPlayerApi(private val spotifyAppRemote: SpotifyAppRemote?) {

    private val errorAppRemoteNull = "spotifyAppRemoteNull"
    private val errorQueError = "queueError"
    private val errorPlayError = "playError"
    private val errorPauseError = "pauseError"
    private val errorToggleShuffleError = "toggleShuffleError"
    private val errorToggleRepeatError = "toggleRepeatError"

    internal fun queue(spotifyUri: String?, result: MethodChannel.Result) {
        if (spotifyAppRemote != null && !spotifyUri.isNullOrBlank()) {
            spotifyAppRemote.playerApi.queue(spotifyUri)
                    .setResultCallback {
                        result.success(true)
                        result.error(errorQueError, "error when adding uri to queue", "")
                    }
        } else if(spotifyUri.isNullOrBlank()) {
            result.error(errorQueError, "spotifyUri has invalid format", "" )
        }else {
            spotifyRemoteAppNotSetError(result)
        }
    }

    internal fun play(spotifyUri: String?, result: MethodChannel.Result) {
        if (spotifyAppRemote != null && !spotifyUri.isNullOrBlank()) {
            spotifyAppRemote.playerApi.play(spotifyUri)
                    .setResultCallback {
                        result.success(true)
                        result.error(errorPlayError, "error when playing uri", "")
                    }
        } else if (spotifyUri.isNullOrBlank()) {
            result.error(errorPlayError,"spotifyUri has invalid format", "")
        } else {
            spotifyRemoteAppNotSetError(result)
        }
    }

    internal fun pause(result: MethodChannel.Result) {
        if (spotifyAppRemote != null) {
            spotifyAppRemote.playerApi.pause()
                    .setResultCallback {
                        result.success(true)
                        result.error(errorPauseError,"error when pausing", "")
                    }
        } else {
            spotifyRemoteAppNotSetError(result)
        }
    }

    internal fun toggleShuffle(result: MethodChannel.Result) {
        if (spotifyAppRemote != null) {
            spotifyAppRemote.playerApi.toggleShuffle()
                    .setResultCallback {
                        result.success(true)
                        result.error(errorToggleShuffleError, "error when toggle shuffle", "")
                    }
        } else {
            spotifyRemoteAppNotSetError(result)
        }
    }

    internal fun toggleRepeat(result: MethodChannel.Result) {
        if (spotifyAppRemote != null) {
            spotifyAppRemote.playerApi.toggleRepeat()
                    .setResultCallback {
                        result.success(true)
                        result.error(errorToggleRepeatError, "error when toggle repeat", "")
                    }
        } else {
            spotifyRemoteAppNotSetError(result)
        }
    }

    private fun spotifyRemoteAppNotSetError(result: MethodChannel.Result) {
        result.error(errorAppRemoteNull, "spotifyAppRemote is null", "")
    }
}