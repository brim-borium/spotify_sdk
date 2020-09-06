import SpotifyiOS

class ConnectionStatusHandler: StatusHandler, SPTAppRemoteDelegate {

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        eventSink?("{\"connected\": true}")
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        eventSink?(FlutterError(code: "didFailConnectionAttemptWithError", message: error?.localizedDescription, details: nil))
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        eventSink?(FlutterError(code: "didDisconnectWithError", message: error?.localizedDescription, details: nil))
    }
}
