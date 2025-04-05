import Flutter
import UIKit

extension FlutterAppDelegate {
    open override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Initialize Spotify-specific components
        SwiftSpotifySdkPlugin.register(with: self.registrar(forPlugin: "SwiftSpotifySdkPlugin")!)

        return result
    }

    open override func application(
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

        return super.application(app, open: url, options: options)
    }
}
