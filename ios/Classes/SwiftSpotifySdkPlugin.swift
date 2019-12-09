import Flutter
import UIKit

public class SwiftSpotifySdkPlugin: NSObject, FlutterPlugin {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "spotify_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftSpotifySdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    guard let swiftArguments = call.arguments as? [String:Any] else {
        result(FlutterError(code: "WROOOOOONG", message: "Could not convert arguments", details: nil))
        return;
    }

    
    switch call.method {
    case SpotfySdkConstants.methodConnectToSpotify:
        guard let clientID = swiftArguments[SpotfySdkConstants.paramClientId] as? String,
        let url =  swiftArguments[SpotfySdkConstants.paramRedirectUrl] as? String else {
            result(FlutterError(code: "WROOOOOONG", message: "Arguments of wrong type", details: nil))
            return;
        }
        connectToSpotify(clientId: "",redirectUrl: "")
        break;
    default:
        result(FlutterError(code: "404", message: "Not Method found", details: nil));
        break;
    }
  }
    
    private func connectToSpotify(clientId: String, redirectUrl: String) {
        print("Good Job!")
    }
}
