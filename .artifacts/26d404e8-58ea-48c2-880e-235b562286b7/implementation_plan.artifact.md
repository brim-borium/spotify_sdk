# Fix All Linting Warnings and Update Dependencies

The goal is to address the 259 linting issues identified by `flutter analyze` and update all project dependencies to their latest stable versions.

## Proposed Changes

I will categorize the fixes to streamline the process.

### 1. Update Dependencies
- **[MODIFY] [pubspec.yaml](file:///Users/tobi/Projects/spotify_sdk/pubspec.yaml)**:
    - Update `dio` to `^5.10.0`
    - Update `js` to `^0.7.2` (Note: Discontinued, but updating to latest version)
    - Update `json_annotation` to `^4.12.0`
    - Update `logger` to `^2.7.0`
    - Update `synchronized` to `^3.4.1`
    - Update `web` to `^1.1.1`
    - Update `build_runner` to `^2.15.2`
    - Update `json_serializable` to `^6.14.0`
    - Update `very_good_analysis` to `^10.3.0`
    - Sort dependencies alphabetically.
- **[MODIFY] [example/pubspec.yaml](file:///Users/tobi/Projects/spotify_sdk/example/pubspec.yaml)**:
    - Update `cupertino_icons` to `^1.0.9`
    - Update `flutter_dotenv` to `^6.0.1`
    - Update `logger` to `^2.7.0`
    - Update `very_good_analysis` to `^10.3.0`
    - Sort dependencies alphabetically.

### 2. Script Cleanup (bin/ directory)
- Address `unawaited_futures`, `avoid_catches_without_on_clauses`, `parameter_assignments`, and `lines_longer_than_80_chars` in:
    - `bin/android_cleanup.dart`
    - `bin/android_module_creator.dart`
    - `bin/android_setup.dart`
    - `bin/github_api.dart`
    - `bin/precondition_checker.dart`

### 3. Model Documentation
- Address `public_member_api_docs` in all model classes under `lib/models/`. Adding standard KDoc comments to constructors and fields.

### 4. Web Implementation (lib/spotify_sdk_web.dart)
- Address `avoid_dynamic_calls`, `cascade_invocations`, `lines_longer_than_80_chars`, and `document_ignores`.
- Refactor to reduce dynamic calls and use cascades.

### 5. Example App (example/lib/)
- Address `public_member_api_docs`, `lines_longer_than_80_chars`, and `unreachable_from_main` in `example/lib/main.dart` and other files.

## Verification Plan

### Automated Tests
- Run `flutter pub get` in both root and example.
- Run `flutter analyze` after each batch of changes.
- Final goal: `No issues found!`.

### Manual Verification
- Ensure the example app builds and runs correctly with the updated dependencies.
