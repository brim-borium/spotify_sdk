import Flutter
import SpotifyiOS

class RemoteManager: NSObject {
    static let shared = RemoteManager()

    var appRemote: SPTAppRemote?
    var connectionStatusHandler: ConnectionStatusHandler?
    var playerStateHandler: PlayerStateHandler?
    var playerContextHandler: PlayerContextHandler?
    static var playerStateChannel: FlutterEventChannel?
    static var playerContextChannel: FlutterEventChannel?

    override init() {
        super.init()
    }
}
