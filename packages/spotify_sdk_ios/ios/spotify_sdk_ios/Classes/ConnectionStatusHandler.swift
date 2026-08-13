import Flutter
import SpotifyiOS

class ConnectionStatusHandler: StatusHandler, SPTAppRemoteDelegate {

    var tokenResult: FlutterResult?
    var connectionResult: FlutterResult?
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        RemoteManager.shared.capabilitiesHandler?.setAppRemote(appRemote)
        RemoteManager.shared.userStatusHandler?.updateConnectionStatus(isConnected: true)

        connectionResult?(true)
        tokenResult?(appRemote.connectionParameters.accessToken)
        eventSink?("{\"connected\": true}")

        connectionResult = nil
        tokenResult = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        RemoteManager.shared.userStatusHandler?.updateConnectionStatus(isConnected: false)
        defer {
            connectionResult = nil
            tokenResult = nil
        }

        if error != nil {
            // report spotify remote error to plugin
            eventSink?("{\"connected\": false, \"errorCode\": \"\(error!._code)\", \"errorDetails\": \"\(error!.localizedDescription)\"}")
            connectionResult?(FlutterError(code: String(error!._code), message: error!.localizedDescription, details: nil))
            tokenResult?(FlutterError(code: String(error!._code), message: error!.localizedDescription, details: nil))
        } else {
            // report disconnection to plugin
            eventSink?("{\"connected\": false}")
            connectionResult?(FlutterError(code: "errorConnection", message: "Failed Connection Attempt", details: nil))
            tokenResult?(FlutterError(code: "errorConnection", message: "Failed Connection Attempt", details: nil))
        }
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        RemoteManager.shared.userStatusHandler?.updateConnectionStatus(isConnected: false)
        if error != nil {
            // report spotify remote error to plugin
            eventSink?("{\"connected\": false, \"errorCode\": \"\(error!._code)\", \"errorDetails\": \"\(error!.localizedDescription)\"}")
        } else {
            // report disconnection to plugin
            eventSink?("{\"connected\": false}")
        }
    }
}
