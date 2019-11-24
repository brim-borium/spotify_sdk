package de.minimalme.spotify_sdk

import com.spotify.android.appremote.api.SpotifyAppRemote
import io.flutter.plugin.common.MethodChannel

class SpotifyPlayerApi(spotifyAppRemote: SpotifyAppRemote?, result: MethodChannel.Result) : BaseSpotifyApi(spotifyAppRemote, result) {

    private val errorQue = "queueError"
    private val errorPlay = "playError"
    private val errorPause = "pauseError"
    private val errorResume = "resumeError"
    private val errorToggleShuffle = "toggleShuffleError"
    private val errorToggleRepeat = "toggleRepeatError"
    private val errorSkipNext = "skipNextError"
    private val errorSkipPrevious = "skipPreviousError"
    private val errorSeekTo = "seekToError"

    private val playerApi = spotifyAppRemote?.playerApi

    internal fun queue(spotifyUri: String?) {
        if (playerApi != null && !spotifyUri.isNullOrBlank()) {
            playerApi.queue(spotifyUri)
                    .setResultCallback {
                        result.success(true)
                        result.error(errorQue, "error when adding uri: $spotifyUri to queue", "")
                    }
        } else if (spotifyUri.isNullOrBlank()) {
            result.error(errorQue, "spotifyUri has invalid format", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun play(spotifyUri: String?) {
        if (playerApi != null && !spotifyUri.isNullOrBlank()) {
            playerApi.play(spotifyUri)
                    .setResultCallback {
                        result.success(true)
                        result.error(errorPlay, "error when playing uri: $spotifyUri", "")
                    }
        } else if (spotifyUri.isNullOrBlank()) {
            result.error(errorPlay, "spotifyUri has invalid format", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun pause() {
        if (playerApi != null) {
            playerApi.pause()
                    .setResultCallback {
                        result.success(true)
                        result.error(errorPause, "error when pausing", "")
                    }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun resume() {
        if (playerApi != null) {
            playerApi.resume()
                    .setResultCallback {
                        result.success(true)
                        result.error(errorResume, "error when resuming", "")
                    }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun seekTo(positionMs: Long?) {
        if (playerApi != null && positionMs != null) {
            playerApi.seekTo(positionMs)
                    .setResultCallback {
                        result.success(true)
                        result.error(errorResume, "error when seeking to: $positionMs", "")
                    }
        } else if(positionMs == null){
            result.error(errorSeekTo, "positionMS is not set", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun seekToRelativePosition(milliseconds: Long?) {
        if (playerApi != null && milliseconds != null) {
            playerApi.seekToRelativePosition(milliseconds)
                    .setResultCallback {
                        result.success(true)
                        result.error(errorResume, "error when seeking relative to: $milliseconds", "")
                    }
        } else if(milliseconds == null){
            result.error(errorSeekTo, "milliseconds is not set", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun toggleShuffle() {
        if (playerApi != null) {
            playerApi.toggleShuffle()
                    .setResultCallback {
                        result.success(true)
                        result.error(errorToggleShuffle, "error when toggle shuffle", "")
                    }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun toggleRepeat() {
        if (playerApi != null) {
            playerApi.toggleRepeat()
                    .setResultCallback {
                        result.success(true)
                        result.error(errorToggleRepeat, "error when toggle repeat", "")
                    }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun skipNext() {
        if (playerApi != null) {
            playerApi.skipNext()
                    .setResultCallback {
                        result.success(true)
                        result.error(errorSkipNext, "error when skipping next", "")
                    }
        }  else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun skipPrevious() {
        if (playerApi != null) {
            playerApi.skipPrevious()
                    .setResultCallback {
                        result.success(true)
                        result.error(errorSkipPrevious, "error when skipping previous", "")
                    }
        }  else {
            spotifyRemoteAppNotSetError()
        }
    }
}