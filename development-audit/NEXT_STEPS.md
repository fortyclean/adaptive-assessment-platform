# Next steps

1. Continue backend lint warning cleanup in small route/service batches.
2. Accept Android SDK licenses to remove the remaining Android toolchain warning.
3. Plan a signed release APK/AAB only after the next release gate passes.

## Recommended next implementation batch

Small, safe batch:

- Remove non-null assertion warnings from one backend route at a time with tests.
- Keep warning-count reductions small and verified to avoid behavior regressions.
