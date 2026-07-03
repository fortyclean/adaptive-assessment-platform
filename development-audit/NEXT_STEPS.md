# Next steps

1. Push the `1.0.107` dependency cleanup after reviewing the local/device evidence, then verify GitHub Actions.
2. Replace, sandbox, or gate `xlsx` import handling before Beta because npm audit has no fix for the current package.
3. Accept Android SDK licenses to remove the remaining Android toolchain warning.
4. Plan a signed release APK/AAB only after the next release gate passes.
5. Start Phase 2 only after the Phase 1 reports are accepted.

## Recommended next implementation batch

Small, safe batch:

- Add a safe import abstraction around spreadsheet parsing or replace `xlsx`.
- Run full Flutter test suite and backend tests before any Beta APK distribution.
