import Flutter
import SpotifyiOS

class UserStatusHandler: StatusHandler {
    private var isConnected: Bool = false

    func updateConnectionStatus(isConnected: Bool) {
        self.isConnected = isConnected
        emitStatus()
    }

    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _ = super.onListen(withArguments: arguments, eventSink: events)
        emitStatus()
        return nil
    }

    private func emitStatus() {
        guard let sink = eventSink else { return }
        let code = isConnected ? 0 : 1
        let shortMessage = isConnected ? "OK" : "NOT_LOGGED_IN"
        let longMessage = isConnected ? "User logged in" : "User not logged in or disconnected"
        let dict: [String: Any] = [
            "code": code,
            "short_message": shortMessage,
            "long_message": longMessage
        ]
        sink(dict.json)
    }
}
