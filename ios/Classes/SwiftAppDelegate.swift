import Flutter
import UIKit

public class SpotifyAppDelegate {
    public static func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        // Initialize Spotify-specific components
        if let registrar = (application.delegate as? FlutterAppDelegate)?.registrar(
            forPlugin: "SwiftSpotifySdkPlugin")
        {
            SwiftSpotifySdkPlugin.register(with: registrar)
        }
    }

    public static func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Handle Spotify URL callback
        if let value = Bundle.main.infoDictionary?["SpotifySDKCallbackURL"] as? String {
            if url.absoluteString == value {
                SwiftSpotifySdkPlugin.shared.handleSpotifyCallback(url: url)
                return true
            }
        }

        return false
    }
}
