package de.minimalme.spotify_sdk

import com.spotify.android.appremote.api.SpotifyAppRemote
import com.spotify.protocol.types.Image.Dimension
import com.spotify.protocol.types.ImageUri
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import android.graphics.Bitmap

class SpotifyConnectApi(spotifyAppRemote: SpotifyAppRemote?, result: MethodChannel.Result) : BaseSpotifyApi(spotifyAppRemote, result) {

    private val errorConnectSwitchToLocalDevice = "errorConnectSwitchToLocalDevice"

    private val connectApi = spotifyAppRemote?.connectApi

    fun switchToLocalDevice() {
        if (connectApi != null) {
            connectApi.connectSwitchToLocalDevice()
                .setResultCallback { result.success(true) }
                .setErrorCallback { throwable -> result.error(errorConnectSwitchToLocalDevice, "error when switching to local device", throwable.toString()) }
        } else {
            spotifyRemoteAppNotSetError()
        }
    }
}