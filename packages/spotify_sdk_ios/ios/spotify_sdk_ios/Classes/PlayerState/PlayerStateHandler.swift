import Flutter
import SpotifyiOS

class PlayerStateHandler: StatusHandler {
    private weak var appRemote: SPTAppRemote?
    private let playerDelegate: PlayerDelegate

    init(appRemote: SPTAppRemote? = nil, playerDelegate: PlayerDelegate) {
        self.appRemote = appRemote
        self.playerDelegate = playerDelegate
        super.init()
    }

    func setAppRemote(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        subscribeIfListening()
    }

    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _ = super.onListen(withArguments: arguments, eventSink: events)
        playerDelegate.playerStateSink = events
        subscribeIfListening()
        return nil
    }

    override func onCancel(withArguments arguments: Any?) -> FlutterError? {
        playerDelegate.playerStateSink = nil
        return super.onCancel(withArguments: arguments)
    }

    private func subscribeIfListening() {
        guard eventSink != nil, let playerAPI = appRemote?.playerAPI else { return }
        playerAPI.delegate = playerDelegate
        playerAPI.subscribe { (_, error) in
            guard error == nil else { return }
        }
    }
}
