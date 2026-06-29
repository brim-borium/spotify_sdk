# AGENTS.md — guidance for AI coding agents

> Canonical agent guide for this repository. Other tool-specific files
> (`CLAUDE.md`, etc.) point here. Keep this file the single source of truth.

## What this project is

`spotify_sdk` is a multi-platform **Flutter plugin** that wraps the native
Spotify SDKs so Flutter apps can authenticate with and remote-control Spotify
playback. One Dart public API is bridged to four platform implementations over
Flutter platform channels:

| Layer | Tech | Entry point |
|-------|------|-------------|
| Public API | Dart | `lib/spotify_sdk.dart` (`SpotifySdk`, static methods) |
| Android | Kotlin | `android/src/main/kotlin/de/minimalme/spotify_sdk/` |
| iOS | Swift / Obj-C | `ios/Classes/` |
| Web | Dart + JS interop | `lib/spotify_sdk_web.dart` |

Communication uses **one `MethodChannel`** (`spotify_sdk`) for request/response
calls and **five `EventChannel`s** for streamed state (player state, player
context, connection status, user status, capabilities). Data crosses the
channel boundary as JSON strings.

## Architecture map

| Path | Role |
|------|------|
| `lib/spotify_sdk.dart` | Public `SpotifySdk` API — every method invokes the method channel |
| `lib/platform_channels.dart` | **The cross-platform contract**: channel, method, and param name constants (`MethodChannels`, `EventChannels`, `MethodNames`, `ParamNames`) |
| `lib/models/*.dart` (+ `*.g.dart`) | `json_serializable` data models (PlayerState, Track, Album, …) |
| `lib/enums/*`, `lib/extensions/*` | RepeatMode/ImageDimension/PodcastPlaybackSpeed + enum↔value mappings |
| `lib/logging/custom_log_filter.dart` | Optional log filter (off by default) |
| `android/.../SpotifySdkPlugin.kt` | Android plugin; routes `call.method` to `Spotify*Api.kt` |
| `android/.../Spotify{Player,User,Images,Connect}Api.kt` | Android API impls (extend `BaseSpotifyApi`); serialize with `Gson().toJson(...)` |
| `android/.../subscriptions/*.kt` | Android `EventChannel.StreamHandler`s |
| `ios/Classes/SwiftSpotifySdkPlugin.swift` | iOS plugin; `switch call.method` routes calls |
| `ios/Classes/SpotifySdkConstants.swift` | iOS mirror of method/param name constants |
| `ios/Classes/*Handler.swift`, `PlayerDelegate.swift` | iOS event-stream handlers |
| `example/lib/main.dart` | Full usage reference for the public API |
| `bin/*.dart` | Android-SDK setup automation (see below) |

## Setup / prerequisites

```bash
flutter pub get
```

- **Android**: the Spotify App Remote SDK is fetched into a gradle module by
  `dart run spotify_sdk:android_setup` (options: `--verbose`, `--cleanup`,
  `--sdk-version=X.X.X`). Source in `bin/android_setup.dart`.
- **iOS**: `ios/prepare-iOS-SDK.sh` clones the native Spotify iOS SDK and
  extracts `SpotifyiOS.xcframework`.
- **Example app**: needs a `.env` (declared in `example/pubspec.yaml` assets)
  with a Spotify `clientId` and `redirectUrl`.

## Build / test / verify

Run the full canonical loop before opening a PR — it mirrors
`.github/workflows/pull_request.yml`, so **local green == CI green**. The
fast path is the `/verify` slash command (`.claude/commands/verify.md`).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only if models changed (or use /regen)
dart format --set-exit-if-changed lib test example
flutter analyze lib test example --no-fatal-infos
flutter test
flutter pub publish --dry-run
pana . --no-warning        # CI requires a PERFECT score — see below
```

> **Perfect-score gate:** `.github/scripts/verify_pub_score.sh` fails CI unless
> `pana` reports a perfect pub score. New public API must have `///` doc
> comments, formatting must be clean, and no analyzer issues — or the score
> drops and CI goes red.

## Conventions

- **Doc comments**: every public Dart member gets a `///` comment (also required
  for the pub score). Reference params/types in brackets, e.g. `[clientId]`.
- **Error handling (Dart)**: each `SpotifySdk` method wraps the channel call and
  rethrows after logging:
  ```dart
  try {
    return await _channel.invokeMethod(MethodNames.foo, { ParamNames.bar: bar });
  } on Exception catch (e) {
    _logException(MethodNames.foo, e);
    rethrow;
  }
  ```
  `_logException` handles `PlatformException` / `MissingPluginException` /
  generic exceptions.
- **Naming**: `camelCase` in Dart; channel/method/**param string values are also
  camelCase** but are always referenced through the constants in
  `platform_channels.dart` — never hard-code the strings.
- **Transport**: arguments go as a `Map`; native side returns JSON strings that
  Dart decodes into models. Android serializes with **GSON**.
- **Android errors**: `result.error(code, message, details)` with string codes
  (e.g. `"queueError"`). **iOS errors**: `FlutterError(code:message:details:)`.

## The parity rule (read before changing the API)

The method/param **name strings must match exactly** across Dart, Android, and
iOS, and behavior must be implemented on every platform or the plugin silently
breaks on the ones you skipped. **Adding or changing a public method requires
touching all of these:**

1. `lib/spotify_sdk.dart` — the `SpotifySdk` method (with `///` docs + try/rethrow).
2. `lib/platform_channels.dart` — add the `MethodNames` / `ParamNames` constants.
3. Android — handle `call.method` in `SpotifySdkPlugin.kt` and implement in the
   relevant `Spotify*Api.kt`.
4. iOS — add constants to `SpotifySdkConstants.swift` and a `case` in the
   `switch call.method` of `SwiftSpotifySdkPlugin.swift`.
5. Web — implement in `lib/spotify_sdk_web.dart` (or explicitly throw
   `UnimplementedError`/`PlatformException` if unsupported, and document it).
6. Docs — update the API table in `README.md` and add a `CHANGELOG.md` entry.

The `add-sdk-method` skill (`.claude/skills/add-sdk-method/`) walks this
checklist automatically.

## Do not touch

- **Generated files** — `lib/models/*.g.dart`. Edit the `.dart` source, then
  regenerate with `/regen` (build_runner). Never hand-edit `.g.dart`.
- **Vendored native SDKs** — the downloaded Android gradle module and
  `ios/ios-sdk/` / extracted xcframework. These are produced by the setup
  scripts, not committed source.
- **Generated docs** — `doc/`.

## PR / commit conventions (from CONTRIBUTING.md)

- Branch from `main` prefixed `feature/`, `bug/`, or `task/`.
- Commits are squashed on merge; the **PR title is the merge message** — use
  imperative mood ("Add X", not "Added X").
- Public-API changes should start as an issue for discussion.
- Update `README.md` (API tables / migration notes) and `CHANGELOG.md`.
- Keep the `pana` score perfect and all status checks green.

## Known gaps

- **Test coverage is thin** — only `test/spotify_sdk_test.dart` exists, covering
  a single connect call. When you add or change behavior, add tests. The
  established pattern mocks the method channel:
  ```dart
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async => /* fake result */);
  ```
  Native (Kotlin/Swift) code is not unit-tested in this repo.
