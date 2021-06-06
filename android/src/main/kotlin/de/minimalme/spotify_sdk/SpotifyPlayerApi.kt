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
    private val errorIsSpotifyAppActive = "isSpotifyAppActiveError"

    private val playerApi = spotifyAppRemote?.playerApi

    internal fun getCrossfadeState() {
        if (playerApi != null) {
            playerApi.crossfadeState
                    .setResultCallback { crossfadeState ->
                        result.success(Gson().toJson(crossfadeState))
                    }
                    .setErrorCallback { throwable -> result.error(errorCrossfadeState, "error when getting the current state of crossfade setting", throwable.toString()) }
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
                    .setErrorCallback { throwable -> result.error(errorPlayerState, "error when getting the current state of the player", throwable.toString()) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun queue(spotifyUri: String?) {
        if (playerApi != null && !spotifyUri.isNullOrBlank()) {
            playerApi.queue(spotifyUri)
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorQue, "error when adding uri: $spotifyUri to queue", throwable.toString()) }
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
                    .setErrorCallback { throwable -> result.error(errorPlay, "error when playing uri: $spotifyUri", throwable.toString()) }
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
                    .setErrorCallback { throwable -> result.error(errorPause, "error when pausing", throwable.toString()) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun resume() {
        if (playerApi != null) {
            playerApi.resume()
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorResume, "error when resuming", throwable.toString()) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun seekTo(milliseconds: Int?) {
        var castedMilliseconds = milliseconds?.toLong()
        if (playerApi != null && castedMilliseconds != null) {
            playerApi.seekTo(castedMilliseconds)
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorResume, "error when seeking to: $castedMilliseconds", throwable.toString()) }
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
                    .setErrorCallback { throwable -> result.error(errorResume, "error when seeking relative to: $castedMilliseconds", throwable.toString()) }
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
                    .setErrorCallback { throwable -> result.error(errorPodcastPlaybackSpeed, "error when setting the podcastPlaybackSpeed to: $podcastPlaybackSpeed", throwable.toString()) }
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
                    .setErrorCallback { throwable -> result.error(errorSkipNext, "error when skipping next", throwable.toString()) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun skipPrevious() {
        if (playerApi != null) {
            playerApi.skipPrevious()
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorSkipPrevious, "error when skipping previous", throwable.toString()) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun skipToIndex(uri: String?, index: Int?) {
        if (playerApi != null && !uri.isNullOrBlank() && index != null) {
            playerApi.skipToIndex(uri, index)
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorSkipToIndex, "error when skipping to index", throwable.toString()) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun toggleShuffle() {
        if (playerApi != null) {
            playerApi.toggleShuffle()
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorToggleShuffle, "error when toggle shuffle", throwable.toString()) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun setShuffle(shuffle: Boolean?) {
        if (playerApi != null && shuffle != null) {
            playerApi.setShuffle(shuffle)
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorToggleRepeat, "error when toggle shuffle", throwable.toString()) }
        } else if (shuffle == null) {
            result.error(errorQue, "shuffle has invalid format or is not set", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun toggleRepeat() {
        if (playerApi != null) {
            playerApi.toggleRepeat()
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorToggleRepeat, "error when toggle repeat", throwable.toString()) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun setRepeatMode(repeatMode: Int?) {
        if (playerApi != null && repeatMode != null) {
            playerApi.setRepeat(repeatMode)
                    .setResultCallback { result.success(true) }
                    .setErrorCallback { throwable -> result.error(errorToggleRepeat, "error when toggle repeat", throwable.toString()) }
        } else if (repeatMode == null) {
            result.error(errorQue, "repeatMode has invalid format or is not set", "")
        } else {
            spotifyRemoteAppNotSetError()
        }
    }

    internal fun isSpotifyAppActive() {
        if (playerApi != null) {

            playerApi.playerState
                .setResultCallback { playerState ->  result.success(!playerState.isPaused && playerState.playbackSpeed > 0)}
                .setErrorCallback {
                        throwable -> result.error(errorIsSpotifyAppActive, "error when getting if spotify app is currently active/playing", throwable.toString())
                }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }
}