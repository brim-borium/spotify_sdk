import Flutter
import UIKit

public class SwiftSpotifySdkPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let spotifySDKChannel = FlutterMethodChannel(name: "spotify_sdk", binaryMessenger: registrar.messenger())
        let connectionStatusChannel = FlutterEventChannel(name: "connection_status_subscription", binaryMessenger: registrar.messenger())

        let instance = SwiftSpotifySdkPlugin()

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
        default:
            result(FlutterError(code: "404", message: "No Method found", details: nil))
        }
    }
    
    private func connectToSpotify(clientId: String, redirectURL: String) {
        print("ClientID: \(clientId), RedirectURL: \(redirectURL)")
    }
}
