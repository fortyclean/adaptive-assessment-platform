# Next steps

1. Push the `1.0.109` CI lint follow-up fix, then verify GitHub Actions.
2. Reconnect or re-authorize the Android phone, then install/launch `1.0.109+109`.
3. Accept Android SDK licenses to remove the remaining Android toolchain warning.
4. Add API-level tests for generated `.xlsx` question import fixtures.
5. Plan a signed release APK/AAB only after the next release gate passes.

## Recommended next implementation batch

Small, safe batch:

- Add API-level tests for `.xlsx` question import using a generated workbook fixture.
- Run full Flutter test suite and backend tests before any Beta APK distribution.
