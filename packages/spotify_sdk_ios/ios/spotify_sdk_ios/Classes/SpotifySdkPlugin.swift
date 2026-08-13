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
        guard RemoteManager.playerStateChannel == nil else {
            return
        }
        let spotifySDKChannel = FlutterMethodChannel(name: SpotifySdkConstants.channelSpotifySdk, binaryMessenger: registrar.messenger())
        let connectionStatusChannel = FlutterEventChannel(name: SpotifySdkConstants.channelConnectionStatus, binaryMessenger: registrar.messenger())
        RemoteManager.connectionStatusChannel = connectionStatusChannel
        RemoteManager.playerStateChannel = FlutterEventChannel(name: SpotifySdkConstants.channelPlayerState, binaryMessenger: registrar.messenger())
        RemoteManager.playerContextChannel = FlutterEventChannel(name: SpotifySdkConstants.channelPlayerContext, binaryMessenger: registrar.messenger())
        RemoteManager.capabilitiesChannel = FlutterEventChannel(name: SpotifySdkConstants.channelCapabilities, binaryMessenger: registrar.messenger())
        RemoteManager.userStatusChannel = FlutterEventChannel(name: SpotifySdkConstants.channelUserStatus, binaryMessenger: registrar.messenger())

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

        instance.remoteManager.capabilitiesHandler = CapabilitiesHandler()
        RemoteManager.capabilitiesChannel?.setStreamHandler(instance.remoteManager.capabilitiesHandler)

        instance.remoteManager.userStatusHandler = UserStatusHandler()
        RemoteManager.userStatusChannel?.setStreamHandler(instance.remoteManager.userStatusHandler)
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
        case SpotifySdkConstants.methodGetLibraryState, SpotifySdkConstants.getLibraryState:
            libraryHandler.getLibraryState(call: call, result: result)

        // Cover Art Images
        case SpotifySdkConstants.methodGetImage:
            imageHandler.getImage(call: call, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        setAccessTokenFromURL(url: url)
        return true
    }

    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        setAccessTokenFromURL(url: url)
        return false
    }

    private func setAccessTokenFromURL(url: URL) {
        guard let appRemote = remoteManager.appRemote else {
            remoteManager.connectionStatusHandler?.connectionResult?(FlutterError(code: "errorConnection", message: "AppRemote is null", details: nil))
            remoteManager.connectionStatusHandler?.tokenResult?(FlutterError(code: "errorConnection", message: "AppRemote is null", details: nil))
            remoteManager.connectionStatusHandler?.connectionResult = nil
            remoteManager.connectionStatusHandler?.tokenResult = nil
            return
        }

        guard let token = appRemote.authorizationParameters(from: url)?[SPTAppRemoteAccessTokenKey] else {
            remoteManager.connectionStatusHandler?.connectionResult?(FlutterError(code: "authenticationTokenError", message: appRemote.authorizationParameters(from: url)?[SPTAppRemoteErrorDescriptionKey], details: nil))
            remoteManager.connectionStatusHandler?.tokenResult?(FlutterError(code: "authenticationTokenError", message: appRemote.authorizationParameters(from: url)?[SPTAppRemoteErrorDescriptionKey], details: nil))
            remoteManager.connectionStatusHandler?.connectionResult = nil
            remoteManager.connectionStatusHandler?.tokenResult = nil
            return
        }

        appRemote.connectionParameters.accessToken = token
        appRemote.connect()
    }
}

@available(iOS 13.0, *)
extension SpotifySdkPlugin: UIWindowSceneDelegate {
    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        setAccessTokenFromURL(url: url)
    }

    public func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return
        }
        setAccessTokenFromURL(url: url)
    }
}
