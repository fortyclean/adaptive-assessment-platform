# Production secrets rotation runbook

1. Create replacement values for JWT signing, refresh-token signing, encryption, MongoDB, Redis, OneSignal, and any email/storage providers.
2. Set the replacements in the production secret manager or CI/CD protected secrets; never commit them to a repository file.
3. Redeploy the backend, invalidate existing sessions when JWT secrets change, and verify `/api/v1/health` with non-sensitive diagnostics.
4. Remove `backend/.env.production` from Git tracking while preserving it only as a local deployment input. Review repository history with an authorized security owner and revoke any previously exposed credentials.
5. Run the CI secret scan, backend build/tests, Flutter analysis/tests, then complete device validation before release.
