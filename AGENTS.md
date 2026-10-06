# Agent Guidelines for `spotify_sdk`

Multi-platform Flutter plugin bridging native Spotify SDKs (Android, iOS, Web). Keep platform implementations synchronized, clean, and robust.

---

## 1. Architectural Intent & Standards

- **Coding Standards**: See [CODING_STANDARDS.md](CODING_STANDARDS.md) for bridge patterns, model generation, error handling, and naming conventions.
- **Central Constants**: All method channels and keys reside in [packages/spotify_sdk_platform_interface/lib/platform_channels.dart](packages/spotify_sdk_platform_interface/lib/platform_channels.dart), mirrored natively in `SpotifySdkConstants.kt` (Android) and `SpotifySdkConstants.swift` (iOS).
- **Public API**: Consolidated in [packages/spotify_sdk/lib/spotify_sdk.dart](packages/spotify_sdk/lib/spotify_sdk.dart).

---

## 2. Platform Scopes

Consult scoped rule files when touching platform-specific directories:
* **Android**: See [.agents/rules/android.md](.agents/rules/android.md)
* **iOS**: See [.agents/rules/ios.md](.agents/rules/ios.md)
* **Web**: See [.agents/rules/web.md](.agents/rules/web.md)
* **E2E Testing**: See [.agents/rules/e2e_testing.md](.agents/rules/e2e_testing.md)

---

## 3. Verification Workflow

1. **Static Analysis**: `melos run analyze`
2. **Formatting**: `melos run format`
3. **Tests**: `melos run test:all`
4. **Code Generation**: `melos run generate:all`
5. **Manual Verification**: Run companion demo app in [example/](packages/spotify_sdk/example)

---

## Agent Skills

### Issue Tracker
GitHub issues house tasks and specs for this repository. See [docs/agents/issue-tracker.md](docs/agents/issue-tracker.md).

### Triage Labels
Canonical five-role triage vocabulary. See [docs/agents/triage-labels.md](docs/agents/triage-labels.md).

### Domain Docs
Single-context layout with [GLOSSARY.md](GLOSSARY.md) and [docs/adr/](docs/adr/) at repo root. See [docs/agents/domain.md](docs/agents/domain.md).
