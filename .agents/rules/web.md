# Web Platform Rules for `spotify_sdk`

Adhere to these rules when working in [packages/spotify_sdk_web/lib/spotify_sdk_web.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_web/lib/spotify_sdk_web.dart).

---

## 1. Context & Architecture

- Web support implements a Dart Web bridge integrating with the official [Spotify Web Playback SDK](https://developer.spotify.com/documentation/web-playback-sdk/) via JS interop.
- Overrides `SpotifySdkPlatform` methods to interface with JavaScript endpoints.

---

## 2. Web Specific Constraints

### A. Spotify Premium Requirement
- The Spotify Web Playback SDK requires a Spotify Premium account for playback control.

### B. Session and Token Management
- Restrict token refresh calls strictly to `getAccessToken()` and `connectToSpotifyRemote()`.

---

## 3. Implementation Patterns

### JS Interop
- Declare JS library bindings using `@JS()` interop annotations.
- Manipulate DOM elements (e.g., injecting Spotify Player script tags) via `package:web` utilities.

### Error and Event Handling
- Map JS callbacks (`initialization_error`, `authentication_error`, `account_error`) to Dart Exceptions, logging via centralized Logger before rethrowing.

