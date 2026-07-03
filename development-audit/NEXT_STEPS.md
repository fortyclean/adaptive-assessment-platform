# Next steps

1. Push the `1.0.108` spreadsheet-import hardening, then verify GitHub Actions.
2. Accept Android SDK licenses to remove the remaining Android toolchain warning.
3. Add API-level tests for generated `.xlsx` question import fixtures.
4. Plan a signed release APK/AAB only after the next release gate passes.
5. Start Phase 2 only after the Phase 1 reports are accepted.

## Recommended next implementation batch

Small, safe batch:

- Add API-level tests for `.xlsx` question import using a generated workbook fixture.
- Run full Flutter test suite and backend tests before any Beta APK distribution.
