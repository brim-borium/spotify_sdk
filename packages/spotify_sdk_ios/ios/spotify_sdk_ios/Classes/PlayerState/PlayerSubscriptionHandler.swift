import Flutter
import SpotifyiOS

class PlayerSubscriptionHandler: StatusHandler {
    private weak var appRemote: SPTAppRemote?
    private let playerDelegate: PlayerDelegate
    private let sinkKeyPath: ReferenceWritableKeyPath<PlayerDelegate, FlutterEventSink?>

    init(
        playerDelegate: PlayerDelegate,
        sinkKeyPath: ReferenceWritableKeyPath<PlayerDelegate, FlutterEventSink?>
    ) {
        self.playerDelegate = playerDelegate
        self.sinkKeyPath = sinkKeyPath
        super.init()
    }

    func setAppRemote(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        subscribeIfListening()
    }

    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _ = super.onListen(withArguments: arguments, eventSink: events)
        playerDelegate[keyPath: sinkKeyPath] = events
        subscribeIfListening()
        return nil
    }

    override func onCancel(withArguments arguments: Any?) -> FlutterError? {
        playerDelegate[keyPath: sinkKeyPath] = nil
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
