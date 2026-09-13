# V2.04.0 Visual Runtime Acceptance

**Status:** PASS
**Mode:** full
**Elapsed:** 65.8s (baseline full ~57s)

## PASS/FAIL logic

- TAP determinism: 3/3 required
- Regression: `{"boot":true,"navigation":true,"save":true,"spin":true,"tap":true}`
- Visual screenshots + viewport matrix must PASS
- No manual PASS overrides

## Screenshots

- `01_main_1080x2340.png` — Main gameplay after boot — PASS
- `02_tap_hit_1080x2340.png` — After TAP hit — PASS
- `02b_crit_hit_1080x2340.png` — Critical hit — PASS
- `03_defeat_reward_1080x2340.png` — Defeat/reward state — PASS
- `04_upgrade_open_1080x2340.png` — Upgrade panel visible — PASS
- `05_upgrade_bought_1080x2340.png` — After TAP upgrade — PASS
- `12_boss_ready_1080x2340.png` — Boss ready — PASS
- `13_boss_intro_1080x2340.png` — Boss intro — PASS
- `14_boss_combat_1080x2340.png` — Boss combat — PASS
- `15_boss_victory_1080x2340.png` — Boss victory — PASS
- `16_boss_reward_1080x2340.png` — Boss reward — PASS
- `17_stage_progress_1080x2340.png` — Stage progression — PASS
- `06_spin_open_1080x2340.png` — SPIN open — PASS
- `07_spin_result_1080x2340.png` — SPIN result — PASS
- `08_village_1080x2340.png` — Village — PASS
- `17_afk_return_1080x2340.png` — AFK return — PASS
- `18_afk_claim_1080x2340.png` — AFK claim — PASS
- `19_main_reload_1080x2340.png` — Main after reload — PASS
- `09_modes_1080x2340.png` — MODI feature hub — PASS
- `10_overlay_1080x2340.png` — Settings overlay — PASS
- `11_return_main_1080x2340.png` — Return to main — PASS
- `01_main_1080x2400.png` — Main gameplay viewport matrix — PASS
- `01_main_1080x1920.png` — Main gameplay viewport matrix — PASS
- `01_main_1440x3200.png` — Main gameplay viewport matrix — PASS

## State evidence

`state_evidence.json` — 24 entries linked to captures