---
name: add-sdk-method
description: Add or change a public SpotifySdk method consistently across all platforms. Use when adding a new method to the spotify_sdk plugin's public API, or changing an existing method's name/parameters, so the Dart API, channel constants, Android, iOS, web, and docs all stay in parity.
---

# Add an SDK method across all platforms

This plugin exposes one Dart API bridged to Android, iOS, and web over platform
channels. A method only works if it is implemented on **every** platform and the
method/param **name strings match exactly** everywhere. This skill enforces that
parity checklist so a method is never added half-way.

## Inputs to establish first

Before writing code, confirm with the user (or infer from the request):

- **Method name** (camelCase, e.g. `setVolume`) — becomes the `MethodNames`
  constant value and must be identical in Dart, Android, and iOS.
- **Parameters**: names (camelCase) + Dart types, which become `ParamNames`
  constants.
- **Return type** (Dart): `bool`, a model, `Uint8List`, a `Stream`, etc.
- **Platform support**: is it supported on all of Android / iOS / web? If a
  platform can't support it, decide the explicit fallback (throw
  `UnimplementedError` / `PlatformException`) and document it.

## Checklist — touch every item

Work top to bottom. Match the surrounding style in each file.

1. **`lib/platform_channels.dart`**
   - Add the method-name constant to `class MethodNames`.
   - Add any new param-name constants to `class ParamNames`.
   - Give each a `///` doc comment (matches existing entries; needed for pub score).

2. **`lib/spotify_sdk.dart`**
   - Add the static method on `SpotifySdk` with a full `///` doc comment
     (document params with `[name]`, note any platform-specific behavior, and
     the exceptions it throws).
   - Follow the established body pattern:
     ```dart
     try {
       return await _channel.invokeMethod(MethodNames.<name>, {
         ParamNames.<p>: <p>,
       });
     } on Exception catch (e) {
       _logException(MethodNames.<name>, e);
       rethrow;
     }
     ```

3. **Android** (`android/src/main/kotlin/de/minimalme/spotify_sdk/`)
   - Add a branch in the `when (call.method)` block of `SpotifySdkPlugin.kt`,
     reading args via `call.argument<…>("<param>")`.
   - Implement in the relevant `Spotify{Player,User,Images,Connect}Api.kt`
     (extend `BaseSpotifyApi`); return via `result.success(...)` (use
     `Gson().toJson(...)` for objects) and `result.error(code, message, details)`
     on failure. Add a private error-code string like the existing ones.

4. **iOS** (`ios/Classes/`)
   - Add the method/param constants to `SpotifySdkConstants.swift`.
   - Add a `case SpotifySdkConstants.method<Name>:` to the `switch call.method`
     in `SwiftSpotifySdkPlugin.swift`; read args from the `arguments` dictionary;
     return via `result(...)` or `result(FlutterError(code:message:details:))`.

5. **Web** (`lib/spotify_sdk_web.dart`)
   - Handle the new method in the web `handleMethodCall` switch, or throw a
     documented `PlatformException`/`UnimplementedError` if unsupported.

6. **Docs**
   - Add the method to the relevant API table in `README.md`.
   - Add a `CHANGELOG.md` entry (mark **BREAKING** if you changed an existing
     signature).
   - If the public API changed, ensure the example (`example/lib/main.dart`) still
     compiles; add a demo there if it helps.

7. **Tests** — add/extend a test in `test/spotify_sdk_test.dart` using the
   mock-method-channel pattern already in that file.

## Verify

Run `/regen` if any model changed, then `/verify` (the full CI loop). Do not
consider the method done until `/verify` is green and `pana` is still perfect.

## Common pitfalls

- Name-string drift between Dart/Android/iOS → the call lands as
  "not implemented" on a platform. Always reference the constants; never inline
  the strings.
- Forgetting `///` docs on the new public Dart member → pub score drops → CI red.
- Editing a `.g.dart` by hand instead of changing the model source and running
  `/regen`.
