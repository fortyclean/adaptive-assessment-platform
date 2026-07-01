# Stitch visual comparison workflow

This workflow keeps the 75 Stitch references reviewable before a new release
build. It does not bump the app version and it does not require production
credentials.

## Fixed viewport

- Primary mobile viewport: `390x844`
- Locale: Arabic
- Direction: RTL
- Theme: light

## 1. Build the reference inventory

From the repository root:

```powershell
node scripts/build-stitch-visual-inventory.mjs `
  --source "..\stitch_adaptive_assessment_platform" `
  --viewport "390x844"
```

Expected output:

- `qa-artifacts/release-validation/stitch-visual-reference-inventory.json`
- `qa-artifacts/release-validation/stitch-visual-reference-inventory.md`

The script fails if any of `_1` through `_75` is missing, or if a reference does
not include both `screen.png` and `code.html`.

## 2. Capture app screenshots

Use the same device/emulator viewport or a browser-driven Flutter target locked
to `390x844`. Save app captures as:

```text
qa-artifacts/release-validation/stitch-app-captures/screen-01.png
qa-artifacts/release-validation/stitch-app-captures/screen-02.png
...
qa-artifacts/release-validation/stitch-app-captures/screen-75.png
```

## 3. Compare and triage

For each screen:

1. Compare the app screenshot with the matching Stitch `screen.png`.
2. Classify the result as:
   - `match`
   - `acceptable-difference`
   - `needs-ui-fix`
   - `not-implemented`
3. Record the decision in the release validation notes.

## 4. Release gate

A release candidate should not be accepted until:

- all 75 Stitch references are present;
- all app screenshots are captured at the fixed viewport;
- all `needs-ui-fix` and `not-implemented` items are either fixed or explicitly
  approved as deferred by the release owner.
