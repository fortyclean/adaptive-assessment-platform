# Changes made in this cycle

## Code/config changes

- Bumped local mobile version to `1.0.104+104`.
- Bumped local backend package version to `1.0.104`.
- Added `1.0.104` changelog entry for parent portal stabilization.
- Updated AppVersion tests to match `1.0.104`.
- Flutter automatically added Gradle compatibility flags:
  - `android.builtInKotlin=false`
  - `android.newDsl=false`

## Artifacts generated

- `release-artifacts/adaptive-mastery-v1.0.104-arm64.apk`
- `release-artifacts/adaptive-mastery-v1.0.104-arm64.aab`
- `development-audit/` reports

## Release workflow hardening

- Removed demo credentials and mojibake text from GitHub release notes.
- Added `scripts/verify-release-notes-safe.mjs` to block demo passwords or demo-login sections from release workflow text.
- Added the release-notes safety check to the CI `secrets` job.
- Aligned GitHub Actions Flutter setup from 3.35.7 to 3.44.4 to match the locally verified toolchain.

## Not done

- No GitHub push.
- No GitHub release.
- No production deployment.
- No production secret values added or printed.
