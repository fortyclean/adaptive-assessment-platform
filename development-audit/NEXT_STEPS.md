# Next steps

1. Verify and push the `1.0.110` XLSX import fixture test, then verify GitHub Actions.
2. Reconnect or re-authorize the Android phone, then install/launch the latest debug APK.
3. Accept Android SDK licenses to remove the remaining Android toolchain warning.
4. Add API-level route coverage for `.xlsx` question import uploads.
5. Plan a signed release APK/AAB only after the next release gate passes.

## Recommended next implementation batch

Small, safe batch:

- Add API-level tests for `.xlsx` question import using a generated workbook fixture.
- Run full Flutter test suite and backend tests before any Beta APK distribution.
