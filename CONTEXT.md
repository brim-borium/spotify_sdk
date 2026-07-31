# Domain Context: Spotify Client Integration

This document defines the shared domain vocabulary, boundaries, and architectural patterns used across the `spotify_sdk` workspace.

## Bounded Context

The entire repository operates under a single bounded context: **Spotify Client Integration**. This context maps native platform capabilities to a unified Flutter interface, supporting two primary capabilities:

1. **App Remote Connection**: Managing local IPC connection to the Spotify player app on mobile, or instantiating/controlling the Web Playback SDK on Web.
2. **Access Token Flow**: The OAuth credential retrieval path, which can optionally feed into the App Remote flow (e.g. for Web playback initialization) or be returned directly to the host application for custom Web API calls.

## Glossary

To avoid ambiguity, the codebase aligns on the following terminology:

*   **App Remote Connection State** (represented in code by `ConnectionStatus`): Indicates whether the client app's connection to the local Spotify player service is active (`connected: true`) or not, along with optional native error codes.
*   **User Session Status** (represented in code by `UserStatus`): Indicates the authentication state of the Spotify app on the device (e.g., whether the user is logged into Spotify).
*   **User Playback Capabilities** (represented in code by `Capabilities`): Refers to the product level/tier of the user (e.g. Free vs. Premium), specifically whether they can play tracks on demand (`canPlayOnDemand`).
*   **Player State**: The dynamic, instantaneous playback status of the active player session. It tracks play/pause state, speed, time position, active track metadata, shuffle/repeat configurations (Player Options), and operation limitations (Player Restrictions).
*   **Player Context**: The catalog container source (e.g., Album, Playlist, Artist, Podcast) that the currently playing track belongs to, including its display metadata and Spotify URI.
*   **Crossfade Configuration**: The user setting determining if playback transitions between subsequent tracks overlap smoothly, defined by an enablement flag and transition duration.
*   **Library State**: The status indicating whether a given Spotify resource is currently saved to the user's personal collection/library (`isSaved`) and whether the user's account tier allows saving this type of item (`canSave`).
*   **Spotify URI**: A unique, resource-specific identifier string (e.g., `spotify:track:<id>`, `spotify:album:<id>`, `spotify:playlist:<id>`) used across all platform implementations to target playback, queueing, or library actions.

## Architectural Conventions

To maintain synchronization and consistency across all platform wrappers, the codebase enforces the following conventions:

1.  **Federated Monorepo Structure**: 
    *   [spotify_sdk](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk): The public user-facing API package.
    *   [spotify_sdk_platform_interface](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface): The common contracts, model definitions, and channels.
    *   [spotify_sdk_android](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_android), [spotify_sdk_ios](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_ios), [spotify_sdk_web](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_web): The platform-specific native implementations.
2.  **Centralized Bridge Pattern**:
    *   All method channel names, event channel names, method keys, and parameter keys MUST be stored centrally in [platform_channels.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface/lib/platform_channels.dart).
3.  **Data Serialization & Code Generation**:
    *   All model classes reside in the platform interface models folder and must use `json_serializable`.
    *   Always use `@JsonKey(name: 'snake_case')` for fields to align with the native Spotify SDK payloads.
    *   Never manually edit `.g.dart` files; always run `build_runner` for regeneration.
4.  **Error Handling Policies**:
    *   Wrap all native channel invocations in `try-on Exception` blocks.
    *   Log exceptions using a unified Logger helper, and **always rethrow** the exception to allow caller applications to respond.
