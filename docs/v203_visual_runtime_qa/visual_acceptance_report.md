# V2.03.0 Visual Runtime Acceptance

**Status:** PASS
**Mode:** smoke
**Elapsed:** 17.1s (baseline full ~57s)

## PASS/FAIL logic

- TAP determinism: 3/3 required
- Regression: `{"boot":true,"navigation":true,"save":true,"spin":true,"tap":true}`
- Visual screenshots + viewport matrix must PASS
- No manual PASS overrides

## Screenshots

- `01_main_1080x2340.png` — Smoke main gameplay — PASS
- `02_tap_hit_1080x2340.png` — Smoke TAP hit — PASS
- `04_spin_open_1080x2340.png` — Smoke SPIN open — PASS

## State evidence

`state_evidence.json` — 3 entries linked to captures