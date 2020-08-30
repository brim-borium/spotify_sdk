import SpotifyiOS

class PlayerContextHandler: StatusHandler {
    private let appRemote: SPTAppRemote
    private let playerDelegate: PlayerDelegate

    init (appRemote: SPTAppRemote, playerDelegate: PlayerDelegate) {
        self.appRemote = appRemote
        self.playerDelegate = playerDelegate
        super.init()
    }

    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _ = super.onListen(withArguments: arguments, eventSink: events)
        playerDelegate.playerContextSink = events
        return nil
    }
}
