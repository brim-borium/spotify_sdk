package de.minimalme.spotify_sdk

import com.spotify.android.appremote.api.SpotifyAppRemote
import io.flutter.plugin.common.MethodChannel

open class BaseSpotifyApi(internal val spotifyAppRemote: SpotifyAppRemote?, internal val result: MethodChannel.Result) {

    private val errorAppRemoteNull = "spotifyAppRemoteNull"

    internal fun spotifyRemoteAppNotSetError() {
        result.error(errorAppRemoteNull, "spotifyAppRemote is null", "")
    }
}