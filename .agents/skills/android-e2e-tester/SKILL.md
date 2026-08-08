---
name: android-e2e-tester
description: Run autonomous Android E2E tests on example app via ADB MCP with Logcat verification.
---

# Android End-to-End Testing (`android-e2e-tester`)

Execute autonomous end-to-end testing on physical Android devices using ADB MCP tools and real-time Logcat cross-checking.

## Workflow

1. **Pre-flight Checks**:
   - Verify device connection (`adb devices`).
   - Check [packages/spotify_sdk/example/.env](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk/example/.env).
   - Confirm Spotify app (`com.spotify.music`) is installed and logged in.

2. **Reset Log Buffer**: Clear old logs with `adb logcat -c`.

3. **App Execution**: Launch app via `flutter run -d <device_id>` inside `packages/spotify_sdk/example`.

4. **UI & SSO Automation**:
   - Inspect UI hierarchy (`get_ui_tree` / `dump_ui_hierarchy`).
   - Tap "Connect to Spotify".
   - Authorize Spotify OAuth dialog when presented ("Agree").
   - Test playback controls (Play, Pause, Skip Next, Skip Previous).

5. **Logcat Cross-Checking**:
   - Query logcat for `SpotifySdk` tags and `PlatformException`.
   - Validate UI widget states against native log entries.

