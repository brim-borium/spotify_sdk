import Flutter
import UIKit
import SpotifyiOS

public class SwiftSpotifySdkPlugin: NSObject, FlutterPlugin {

    var appRemote: SPTAppRemote?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let spotifySDKChannel = FlutterMethodChannel(name: "spotify_sdk", binaryMessenger: registrar.messenger())
        let connectionStatusChannel = FlutterEventChannel(name: "connection_status_subscription", binaryMessenger: registrar.messenger())

        let instance = SwiftSpotifySdkPlugin()
        registrar.addApplicationDelegate(instance)

        registrar.addMethodCallDelegate(instance, channel: spotifySDKChannel)
        connectionStatusChannel.setStreamHandler(ConnectionStatusHandler())
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let swiftArguments = call.arguments as? [String:Any] else {
            result(FlutterError(code: "Arguments Error", message: "Could not parse arguments", details: nil))
            return
        }

        switch call.method {
        case SpotfySdkConstants.methodConnectToSpotify:
            guard let clientID = swiftArguments[SpotfySdkConstants.paramClientId] as? String,
                let url =  swiftArguments[SpotfySdkConstants.paramRedirectUrl] as? String else {
                    result(FlutterError(code: "Arguments Error", message: "One or more arguments are missing", details: nil))
                    return
            }
            connectToSpotify(clientId: clientID, redirectURL: url)
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func connectToSpotify(clientId: String, redirectURL: String) {
        guard let redirectURL = URL(string: redirectURL) else { return }
        let configuration = SPTConfiguration(clientID: clientId, redirectURL: redirectURL)
        appRemote = SPTAppRemote(configuration: configuration, logLevel: .none)

        // Note: A blank string will play the user's last song or pick a random one.
        if appRemote?.authorizeAndPlayURI("") == false {

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

    func setAccessTokenFromURL(url: URL) {
        let params = appRemote?.authorizationParameters(from: url)
        if let token = params?[SPTAppRemoteAccessTokenKey] {
            self.appRemote?.connectionParameters.accessToken = token
            self.appRemote?.connect()
        }
        else if let error = params?[SPTAppRemoteErrorDescriptionKey] {
            print(error)
        }
    }
}
