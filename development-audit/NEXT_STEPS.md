# Next steps

1. Commit version `1.0.104`, release-note hardening, and Flutter CI pin alignment only after reviewing this audit output.
2. Push only after explicit approval, then verify GitHub Actions.
3. Re-run physical Android install/smoke for `1.0.104`.
4. Triage `npm audit` dependency findings without using forced breaking upgrades.
5. Re-run CI after pushing the `1.0.105` toolchain policy update.
6. Start Phase 2 only after the Phase 1 reports are accepted.

## Recommended next implementation batch

Small, safe batch:

- Add a short Node/toolchain policy note to the audit/developer documentation.
- Run secret scan, release-note scan, Flutter analyze/test, and CI after approval to push.
