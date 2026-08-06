package de.minimalme.spotify_sdk.handlers

import android.content.Intent
import android.util.Log
import com.spotify.android.appremote.api.ConnectionParams
import com.spotify.android.appremote.api.Connector.ConnectionListener
import com.spotify.android.appremote.api.SpotifyAppRemote
import com.spotify.sdk.android.auth.AuthorizationClient
import com.spotify.sdk.android.auth.AuthorizationRequest
import com.spotify.sdk.android.auth.AuthorizationResponse
import de.minimalme.spotify_sdk.RemoteManager
import de.minimalme.spotify_sdk.SpotifyErrorMapper
import de.minimalme.spotify_sdk.subscriptions.*
import io.flutter.plugin.common.MethodChannel.Result

class AuthHandler(private val remoteManager: RemoteManager) {

    private val loggingTag = "spotify_sdk"
    val requestCodeAuthentication = 1337

    fun connectToSpotify(clientId: String?, redirectUrl: String?, result: Result) {
        if (clientId.isNullOrBlank() || redirectUrl.isNullOrBlank()) {
            result.error("errorConnecting", "client id or redirectUrl are not set or have invalid format", "")
            return
        }
        val connectionParams = ConnectionParams.Builder(clientId)
            .setRedirectUri(redirectUrl)
            .showAuthView(true)
            .build()
        SpotifyAppRemote.disconnect(remoteManager.spotifyAppRemote)
        var initiallyConnected = false
        SpotifyAppRemote.connect(
            remoteManager.applicationContext,
            connectionParams,
            object : ConnectionListener {
                override fun onConnected(appRemote: SpotifyAppRemote) {
                    remoteManager.spotifyAppRemote = appRemote

                    remoteManager.playerContextChannel?.setStreamHandler(PlayerContextChannel(appRemote.playerApi))
                    remoteManager.playerStateChannel?.setStreamHandler(PlayerStateChannel(appRemote.playerApi))
                    remoteManager.capabilitiesChannel?.setStreamHandler(CapabilitiesChannel(appRemote.userApi))
                    remoteManager.userStatusChannel?.setStreamHandler(UserStatusChannel(appRemote.userApi))
                    initiallyConnected = true

                    Log.i(loggingTag, "App Remote successfully connected")
                    remoteManager.connStatusEventChannel(ConnectionStatusChannel.ConnectionEvent(true, "Successfully connected to Spotify.", null, null))
                    result.success(true)
                }

                override fun onFailure(throwable: Throwable) {
                    val info = SpotifyErrorMapper.mapConnectionFailure(throwable)
                    Log.e(loggingTag, info.errorMessage)
                    if (initiallyConnected) {
                        remoteManager.connStatusEventChannel(ConnectionStatusChannel.ConnectionEvent(info.isConnected, info.errorMessage, info.errorCode, info.errorDetails))
                    } else {
                        result.error(info.errorCode, info.errorMessage, info.errorDetails)
                    }
                }
            }
        )
    }

    fun getAccessToken(clientId: String?, redirectUrl: String?, scope: String?, result: Result) {
        val activity = remoteManager.applicationActivity
        if (activity == null) {
            result.error("errorConnecting", "getAccessToken needs a foreground activity", "")
            return
        }
        if (clientId.isNullOrBlank() || redirectUrl.isNullOrBlank()) {
            result.error("errorConnecting", "client id or redirectUrl are not set or have invalid format", "")
            return
        }
        val scopeArray = scope?.split(",")?.toTypedArray()
        with(remoteManager) { "getAccessToken".checkAndSetPendingOperation(result) }

        val builder = AuthorizationRequest.Builder(clientId, AuthorizationResponse.Type.TOKEN, redirectUrl)
        builder.setScopes(scopeArray)
        val request = builder.build()
        AuthorizationClient.openLoginActivity(activity, requestCodeAuthentication, request)
    }

    fun getSwapToken(clientId: String?, redirectUrl: String?, scope: String?, result: Result) {
        val activity = remoteManager.applicationActivity
        if (activity == null) {
            result.error("errorConnecting", "getSwapToken needs a foreground activity", "")
            return
        }
        if (clientId.isNullOrBlank() || redirectUrl.isNullOrBlank()) {
            result.error("errorConnecting", "client id or redirectUrl are not set or have invalid format", "")
            return
        }
        val scopeArray = scope?.split(",")?.toTypedArray()
        with(remoteManager) { "getSwapToken".checkAndSetPendingOperation(result) }

        val builder = AuthorizationRequest.Builder(clientId, AuthorizationResponse.Type.CODE, redirectUrl)
        builder.setScopes(scopeArray)
        val request = builder.build()
        AuthorizationClient.openLoginActivity(activity, requestCodeAuthentication, request)
    }

    fun isSpotifyInstalled(result: Result) {
        val context = remoteManager.applicationContext
        if (context == null) {
            result.success(false)
            return
        }
        result.success(SpotifyAppRemote.isSpotifyInstalled(context))
    }

    fun disconnectFromSpotify(result: Result) {
        val remote = remoteManager.spotifyAppRemote
        if (remote != null && remote.isConnected) {
            SpotifyAppRemote.disconnect(remote)
            remoteManager.connStatusEventChannel(ConnectionStatusChannel.ConnectionEvent(false, "Successfully disconnected from Spotify.", null, null))
            result.success(true)
        } else if (remote != null && !remote.isConnected) {
            result.error("errorDisconnecting", "could not disconnect spotify remote", "you are not connected, no need to disconnect")
        } else {
            result.error("errorDisconnecting", "could not disconnect spotify remote", "spotifyAppRemote is not set")
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == requestCodeAuthentication) {
            val response = AuthorizationClient.getResponse(resultCode, data)
            val pending = remoteManager.pendingOperation
            if (pending != null) {
                when (response.type) {
                    AuthorizationResponse.Type.TOKEN -> pending.result.success(response.accessToken)
                    AuthorizationResponse.Type.CODE -> pending.result.success(response.code)
                    AuthorizationResponse.Type.ERROR -> pending.result.error("authenticationError", response.error, null)
                    else -> pending.result.error("authenticationError", "Authentication cancelled or failed", null)
                }
                remoteManager.pendingOperation = null
            }
            return true
        }
        return false
    }
}
