import Flutter
import SpotifyiOS

public class SpotifySdkPlugin: NSObject, FlutterPlugin {
    private static var instance = SpotifySdkPlugin()

    private let remoteManager = RemoteManager.shared
    private lazy var authHandler = AuthHandler(remoteManager: remoteManager)
    private lazy var playerHandler = PlayerHandler(remoteManager: remoteManager)
    private lazy var libraryHandler = LibraryHandler(remoteManager: remoteManager)
    private lazy var imageHandler = ImageHandler(remoteManager: remoteManager)

    public static func register(with registrar: FlutterPluginRegistrar) {
        guard instance.remoteManager.playerStateChannel == nil else {
            return
        }
        let spotifySDKChannel = FlutterMethodChannel(name: "spotify_sdk", binaryMessenger: registrar.messenger())
        let connectionStatusChannel = FlutterEventChannel(name: "connection_status_subscription", binaryMessenger: registrar.messenger())
        instance.remoteManager.playerStateChannel = FlutterEventChannel(name: "player_state_subscription", binaryMessenger: registrar.messenger())
        instance.remoteManager.playerContextChannel = FlutterEventChannel(name: "player_context_subscription", binaryMessenger: registrar.messenger())
        registrar.addApplicationDelegate(instance)

        if #available(iOS 13.0, *) {
            let selector = NSSelectorFromString("addSceneDelegate:")
            if (registrar as AnyObject).responds(to: selector) {
                (registrar as AnyObject).perform(selector, with: instance)
            }
        }
        registrar.addMethodCallDelegate(instance, channel: spotifySDKChannel)
        instance.remoteManager.connectionStatusHandler = ConnectionStatusHandler()
        connectionStatusChannel.setStreamHandler(instance.remoteManager.connectionStatusHandler)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        // Auth & Session
        case SpotifySdkConstants.methodConnectToSpotify:
            authHandler.connectToSpotify(call: call, result: result)
        case SpotifySdkConstants.methodGetAccessToken, SpotifySdkConstants.methodGetSwapToken:
            authHandler.getAccessTokenOrSwapToken(call: call, result: result)
        case SpotifySdkConstants.methodIsSpotifyInstalled:
            authHandler.isSpotifyInstalled(result: result)
        case SpotifySdkConstants.methodDisconnectFromSpotify:
            authHandler.disconnect(result: result)

        // Playback & Controls
        case SpotifySdkConstants.methodGetPlayerState:
            playerHandler.getPlayerState(result: result)
        case SpotifySdkConstants.methodPlay:
            playerHandler.play(call: call, result: result)
        case SpotifySdkConstants.methodPause:
            playerHandler.pause(result: result)
        case SpotifySdkConstants.methodResume:
            playerHandler.resume(result: result)
        case SpotifySdkConstants.methodQueueTrack:
            playerHandler.queueTrack(call: call, result: result)
        case SpotifySdkConstants.methodSkipNext:
            playerHandler.skipNext(result: result)
        case SpotifySdkConstants.methodSkipPrevious:
            playerHandler.skipPrevious(result: result)
        case SpotifySdkConstants.methodSkipToIndex:
            playerHandler.skipToIndex(call: call, result: result)
        case SpotifySdkConstants.methodSeekTo:
            playerHandler.seekTo(call: call, result: result)
        case SpotifySdkConstants.methodSeekToRelativePosition:
            playerHandler.seekToRelativePosition(call: call, result: result)
        case SpotifySdkConstants.methodGetCrossfadeState:
            playerHandler.getCrossfadeState(result: result)
        case SpotifySdkConstants.methodSetShuffle:
            playerHandler.setShuffle(call: call, result: result)
        case SpotifySdkConstants.methodToggleShuffle:
            playerHandler.toggleShuffle(result: result)
        case SpotifySdkConstants.methodSetRepeatMode:
            playerHandler.setRepeatMode(call: call, result: result)
        case SpotifySdkConstants.methodToggleRepeat:
            playerHandler.toggleRepeat(result: result)
        case SpotifySdkConstants.methodSwitchToLocalDevice:
            playerHandler.switchToLocalDevice(result: result)

        // User Library & Capabilities
        case SpotifySdkConstants.methodAddToLibrary:
            libraryHandler.addToLibrary(call: call, result: result)
        case SpotifySdkConstants.methodRemoveFromLibrary:
            libraryHandler.removeFromLibrary(call: call, result: result)
        case SpotifySdkConstants.methodGetCapabilities:
            libraryHandler.getCapabilities(result: result)
        case SpotifySdkConstants.getLibraryState:
            libraryHandler.getLibraryState(call: call, result: result)

        // Cover Art Images
        case SpotifySdkConstants.methodGetImage:
            imageHandler.getImage(call: call, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        remoteManager.connectionStatusHandler?.appRemote(remoteManager.appRemote, open: url)
        return true
    }

    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        remoteManager.connectionStatusHandler?.appRemote(remoteManager.appRemote, open: url)
        return true
    }
}
