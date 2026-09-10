# V1.19 RUNTIME BOOT QA

For the first real Godot run:
- Editor startup must reach MainGame without parser/autoload errors.
- Debug panel should show `Boot PASS (0)` after initialization.
- Any Boot FAIL must be treated as a stop condition; do not continue to P1.
- Confirm starting economy is 300 Gold / 5 Spins on a fresh save.
- Confirm release export does not expose the TEST panel.
- Confirm Home / Rad / Dorf remain the only visible P0 navigation.
- Then execute the V1.17 P0 RC device runbook and V1.18 engine/export smoke runbook.

V1.19 diagnostics are observational only; they must not mutate rewards, progression, save data or balance.
