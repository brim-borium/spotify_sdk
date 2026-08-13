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
    val remoteManager = RemoteManager()
    val authHandler = AuthHandler(remoteManager)
    val playerHandler = PlayerHandler(remoteManager)
    val libraryHandler = LibraryHandler(remoteManager)
    val imageHandler = ImageHandler(remoteManager)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        remoteManager.applicationContext = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, SpotifySdkConstants.CHANNEL_SPOTIFY_SDK)
        methodChannel.setMethodCallHandler(this)

        remoteManager.playerContextChannel = EventChannel(binding.binaryMessenger, SpotifySdkConstants.CHANNEL_PLAYER_CONTEXT)
        remoteManager.playerStateChannel = EventChannel(binding.binaryMessenger, SpotifySdkConstants.CHANNEL_PLAYER_STATE)
        remoteManager.capabilitiesChannel = EventChannel(binding.binaryMessenger, SpotifySdkConstants.CHANNEL_CAPABILITIES)
        remoteManager.userStatusChannel = EventChannel(binding.binaryMessenger, SpotifySdkConstants.CHANNEL_USER_STATUS)
        remoteManager.connectionStatusChannel = EventChannel(binding.binaryMessenger, SpotifySdkConstants.CHANNEL_CONNECTION_STATUS)

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
            SpotifySdkConstants.METHOD_CONNECT_TO_SPOTIFY -> authHandler.connectToSpotify(
                call.argument(SpotifySdkConstants.PARAM_CLIENT_ID),
                call.argument(SpotifySdkConstants.PARAM_REDIRECT_URL),
                result
            )
            SpotifySdkConstants.METHOD_GET_ACCESS_TOKEN -> authHandler.getAccessToken(
                call.argument(SpotifySdkConstants.PARAM_CLIENT_ID),
                call.argument(SpotifySdkConstants.PARAM_REDIRECT_URL),
                call.argument(SpotifySdkConstants.PARAM_SCOPE),
                result
            )
            SpotifySdkConstants.METHOD_GET_SWAP_TOKEN -> authHandler.getSwapToken(
                call.argument(SpotifySdkConstants.PARAM_CLIENT_ID),
                call.argument(SpotifySdkConstants.PARAM_REDIRECT_URL),
                call.argument(SpotifySdkConstants.PARAM_SCOPE),
                result
            )
            SpotifySdkConstants.METHOD_IS_SPOTIFY_INSTALLED -> authHandler.isSpotifyInstalled(result)
            SpotifySdkConstants.METHOD_DISCONNECT_FROM_SPOTIFY -> authHandler.disconnectFromSpotify(result)

            // Playback & Controls
            SpotifySdkConstants.METHOD_SWITCH_TO_LOCAL_DEVICE -> playerHandler.switchToLocalDevice(result)
            SpotifySdkConstants.METHOD_GET_CROSSFADE_STATE -> playerHandler.getCrossfadeState(result)
            SpotifySdkConstants.METHOD_GET_PLAYER_STATE -> playerHandler.getPlayerState(result)
            SpotifySdkConstants.METHOD_PLAY -> playerHandler.play(call.argument(SpotifySdkConstants.PARAM_SPOTIFY_URI), result)
            SpotifySdkConstants.METHOD_PAUSE -> playerHandler.pause(result)
            SpotifySdkConstants.METHOD_QUEUE_TRACK -> playerHandler.queue(call.argument(SpotifySdkConstants.PARAM_SPOTIFY_URI), result)
            SpotifySdkConstants.METHOD_RESUME -> playerHandler.resume(result)
            SpotifySdkConstants.METHOD_SEEK_TO -> playerHandler.seekTo((call.argument<Number>(SpotifySdkConstants.PARAM_POSITIONED_MILLISECONDS))?.toLong(), result)
            SpotifySdkConstants.METHOD_SEEK_TO_RELATIVE_POSITION -> playerHandler.seekToRelativePosition((call.argument<Number>(SpotifySdkConstants.PARAM_RELATIVE_MILLISECONDS))?.toLong(), result)
            SpotifySdkConstants.METHOD_SET_PODCAST_PLAYBACK_SPEED -> playerHandler.setPodcastPlaybackSpeed((call.argument<Number>(SpotifySdkConstants.PARAM_PODCAST_PLAYBACK_SPEED))?.toDouble(), result)
            SpotifySdkConstants.METHOD_SKIP_NEXT -> playerHandler.skipNext(result)
            SpotifySdkConstants.METHOD_SKIP_PREVIOUS -> playerHandler.skipPrevious(result)
            SpotifySdkConstants.METHOD_SKIP_TO_INDEX -> playerHandler.skipToIndex(call.argument(SpotifySdkConstants.PARAM_SPOTIFY_URI), call.argument(SpotifySdkConstants.PARAM_TRACK_INDEX), result)
            SpotifySdkConstants.METHOD_TOGGLE_SHUFFLE -> playerHandler.toggleShuffle(result)
            SpotifySdkConstants.METHOD_SET_SHUFFLE -> playerHandler.setShuffle(call.argument(SpotifySdkConstants.PARAM_SHUFFLE), result)
            SpotifySdkConstants.METHOD_TOGGLE_REPEAT -> playerHandler.toggleRepeat(result)
            SpotifySdkConstants.METHOD_SET_REPEAT_MODE -> playerHandler.setRepeatMode(call.argument(SpotifySdkConstants.PARAM_REPEAT_MODE), result)

            // User Library & Capabilities
            SpotifySdkConstants.METHOD_ADD_TO_LIBRARY -> libraryHandler.addToUserLibrary(call.argument(SpotifySdkConstants.PARAM_SPOTIFY_URI), result)
            SpotifySdkConstants.METHOD_REMOVE_FROM_LIBRARY -> libraryHandler.removeFromUserLibrary(call.argument(SpotifySdkConstants.PARAM_SPOTIFY_URI), result)
            SpotifySdkConstants.METHOD_GET_CAPABILITIES -> libraryHandler.getCapabilities(result)
            SpotifySdkConstants.METHOD_GET_LIBRARY_STATE -> libraryHandler.getLibraryState(call.argument(SpotifySdkConstants.PARAM_SPOTIFY_URI), result)

            // Cover Art Images
            SpotifySdkConstants.METHOD_GET_IMAGE -> imageHandler.getImage(call.argument(SpotifySdkConstants.PARAM_IMAGE_URI), call.argument(SpotifySdkConstants.PARAM_IMAGE_DIMENSION), result)

            else -> result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: android.content.Intent?): Boolean {
        return authHandler.onActivityResult(requestCode, resultCode, data)
    }
}
