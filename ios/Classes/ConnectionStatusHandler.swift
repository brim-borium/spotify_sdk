import SpotifyiOS

class ConnectionStatusHandler: StatusHandler, SPTAppRemoteDelegate {

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        eventSink?("{\"connected\": true}")
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        if error {
            // report spotify remote error to plugin
            eventSink?("{\"connected\": false, \"errorCode\": \(error!.code), \"errorDetails\": \(error!.localizedDescription)}")
        } else {
            // report disconnection to plugin
            eventSink?("{\"connected\": false}")
        }
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        if error {
            // report spotify remote error to plugin
            eventSink?("{\"connected\": false, \"errorCode\": \(error!.code), \"errorDetails\": \(error!.localizedDescription)}")
        } else {
            // report disconnection to plugin
            eventSink?("{\"connected\": false}")
        }
    }
}
