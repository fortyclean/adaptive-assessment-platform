# Improvement plan

## Immediate P1/P2 work

1. Remove demo credentials from GitHub release notes.
2. Align Flutter version across local guidance and CI.
3. Decide whether local releases require universal APKs or arm64 APK + AAB.
4. Add/confirm documentation for Android toolchain path and license acceptance.

## Next quality batch

1. Reduce backend lint warnings in small batches.
2. Fix or document Flutter Kotlin Gradle Plugin migration warnings.
3. Add CI artifact naming for AAB in addition to APK if Beta distribution requires it.
4. Keep phase work small: one route/service or one screen/feature per batch.

## Not started in this cycle

- Environment separation implementation.
- CI rewrite.
- Security hardening beyond scan and review.
- New feature work.
- Beta/Production deployment.
