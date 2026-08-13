# Web Platform Rules for `spotify_sdk`

Adhere to these rules when working in [packages/spotify_sdk_web/lib/spotify_sdk_web.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_web/lib/spotify_sdk_web.dart).

---

## 1. Context & Architecture

- Web support implements a Dart Web bridge integrating with the official [Spotify Web Playback SDK](https://developer.spotify.com/documentation/web-playback-sdk/) via JS interop.
- Directly overrides `SpotifySdkPlatform` methods to interface with JavaScript endpoints and Spotify REST Web API endpoints.

---

## 2. Web Specific Constraints

### A. Spotify Premium Requirement
- The Spotify Web Playback SDK requires a Spotify Premium account for playback control.

### B. Session and Token Management
- Manage browser OAuth PKCE via `SpotifyAuthSession`.
- Restrict token refresh calls strictly to `getAccessToken()` and `connectToSpotifyRemote()`.

---

## 3. Implementation Patterns

### JS Interop
- Declare JS library bindings using `@JS()` interop annotations and `dart:js_interop`.
- Inject Spotify Player script tags via `WebSdkLoader`.

### Event Dispatching & Typed Models
- `WebPlayerDispatcher` directly maps JS player events to Dart domain models (`PlayerState`, `PlayerContext`, `ConnectionStatus`) and emits them directly into typed `StreamController<T>` instances without JSON string serialization roundtrips.
- Device ID resolution in `WebPlayerManager` uses an event-driven `Completer<String>` triggered on player `ready` events.

### Error and Event Handling
- Map JS callbacks (`initialization_error`, `authentication_error`, `account_error`) to typed `SpotifyException` domain instances, logging via centralized Logger before rethrowing.
