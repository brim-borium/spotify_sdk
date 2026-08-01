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
import de.minimalme.spotify_sdk.subscriptions.ConnectionStatusChannel

class SpotifySdkPlugin : MethodCallHandler, FlutterPlugin, ActivityAware, PluginRegistry.ActivityResultListener {

    private lateinit var methodChannel: MethodChannel
    private val channelName = "spotify_sdk"

    private val playerContextSubscription = "player_context_subscription"
    private val playerStateSubscription = "player_state_subscription"
    private val capabilitiesSubscription = "capabilities_subscription"
    private val userStatusSubscription = "user_status_subscription"
    private val connectionStatusSubscription = "connection_status_subscription"

    private val remoteController = SpotifyRemoteController()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        remoteController.applicationContext = binding.applicationContext

        methodChannel = MethodChannel(binding.binaryMessenger, channelName)
        methodChannel.setMethodCallHandler(this)

        remoteController.playerContextChannel = EventChannel(binding.binaryMessenger, playerContextSubscription)
        remoteController.playerStateChannel = EventChannel(binding.binaryMessenger, playerStateSubscription)
        remoteController.capabilitiesChannel = EventChannel(binding.binaryMessenger, capabilitiesSubscription)
        remoteController.userStatusChannel = EventChannel(binding.binaryMessenger, userStatusSubscription)
        remoteController.connectionStatusChannel = EventChannel(binding.binaryMessenger, connectionStatusSubscription)

        remoteController.connectionStatusChannel?.setStreamHandler(ConnectionStatusChannel(remoteController.connStatusEventChannel))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        remoteController.applicationContext = null
        methodChannel.setMethodCallHandler(null)

        remoteController.playerContextChannel?.setStreamHandler(null)
        remoteController.playerStateChannel?.setStreamHandler(null)
        remoteController.capabilitiesChannel?.setStreamHandler(null)
        remoteController.userStatusChannel?.setStreamHandler(null)
        remoteController.connectionStatusChannel?.setStreamHandler(null)

        remoteController.playerContextChannel = null
        remoteController.playerStateChannel = null
        remoteController.capabilitiesChannel = null
        remoteController.userStatusChannel = null
        remoteController.connectionStatusChannel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        binding.addActivityResultListener(this)
        remoteController.applicationActivity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        remoteController.applicationActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        remoteController.applicationActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        remoteController.applicationActivity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        remoteController.handleMethodCall(call, result)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: android.content.Intent?): Boolean {
        return remoteController.onActivityResult(requestCode, resultCode, data)
    }
}
