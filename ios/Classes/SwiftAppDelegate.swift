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
        if let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]],
            let urlSchemes = urlTypes.first?["CFBundleURLSchemes"] as? [String],
            let urlScheme = urlSchemes.first
        {
            if url.scheme == urlScheme && url.host == "auth" {
                if url.path == "/spotify/callback" {
                    SwiftSpotifySdkPlugin.shared.handleSpotifyCallback(url: url)
                    return true
                }
            }
        }

        return false
    }
}
