# Environment matrix

| Environment | Current state | Risk |
|---|---|---|
| Development | Local Flutter/backend tests pass; Docker configs exist | Local compose contains placeholder credentials |
| Test | Backend has MongoDB/Redis test compose | Not run in this cycle |
| Staging/Beta | Not provisioned in this cycle | Required before OneSignal/Sentry live validation |
| Production | Not configured or deployed in this cycle | Must remain separate and secret-driven |

## Current configuration mechanisms

- Flutter uses `--dart-define` based configuration for values such as environment/API/integrations.
- Backend uses env files and environment variables.
- CI uses GitHub Actions with pinned Node/Flutter versions.

## Required later

- Single `APP_ENV=development|staging|production` policy across mobile/backend.
- Production guard against demo accounts.
- Staging/Beta banner and separate backend/database/cache.
