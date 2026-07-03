# Performance report

## Measured in this cycle

| Metric | Result |
|---|---:|
| Release APK arm64 size | 28.3 MB |
| Release AAB arm64 size | 28.0 MB |
| Backend test performance suite | Passed; existing suite logs P99 next-question time below SLA |
| Debug APK build time | 211.4 seconds |
| Release APK arm64 build time | 263.1 seconds |
| Release AAB arm64 build time | 17.2 seconds after release build cache |

## Not measured yet

- Cold start on physical device for 1.0.104.
- Warm start.
- Dashboard load time for each role.
- Memory/CPU on mid-range Android.
- API latency against isolated staging services.

## Next performance action

Create a repeatable device performance checklist under `qa-artifacts/release-validation/` before claiming runtime performance improvements.
