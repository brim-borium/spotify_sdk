---
name: example-runner
description: Explains how to run, configure, and test the spotify_sdk plugin using the companion example app. Use this skill when testing changes visually or verifying plugin integration.
---

# Example App Runner and Tester Skill for spotify_sdk

The repository includes a complete example application under the [example/](file:///Users/tobi/Projects/spotify_sdk/example) directory for manual end-to-end verification.

## When to Use
- When you want to run the plugin locally and verify functionality on an emulator, device, or web browser.
- When validating if changes to platform channels or models work correctly end-to-end.

## Setup Requirements

### 1. Environment Variables (`.env`)
The example app requires Spotify API credentials to connect.
Create a `.env` file in the root of the `example` folder ([example/.env](file:///Users/tobi/Projects/spotify_sdk/example/.env)):
```ini
CLIENT_ID=your_spotify_client_id
REDIRECT_URL=your_spotify_redirect_url
```

### 2. running the Example App
Navigate to the `example/` folder and run the Flutter application:
```bash
cd example
flutter run
```

### 3. Web Testing
To run the example app on Web specifically:
```bash
cd example
flutter run -d chrome
```

## Guidelines
- Make sure to test your code modifications on all supported platforms (iOS, Android, Web) where possible.
- Check the log console for platform-specific exceptions if connections or playbacks fail.
