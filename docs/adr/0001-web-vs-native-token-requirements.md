# 1. Web vs Native Access Token Requirements for Remote Connection

- **Status**: Accepted
- **Date**: 2026-07-31

## Context

The `spotify_sdk` plugin bridges native Spotify SDK capabilities across Android, iOS, and Web. On mobile platforms (Android and iOS), connection to Spotify is established via local IPC (Inter-Process Communication) to the installed Spotify application. The native Mobile App Remote SDK handles authorization and authentication out of band with the Spotify client app.

On the Web platform, Spotify does not provide a local IPC app remote. Playback control is instead driven by the Web Playback SDK in the browser, which requires an active, valid OAuth access token provided directly during player initialization.

## Decision

We accept a platform-dependent token lifecycle requirement for `connectToSpotifyRemote`:

1. On **iOS and Android**, `accessToken` is optional when calling `connectToSpotifyRemote`, as the underlying native App Remote SDK initiates IPC authentication with the installed Spotify application.
2. On **Web**, an explicit `accessToken` (obtained via `getAccessToken` or host application OAuth flow) MUST be passed to `connectToSpotifyRemote` to initialize the Web Playback SDK instance.
3. If an `accessToken` is provided on native platforms, it is stored transiently for web API fallbacks but is not required for IPC connection state.

## Consequences

- **Developer Experience**: Host applications targeting Web must call `getAccessToken` or supply a valid OAuth token before calling `connectToSpotifyRemote`.
- **Error Handling**: `ConnectionStatus` on Web will reflect authentication failure or token expiration errors distinct from IPC connection drops on mobile.
- **API Contract**: The `accessToken` parameter on `SpotifySdk.connectToSpotifyRemote` remains optional in Dart to support mobile-only flows, but Web implementation validates its presence at runtime.
