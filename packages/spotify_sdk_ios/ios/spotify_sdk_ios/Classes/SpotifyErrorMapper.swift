import Flutter

public struct SpotifyErrorMapper {
    public static func makeError(code: String, message: String, details: Any? = nil) -> FlutterError {
        return FlutterError(code: code, message: message, details: details)
    }

    public static func notConnectedError() -> FlutterError {
        return FlutterError(code: "spotifyAppRemoteNull", message: "spotifyAppRemote is null or disconnected", details: nil)
    }

    public static func argumentError(_ message: String = "Argument Error") -> FlutterError {
        return FlutterError(code: "Argument Error", message: message, details: nil)
    }
}
