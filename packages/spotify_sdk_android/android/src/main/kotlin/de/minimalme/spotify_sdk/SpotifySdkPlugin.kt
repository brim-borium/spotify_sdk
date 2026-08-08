package de.minimalme.spotify_sdk

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import de.minimalme.spotify_sdk.handlers.AuthHandler
import de.minimalme.spotify_sdk.handlers.ImageHandler
import de.minimalme.spotify_sdk.handlers.LibraryHandler
import de.minimalme.spotify_sdk.handlers.PlayerHandler
import de.minimalme.spotify_sdk.subscriptions.ConnectionStatusChannel

class SpotifySdkPlugin : MethodCallHandler, FlutterPlugin, ActivityAware, PluginRegistry.ActivityResultListener {

    private lateinit var methodChannel: MethodChannel
    private val channelName = "spotify_sdk"

    private val playerContextSubscription = "player_context_subscription"
    private val playerStateSubscription = "player_state_subscription"
    private val capabilitiesSubscription = "capabilities_subscription"
    private val userStatusSubscription = "user_status_subscription"
    private val connectionStatusSubscription = "connection_status_subscription"

    val remoteManager = RemoteManager()
    val authHandler = AuthHandler(remoteManager)
    val playerHandler = PlayerHandler(remoteManager)
    val libraryHandler = LibraryHandler(remoteManager)
    val imageHandler = ImageHandler(remoteManager)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        remoteManager.applicationContext = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, channelName)
        methodChannel.setMethodCallHandler(this)

        remoteManager.playerContextChannel = EventChannel(binding.binaryMessenger, playerContextSubscription)
        remoteManager.playerStateChannel = EventChannel(binding.binaryMessenger, playerStateSubscription)
        remoteManager.capabilitiesChannel = EventChannel(binding.binaryMessenger, capabilitiesSubscription)
        remoteManager.userStatusChannel = EventChannel(binding.binaryMessenger, userStatusSubscription)
        remoteManager.connectionStatusChannel = EventChannel(binding.binaryMessenger, connectionStatusSubscription)

        remoteManager.connectionStatusChannel?.setStreamHandler(ConnectionStatusChannel(remoteManager.connStatusEventChannel))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        remoteManager.applicationContext = null
        methodChannel.setMethodCallHandler(null)

        remoteManager.playerContextChannel?.setStreamHandler(null)
        remoteManager.playerStateChannel?.setStreamHandler(null)
        remoteManager.capabilitiesChannel?.setStreamHandler(null)
        remoteManager.userStatusChannel?.setStreamHandler(null)
        remoteManager.connectionStatusChannel?.setStreamHandler(null)

        remoteManager.playerContextChannel = null
        remoteManager.playerStateChannel = null
        remoteManager.capabilitiesChannel = null
        remoteManager.userStatusChannel = null
        remoteManager.connectionStatusChannel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this)
        remoteManager.applicationActivity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        remoteManager.applicationActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        remoteManager.applicationActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        remoteManager.applicationActivity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            // Auth & Session
            "connectToSpotify" -> authHandler.connectToSpotify(call.argument("clientId"), call.argument("redirectUrl"), result)
            "getAccessToken" -> authHandler.getAccessToken(call.argument("clientId"), call.argument("redirectUrl"), call.argument("scope"), result)
            "getSwapToken" -> authHandler.getSwapToken(call.argument("clientId"), call.argument("redirectUrl"), call.argument("scope"), result)
            "isSpotifyInstalled" -> authHandler.isSpotifyInstalled(result)
            "disconnectFromSpotify" -> authHandler.disconnectFromSpotify(result)

            // Playback & Controls
            "switchToLocalDevice" -> playerHandler.switchToLocalDevice(result)
            "getCrossfadeState" -> playerHandler.getCrossfadeState(result)
            "getPlayerState" -> playerHandler.getPlayerState(result)
            "play" -> playerHandler.play(call.argument("spotifyUri"), result)
            "pause" -> playerHandler.pause(result)
            "queueTrack" -> playerHandler.queue(call.argument("spotifyUri"), result)
            "resume" -> playerHandler.resume(result)
            "seekTo" -> playerHandler.seekTo((call.argument<Number>("positionedMilliseconds"))?.toLong(), result)
            "seekToRelativePosition" -> playerHandler.seekToRelativePosition((call.argument<Number>("relativeMilliseconds"))?.toLong(), result)
            "setPodcastPlaybackSpeed" -> playerHandler.setPodcastPlaybackSpeed((call.argument<Number>("podcastPlaybackSpeed"))?.toDouble(), result)
            "skipNext" -> playerHandler.skipNext(result)
            "skipPrevious" -> playerHandler.skipPrevious(result)
            "skipToIndex" -> playerHandler.skipToIndex(call.argument("spotifyUri"), call.argument("trackIndex"), result)
            "toggleShuffle" -> playerHandler.toggleShuffle(result)
            "setShuffle" -> playerHandler.setShuffle(call.argument("shuffle"), result)
            "toggleRepeat" -> playerHandler.toggleRepeat(result)
            "setRepeatMode" -> playerHandler.setRepeatMode(call.argument("repeatMode"), result)

            // User Library & Capabilities
            "addToLibrary" -> libraryHandler.addToUserLibrary(call.argument("spotifyUri"), result)
            "removeFromLibrary" -> libraryHandler.removeFromUserLibrary(call.argument("spotifyUri"), result)
            "getCapabilities" -> libraryHandler.getCapabilities(result)
            "getLibraryState" -> libraryHandler.getLibraryState(call.argument("spotifyUri"), result)

            // Cover Art Images
            "getImage" -> imageHandler.getImage(call.argument("imageUri"), call.argument("imageDimension"), result)

            else -> result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: android.content.Intent?): Boolean {
        return authHandler.onActivityResult(requestCode, resultCode, data)
    }
}
