import Flutter
import SpotifyiOS

public class SwiftSpotifySdkPlugin: NSObject, FlutterPlugin {

    private var appRemote: SPTAppRemote?
    private var connectionStatusHandler: ConnectionStatusHandler?
    private var playerStateHandler: PlayerStateHandler?
    private var playerContextHandler: PlayerContextHandler?
    private static var playerStateChannel: FlutterEventChannel?
    private static var playerContextChannel: FlutterEventChannel?
    private var result: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let spotifySDKChannel = FlutterMethodChannel(name: "spotify_sdk", binaryMessenger: registrar.messenger())
        let connectionStatusChannel = FlutterEventChannel(name: "connection_status_subscription", binaryMessenger: registrar.messenger())
        playerStateChannel = FlutterEventChannel(name: "player_state_subscription", binaryMessenger: registrar.messenger())
        playerContextChannel = FlutterEventChannel(name: "player_context_subscription", binaryMessenger: registrar.messenger())

        let instance = SwiftSpotifySdkPlugin()
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: spotifySDKChannel)

        instance.connectionStatusHandler = ConnectionStatusHandler()

        connectionStatusChannel.setStreamHandler(instance.connectionStatusHandler)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case SpotfySdkConstants.methodConnectToSpotify:
            guard let swiftArguments = call.arguments as? [String:Any],
                let clientID = swiftArguments[SpotfySdkConstants.paramClientId] as? String,
                let url = swiftArguments[SpotfySdkConstants.paramRedirectUrl] as? String else {
                    result(FlutterError(code: "Arguments Error", message: "One or more arguments are missing", details: nil))
                    return
            }
            if let accessToken = swiftArguments[SpotfySdkConstants.paramAccessToken] as? String, let appRemote = appRemote {
                appRemote.connectionParameters.accessToken = accessToken
                appRemote.connect()
            } else {
                connectToSpotify(clientId: clientID, redirectURL: url)
            }
            result(true)
        case SpotfySdkConstants.methodGetAuthenticationToken:
            guard let swiftArguments = call.arguments as? [String:Any],
                let clientID = swiftArguments[SpotfySdkConstants.paramClientId] as? String,
                let url = swiftArguments[SpotfySdkConstants.paramRedirectUrl] as? String else {
                    result(FlutterError(code: "Arguments Error", message: "One or more arguments are missing", details: nil))
                    return
            }
            self.result = result
            connectToSpotify(clientId: clientID, redirectURL: url)
        case SpotfySdkConstants.methodGetImage:
            guard let swiftArguments = call.arguments as? [String:Any],
                let paramImageUri = swiftArguments[SpotfySdkConstants.paramImageUri] as? String,
                let paramImageDimension = swiftArguments[SpotfySdkConstants.paramImageDimension] as? Int else {
                    result(FlutterError(code: "Arguments Error", message: "One or more arguments are missing", details: nil))
                    return
            }

            class ImageObject: NSObject, SPTAppRemoteImageRepresentable {
                var imageIdentifier: String = ""
            }

            let imageObject = ImageObject()
            imageObject.imageIdentifier = paramImageUri
            appRemote?.imageAPI?.fetchImage(forItem: imageObject, with: CGSize(width: paramImageDimension, height: paramImageDimension), callback: { (image, error) in
                guard error == nil else {
                    result(FlutterError(code: "ImageAPI Error", message: error?.localizedDescription, details: nil))
                    return
                }
                guard let imageData = (image as? UIImage)?.pngData() else {
                    result(FlutterError(code: "ImageAPI Error", message: "Image is empty", details: nil))
                    return
                }
                result(imageData)
            })
        case SpotfySdkConstants.methodGetPlayerState:
            appRemote?.playerAPI?.getPlayerState({ (playerState, error) in
                guard error == nil else {
                    result(FlutterError(code: "PlayerAPI Error", message: error?.localizedDescription, details: nil))
                    return
                }
                guard let playerState = playerState as? SPTAppRemotePlayerState else {
                    result(FlutterError(code: "PlayerAPI Error", message: "PlayerState is empty", details: nil))
                    return
                }
                result(PlayerState.stateJson(playerState).json)
            })
        case SpotfySdkConstants.methodLogoutFromSpotify:
            appRemote?.disconnect()
//            appRemote?.connectionParameters.accessToken = nil
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func connectToSpotify(clientId: String, redirectURL: String, accessToken: String? = nil) {
        guard let redirectURL = URL(string: redirectURL) else { return }
        let configuration = SPTConfiguration(clientID: clientId, redirectURL: redirectURL)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .none)
        appRemote.delegate = connectionStatusHandler
        let playerDelegate = PlayerDelegate()
        playerStateHandler = PlayerStateHandler(appRemote: appRemote, playerDelegate: playerDelegate)
        SwiftSpotifySdkPlugin.playerStateChannel?.setStreamHandler(playerStateHandler)

        playerContextHandler = PlayerContextHandler(appRemote: appRemote, playerDelegate: playerDelegate)
        SwiftSpotifySdkPlugin.playerContextChannel?.setStreamHandler(playerContextHandler)

        self.appRemote = appRemote

        // Note: A blank string will play the user's last song or pick a random one.
        if self.appRemote?.authorizeAndPlayURI("") == false {

            /*
             * The Spotify app is not installed.
             * Use SKStoreProductViewController with [SPTAppRemote spotifyItunesItemIdentifier] to present the user
             * with a way to install the Spotify app.
             */
        }
    }
}

extension SwiftSpotifySdkPlugin: UIApplicationDelegate {
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        setAccessTokenFromURL(url: url)
        return true
    }

    private func setAccessTokenFromURL(url: URL) {
        let params = appRemote?.authorizationParameters(from: url)
        if let token = params?[SPTAppRemoteAccessTokenKey] {
            self.appRemote?.connectionParameters.accessToken = token
            self.appRemote?.connect()
            self.result?(token)
            self.result = nil
        }
        else if let error = params?[SPTAppRemoteErrorDescriptionKey] {
            print(error)
        }
    }
}
