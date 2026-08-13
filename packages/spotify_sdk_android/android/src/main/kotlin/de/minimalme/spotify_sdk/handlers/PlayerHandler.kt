package de.minimalme.spotify_sdk.handlers

import com.google.gson.Gson
import com.spotify.protocol.types.PlaybackSpeed
import de.minimalme.spotify_sdk.RemoteManager
import de.minimalme.spotify_sdk.SpotifySdkConstants
import io.flutter.plugin.common.MethodChannel.Result

class PlayerHandler(private val remoteManager: RemoteManager) {

    fun switchToLocalDevice(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.connectApi.connectSwitchToLocalDevice()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_CONNECT_SWITCH_TO_LOCAL_DEVICE, "error when switching to local device", throwable.toString()) }
        }
    }

    fun getCrossfadeState(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.crossfadeState
                .setResultCallback { state -> result.success(Gson().toJson(state)) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_CROSSFADE_STATE, "error when getting current crossfade setting", throwable.toString()) }
        }
    }

    fun getPlayerState(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.playerState
                .setResultCallback { state -> result.success(Gson().toJson(state)) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_PLAYER_STATE, "error when getting current player state", throwable.toString()) }
        }
    }

    fun play(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error(SpotifySdkConstants.ERROR_PLAY, "spotifyUri has invalid format or is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.play(spotifyUri)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_PLAY, "error when playing uri: $spotifyUri", throwable.toString()) }
        }
    }

    fun pause(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.pause()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_PAUSE, "error when pausing", throwable.toString()) }
        }
    }

    fun queue(spotifyUri: String?, result: Result) {
        if (spotifyUri.isNullOrBlank()) {
            result.error(SpotifySdkConstants.ERROR_QUEUE, "spotifyUri has invalid format or is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.queue(spotifyUri)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_QUEUE, "error when queueing uri: $spotifyUri", throwable.toString()) }
        }
    }

    fun resume(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.resume()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_RESUME, "error when resuming", throwable.toString()) }
        }
    }

    fun seekTo(positionedMilliseconds: Long?, result: Result) {
        if (positionedMilliseconds == null) {
            result.error(SpotifySdkConstants.ERROR_SEEK_TO, "positionedMilliseconds is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.seekTo(positionedMilliseconds)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_SEEK_TO, "error when seeking to position", throwable.toString()) }
        }
    }

    fun seekToRelativePosition(relativeMilliseconds: Long?, result: Result) {
        if (relativeMilliseconds == null) {
            result.error(SpotifySdkConstants.ERROR_SEEK_TO_RELATIVE_POSITION, "relativeMilliseconds is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.seekToRelativePosition(relativeMilliseconds)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_SEEK_TO_RELATIVE_POSITION, "error when seeking to relative position", throwable.toString()) }
        }
    }

    fun setPodcastPlaybackSpeed(podcastPlaybackSpeed: Double?, result: Result) {
        if (podcastPlaybackSpeed == null) {
            result.error(SpotifySdkConstants.ERROR_SET_PODCAST_PLAYBACK_SPEED, "podcastPlaybackSpeed is not set", "")
            return
        }
        val speedValue = PlaybackSpeed.PodcastPlaybackSpeed.values().firstOrNull { it.value.toDouble() == podcastPlaybackSpeed }
        if (speedValue == null) {
            result.error(SpotifySdkConstants.ERROR_SET_PODCAST_PLAYBACK_SPEED, "podcastPlaybackSpeed value is invalid", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.setPodcastPlaybackSpeed(speedValue)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_SET_PODCAST_PLAYBACK_SPEED, "error when setting podcast playback speed", throwable?.toString() ?: "") }
        }
    }

    fun skipNext(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.skipNext()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_SKIP_NEXT, "error when skipping to next", throwable.toString()) }
        }
    }

    fun skipPrevious(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.skipPrevious()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_SKIP_PREVIOUS, "error when skipping to previous", throwable.toString()) }
        }
    }

    fun skipToIndex(spotifyUri: String?, trackIndex: Int?, result: Result) {
        if (spotifyUri.isNullOrBlank() || trackIndex == null) {
            result.error(SpotifySdkConstants.ERROR_SKIP_TO_INDEX, "spotifyUri or trackIndex are not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.skipToIndex(spotifyUri, trackIndex)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_SKIP_TO_INDEX, "error when skipping to index", throwable.toString()) }
        }
    }

    fun toggleShuffle(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.toggleShuffle()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_TOGGLE_SHUFFLE, "error when toggling shuffle", throwable.toString()) }
        }
    }

    fun setShuffle(shuffle: Boolean?, result: Result) {
        if (shuffle == null) {
            result.error(SpotifySdkConstants.ERROR_SET_SHUFFLE, "shuffle is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.setShuffle(shuffle)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_SET_SHUFFLE, "error when setting shuffle", throwable.toString()) }
        }
    }

    fun toggleRepeat(result: Result) {
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.toggleRepeat()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_TOGGLE_REPEAT, "error when toggling repeat", throwable.toString()) }
        }
    }

    fun setRepeatMode(repeatMode: Int?, result: Result) {
        if (repeatMode == null) {
            result.error(SpotifySdkConstants.ERROR_SET_REPEAT_MODE, "repeatMode is not set", "")
            return
        }
        remoteManager.withAppRemote(result) { remote ->
            remote.playerApi.setRepeat(repeatMode)
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(SpotifySdkConstants.ERROR_SET_REPEAT_MODE, "error when setting repeat mode", throwable?.toString() ?: "") }
        }
    }
}
