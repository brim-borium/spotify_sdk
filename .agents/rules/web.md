# Web Platform Rules for `spotify_sdk`

Adhere to these rules when working on the Web implementation inside [lib/spotify_sdk_web.dart](file:///Users/tobi/Projects/spotify_sdk/lib/spotify_sdk_web.dart).

---

## 1. Context & Architecture

- Web support does not wrap a native platform compiled library; instead, it implements a Dart Web bridge integrating with the official [Spotify Web Playback SDK](https://developer.spotify.com/documentation/web-playback-sdk/) via JS interop.
- It overrides `SpotifySdkPlatform` methods to interface with JavaScript endpoints.

---

## 2. Web Specific Constraints

### A. Spotify Premium Requirement
- The Spotify Web Playback SDK **unconditionally requires** a Spotify Premium account for playback control. Non-premium credentials will fail.

### B. Session and Token Management
- Only `getAccessToken()` and `connectToSpotifyRemote()` trigger token refreshes. Avoid storing or manually refreshing tokens within other helper methods.

---

## 3. Implementation Patterns

### JS Interop
- Use standard `js` interop annotations (`@JS()`) to declare bindings for the Spotify JS library.
- Use `package:web` utilities for browser document manipulation (e.g. injecting the Spotify Player script tags dynamically).

### Error and Event Handling
- Map JS callbacks and events (such as `initialization_error`, `authentication_error`, `account_error`) to appropriate Dart Exceptions and log them using the centralized logger before returning/throwing.
