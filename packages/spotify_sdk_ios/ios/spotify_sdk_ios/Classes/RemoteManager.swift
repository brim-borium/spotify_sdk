import Flutter
import SpotifyiOS

class RemoteManager: NSObject {
    static let shared = RemoteManager()

    var appRemote: SPTAppRemote?
    var connectionStatusHandler: ConnectionStatusHandler?
    var playerStateHandler: PlayerStateHandler?
    var playerContextHandler: PlayerContextHandler?
    var capabilitiesHandler: CapabilitiesHandler?
    var userStatusHandler: UserStatusHandler?

    static var playerStateChannel: FlutterEventChannel?
    static var playerContextChannel: FlutterEventChannel?
    static var capabilitiesChannel: FlutterEventChannel?
    static var userStatusChannel: FlutterEventChannel?
    static var connectionStatusChannel: FlutterEventChannel?

    override init() {
        super.init()
    }
}
