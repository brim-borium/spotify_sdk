package de.minimalme.spotify_sdk.handlers

import com.google.gson.Gson
import com.spotify.protocol.types.PlaybackSpeed
import de.minimalme.spotify_sdk.RemoteManager
import io.flutter.plugin.common.MethodChannel.Result

class PlayerHandler(private val remoteManager: RemoteManager) {

    fun switchToLocalDevice(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.connectApi.connectSwitchToLocalDevice()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("errorConnectSwitchToLocalDevice", "error when switching to local device", throwable.toString()) }
        }
    }

    fun getCrossfadeState(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.crossfadeState
                .setResultCallback { state -> result.success(Gson().toJson(state)) }
                .setErrorCallback { throwable -> result.error("crossfadeStateError", "error when getting current crossfade setting", throwable.toString()) }
        }
    }

    fun getPlayerState(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.playerState
                .setResultCallback { state -> result.success(Gson().toJson(state)) }
                .setErrorCallback { throwable -> result.error("PlayerStateError", "error when getting current player state", throwable.toString()) }
        }
    }

    fun play(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error("playError", "spotifyUri has invalid format or is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.play(spotifyUri)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("playError", "error when playing uri: $spotifyUri", throwable.toString()) }
        }
    }

    fun pause(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.pause()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("pauseError", "error when pausing", throwable.toString()) }
        }
    }

    fun queue(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error("queueError", "spotifyUri has invalid format or is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.queue(spotifyUri)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("queueError", "error when queueing uri: $spotifyUri", throwable.toString()) }
        }
    }

    fun resume(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.resume()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("resumeError", "error when resuming", throwable.toString()) }
        }
    }

    fun seekTo(positionedMilliseconds: Long?, result: Result) {
        if (positionedMilliseconds == null) {
            result.error("seekToError", "positionedMilliseconds is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.seekTo(positionedMilliseconds)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("seekToError", "error when seeking to position", throwable.toString()) }
        }
    }

    fun seekToRelativePosition(relativeMilliseconds: Long?, result: Result) {
        if (relativeMilliseconds == null) {
            result.error("seekToRelativePositionError", "relativeMilliseconds is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.seekToRelativePosition(relativeMilliseconds)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("seekToRelativePositionError", "error when seeking to relative position", throwable.toString()) }
        }
    }

    fun setPodcastPlaybackSpeed(podcastPlaybackSpeed: Double?, result: Result) {
        if (podcastPlaybackSpeed == null) {
            result.error("setPodcastPlaybackSpeedError", "podcastPlaybackSpeed is not set", "")
            return
        }
        val speedValue = PlaybackSpeed.PodcastPlaybackSpeed.values().firstOrNull { it.value.toDouble() == podcastPlaybackSpeed }
        if (speedValue == null) {
            result.error("setPodcastPlaybackSpeedError", "podcastPlaybackSpeed value is invalid", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.setPodcastPlaybackSpeed(speedValue)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("setPodcastPlaybackSpeedError", "error when setting podcast playback speed", throwable?.toString() ?: "") }
        }
    }

    fun skipNext(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.skipNext()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("skipNextError", "error when skipping to next", throwable.toString()) }
        }
    }

    fun skipPrevious(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.skipPrevious()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("skipPreviousError", "error when skipping to previous", throwable.toString()) }
        }
    }

    fun skipToIndex(spotifyUri: String?, trackIndex: Int?, result: Result) {
        if (spotifyUri.isNullOrBlank() || trackIndex == null) {
            result.error("skipToIndexError", "spotifyUri or trackIndex are not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.skipToIndex(spotifyUri, trackIndex)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("skipToIndexError", "error when skipping to index", throwable.toString()) }
        }
    }

    fun toggleShuffle(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.toggleShuffle()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("toggleShuffleError", "error when toggling shuffle", throwable.toString()) }
        }
    }

    fun setShuffle(shuffle: Boolean?, result: Result) {
        if (shuffle == null) {
            result.error("setShuffleError", "shuffle is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.setShuffle(shuffle)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("setShuffleError", "error when setting shuffle", throwable.toString()) }
        }
    }

    fun toggleRepeat(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.toggleRepeat()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("toggleRepeatError", "error when toggling repeat", throwable.toString()) }
        }
    }

    fun setRepeatMode(repeatMode: Int?, result: Result) {
        if (repeatMode == null) {
            result.error("setRepeatModeError", "repeatMode is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.setRepeat(repeatMode)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error("setRepeatModeError", "error when setting repeat mode", throwable?.toString() ?: "") }
        }
    }
}
