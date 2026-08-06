import Flutter
import SpotifyiOS

public class RemoteManager: NSObject {
    public static let shared = RemoteManager()

    public var appRemote: SPTAppRemote?
    public var connectionStatusHandler: ConnectionStatusHandler?
    public var playerStateHandler: PlayerStateHandler?
    public var playerContextHandler: PlayerContextHandler?
    public var playerStateChannel: FlutterEventChannel?
    public var playerContextChannel: FlutterEventChannel?

    public override init() {
        super.init()
    }
}
