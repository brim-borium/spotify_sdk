import SpotifyiOS

class ConnectionStatusHandler: StatusHandler, SPTAppRemoteDelegate {
    var tokenResult: FlutterResult?
    var codeResult: FlutterResult?
    var connectionResult: FlutterResult?
    
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        
        connectionResult?(true)
        tokenResult?(appRemote.connectionParameters.accessToken)
        
        eventSink?("{\"connected\": true}")

        connectionResult = nil
        tokenResult = nil
        codeResult = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        defer {
            connectionResult = nil
            tokenResult = nil
            codeResult = nil
        }

        if error != nil {
            if let nsError = error as NSError? {
                // read error code recursively
                let errorCode = readErrorCode(error: nsError)
                let errorReason = readErrorReason(error: nsError)
                
                // report spotify remote error to plugin
                eventSink?("{\"connected\": false, \"errorCode\": \"\(errorCode)\", \"errorDetails\": \"\(errorReason)\"}")
                connectionResult?(FlutterError(code: String(errorCode), message: errorReason, details: nil))
                tokenResult?(FlutterError(code: String(errorCode), message: errorReason, details: nil))
                codeResult?(FlutterError(code: String(errorCode), message: errorReason, details: nil))
                
            }else {
                // report spotify remote error to plugin
                eventSink?("{\"connected\": false, \"errorCode\": \"\(error!._code)\", \"errorDetails\": \"\(error!.localizedDescription)\"}")
                connectionResult?(FlutterError(code: String(error!._code), message: error!.localizedDescription, details: nil))
                tokenResult?(FlutterError(code: String(error!._code), message: error!.localizedDescription, details: nil))
                codeResult?(FlutterError(code: String(error!._code), message: error!.localizedDescription, details: nil))
            }
            
            
        } else {
            // report disconnection to plugin
            eventSink?("{\"connected\": false}")
            connectionResult?(FlutterError(code: "errorConnection", message: "Failed Connection Attempt", details: nil))
            tokenResult?(FlutterError(code: "errorConnection", message: "Failed Connection Attempt", details: nil))
            codeResult?(FlutterError(code: "errorConnection", message: "Failed Connection Attempt", details: nil))
        }
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        if error != nil {
            // report spotify remote error to plugin
            eventSink?("{\"connected\": false, \"errorCode\": \"\(error!._code)\", \"errorDetails\": \"\(error!.localizedDescription)\"}")
        } else {
            // report disconnection to plugin
            eventSink?("{\"connected\": false}")
        }
    }


    // create a function to read first underlying error reason recursively
    func readErrorCode(error: NSError) -> String {
        if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
            return readErrorCode(error: underlyingError)
        } else {
            return String(error.code)
        }
    }
    
    // create a function to read first underlying error reason recursively
    func readErrorReason(error: NSError) -> String {
        if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
            return readErrorReason(error: underlyingError)
        } else {
            return error.localizedFailureReason ?? error.localizedDescription
        }
    }


    
    
    
    
}
