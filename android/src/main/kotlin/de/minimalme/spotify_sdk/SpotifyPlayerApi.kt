package de.minimalme.spotify_sdk

import com.google.gson.Gson
import com.spotify.android.appremote.api.SpotifyAppRemote
import com.spotify.protocol.types.PlaybackSpeed
import io.flutter.plugin.common.MethodChannel

class SpotifyPlayerApi(spotifyAppRemote: SpotifyAppRemote?, result: MethodChannel.Result) : BaseSpotifyApi(spotifyAppRemote, result) {


    private val errorCrossfadeState = "crossfadeStateError"
    private val errorPlayerState = "PlayerStateError"
    private val errorQue = "queueError"
    private val errorPlay = "playError"
    private val errorPause = "pauseError"
    private val errorResume = "resumeError"
    private val errorSkipNext = "skipNextError"
    private val errorSkipPrevious = "skipPreviousError"
    private val errorSeekTo = "seekToError"
    private val errorSkipToIndex = "skipToIndexError"
    private val errorPodcastPlaybackSpeed = "podcastPlaybackSpeedError"
    private val errorToggleShuffle = "toggleShuffleError"
    private val errorToggleRepeat = "toggleRepeatError"

    private val playerApi = spotifyAppRemote?.playerApi

    internal fun getCrossfadeState() {
        if (playerApi != null) {
            playerApi.crossfadeState
                    .setResultCallback { crossfadeState ->
                        result.success(Gson().toJson(crossfadeState))
                    }
                    .setErrorCallback { throwable -> result.error(errorCrossfadeState, "error when getting the current state of crossfade setting", throwable.message) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun getPlayerState() {
        if (playerApi != null) {
            playerApi.playerState
                    .setResultCallback { playerState ->
                        result.success(Gson().toJson(playerState))

                    }
                    .setErrorCallback { throwable -> result.error(errorPlayerState, "error when getting the current state of the player", throwable.message) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun queue(spotifyUri: String?) {
        if (playerApi != null && !spotifyUri.isNullOrBlank()) {
            playerApi.queue(spotifyUri)
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorQue, "error when adding uri: $spotifyUri to queue", throwable.message) }
        } else if (spotifyUri.isNullOrBlank()) {
            result.error(errorQue, "spotifyUri has invalid format or is not set", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun play(spotifyUri: String?) {
        if (playerApi != null && !spotifyUri.isNullOrBlank()) {
            playerApi.play(spotifyUri)
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorPlay, "error when playing uri: $spotifyUri", throwable.message) }
        } else if (spotifyUri.isNullOrBlank()) {
            result.error(errorPlay, "spotifyUri has invalid format or is not set", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun pause() {
        if (playerApi != null) {
            playerApi.pause()
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorPause, "error when pausing", throwable.message) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun resume() {
        if (playerApi != null) {
            playerApi.resume()
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorResume, "error when resuming", throwable.message) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun seekTo(milliseconds: Int?) {
        var castedMilliseconds = milliseconds?.toLong()
        if (playerApi != null && castedMilliseconds != null) {
            playerApi.seekTo(castedMilliseconds)
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorResume, "error when seeking to: $castedMilliseconds", throwable.message) }
        } else if (castedMilliseconds == null) {
            result.error(errorSeekTo, "positionMS is not set", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun seekToRelativePosition(milliseconds: Int?) {
        val castedMilliseconds = milliseconds?.toLong()
        if (playerApi != null && castedMilliseconds != null) {
            playerApi.seekToRelativePosition(castedMilliseconds)
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorResume, "error when seeking relative to: $castedMilliseconds", throwable.message) }
        } else if (castedMilliseconds == null) {
            result.error(errorSeekTo, "milliseconds is not set", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun setPodcastPlaybackSpeed(podcastPlaybackSpeedValue: Int?) {
        if (playerApi != null && podcastPlaybackSpeedValue != null) {

            val podcastPlaybackSpeed = PlaybackSpeed.PodcastPlaybackSpeed.values()[podcastPlaybackSpeedValue]

            playerApi.setPodcastPlaybackSpeed(podcastPlaybackSpeed)
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorPodcastPlaybackSpeed, "error when setting the podcastPlaybackSpeed to: $podcastPlaybackSpeed", throwable.message) }
        } else if (podcastPlaybackSpeedValue == null) {
            result.error(errorPodcastPlaybackSpeed, "podcastPlaybackSpeedValue is not set", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun skipNext() {
        if (playerApi != null) {
            playerApi.skipNext()
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorSkipNext, "error when skipping next", throwable.message) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun skipPrevious() {
        if (playerApi != null) {
            playerApi.skipPrevious()
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorSkipPrevious, "error when skipping previous", throwable.message) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun skipToIndex(uri: String?, index: Int?) {
        if (playerApi != null && !uri.isNullOrBlank() && index != null) {
            playerApi.skipToIndex(uri, index)
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorSkipToIndex, "error when skipping to index", throwable.message) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun toggleShuffle() {
        if (playerApi != null) {
            playerApi.toggleShuffle()
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorToggleShuffle, "error when toggle shuffle", throwable.message) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun toggleRepeat() {
        if (playerApi != null) {
            playerApi.toggleRepeat()
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorToggleRepeat, "error when toggle repeat", throwable.message) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }
}