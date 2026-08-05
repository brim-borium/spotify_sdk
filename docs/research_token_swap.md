# Spotify Authorization: Token Swap vs. PKCE

## 1. Overview of Spotify's Developer Documentation
According to the official [Spotify Developer Documentation](https://developer.spotify.com/documentation/web-api/tutorials/code-pkce-flow), there are two primary methods for mobile and web clients to authenticate and obtain an authorization token/code:
*   **Authorization Code with PKCE (Proof Key for Code Exchange):** The recommended modern standard for mobile and single-page apps (SPAs) where securely storing a `client_secret` is not possible.
*   **Authorization Code Flow (Token Swap):** The traditional OAuth 2.0 flow. For mobile apps, this requires setting up a secure backend server (the "Token Swap" and "Token Refresh" services) to hold the `client_secret` and handle the token exchange.

## 2. Is Token Swap still supported and viable?
**Yes, Token Swap is still supported and viable, but it is considered legacy for purely mobile/client-side apps.**
*   **Not Obsolete, But Situational:** If your architecture already mandates a backend server that handles user sessions and proxying requests to Spotify, the Token Swap approach is completely valid and highly secure.
*   **Replaced by PKCE for Clients:** For standalone iOS, Android, and Flutter applications that do not want to maintain an intermediate backend just for authentication, **PKCE is the recommended standard**. PKCE enables the app to securely acquire and refresh tokens directly using a dynamically generated `code_verifier` and `code_challenge`, eliminating the risk of reverse-engineering a static `client_secret` from the mobile binary.

## 3. Analysis of PR #233 in `brim-borium/spotify_sdk`
**PR #233 ("Support getting a Swap Token")**
*   **What it does:** This PR implements a mechanism for the Flutter client to request the initial authorization `code` (often colloquially referred to as a "swap token") from the native Spotify application without automatically resolving it into an access token. 
    *   On **iOS**, it leverages `SPTSessionManager` to trigger the flow and retrieve the authorization code.
    *   On **Android**, it leverages the `AuthorizationClient` (from the `spotify-auth` Android SDK) to retrieve the code.
    *   It also adds a utility `isSpotifyInstalled` to check if the native Spotify app is present on the device.
*   **Are `SPTSessionManager` and Token Swap still relevant?**
    *   **iOS (`SPTSessionManager`):** Yes, highly relevant. `SPTSessionManager` is not deprecated in the official iOS SDK. In fact, it has been updated to natively support the PKCE flow as well. However, in the context of PR #233, it is used to obtain the authorization code so the Flutter layer (or a backend) can manually handle the token swap.
    *   **Android (`AuthorizationClient`):** The Spotify Android Auth SDK (`spotify-auth`) has officially been placed into maintenance mode by Spotify. Spotify now recommends Android developers use the standard [AppAuth](https://github.com/openid/AppAuth-Android) library for PKCE. Nonetheless, `AuthorizationClient` remains relevant for legacy plugins like `spotify_sdk` that wrap it for backward compatibility and to support custom backend Token Swap implementations.

## 4. Comparison: Token Swap vs Authorization Code Flow with PKCE

| Feature | Token Swap | PKCE (Auth Code Flow) |
| :--- | :--- | :--- |
| **Security Mechanism** | Protects the static `client_secret` by storing it securely on a backend server. The client never sees the secret. | Eliminates the need for a `client_secret`. Uses a dynamically generated cryptographic `code_verifier` and `code_challenge` per request. |
| **Backend Requirement** | **Required.** Must host a web server (e.g., Node.js, Ruby, Python) with `/swap` and `/refresh` endpoints. | **None.** The client application communicates directly with the Spotify Accounts service. |
| **Token Refresh Capability** | The mobile client passes its `refresh_token` to the custom backend, which uses the `client_secret` to get a new token from Spotify. | The mobile client directly sends the `refresh_token` to Spotify (along with the original Client ID) to receive a new access token. |
| **Mobile SDK Support** | Supported historically via native SDKs (e.g., iOS `SPTSessionManager` configured with `tokenSwapURL`). | **Native & Recommended.** The modern iOS SDK handles PKCE out of the box. Android natively supports it via AppAuth. |
| **Best Use Case** | Apps that require server-side proxying, analytics, or strict control over user sessions and API calls. | Standalone mobile and web apps that want a seamless, secure login without maintaining backend infrastructure. |

### Conclusion
For new integrations in Flutter, if a custom backend is not strictly required for other business logic, **PKCE** is the superior, frictionless choice. PR #233 accommodates users who have existing backend infrastructures or legacy requirements (Token Swap) by exposing the necessary authorization codes from both iOS and Android natively.
