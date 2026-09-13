# V2.06.0 Visual Runtime Acceptance

**Status:** PASS
**Mode:** full
**Elapsed:** 89.7s (baseline full ~57s)

## PASS/FAIL logic

- TAP determinism: 3/3 required
- Regression: `{"boot":true,"navigation":true,"save":true,"spin":true,"tap":true}`
- Visual screenshots + viewport matrix must PASS
- No manual PASS overrides

## Screenshots

- `01_main_1080x2340.png` — Main gameplay after boot — PASS
- `34_hud_resource_bars_1080x2340.png` — HUD v4 resource bars — PASS
- `35_hud_gold_bar_1080x2340.png` — Gold resource bar close — PASS
- `36_hud_spin_shield_bars_1080x2340.png` — Spin and shield resource bars — PASS
- `02_tap_hit_1080x2340.png` — After TAP hit — PASS
- `02b_crit_hit_1080x2340.png` — Critical hit — PASS
- `03_defeat_reward_1080x2340.png` — Defeat/reward state — PASS
- `04_upgrade_open_1080x2340.png` — Upgrade panel visible — PASS
- `05_upgrade_bought_1080x2340.png` — After TAP upgrade — PASS
- `28_hero_collection_locked_1080x2340.png` — Hero collection locked — PASS
- `29_hero_unlock_1080x2340.png` — Hero unlock — PASS
- `37_hero_detail_1080x2340.png` — Hero detail selected — PASS
- `30_hero_deployed_1080x2340.png` — Hero deployed — PASS
- `31_hero_auto_attack_1080x2340.png` — Hero auto attack — PASS
- `32_combined_combat_1080x2340.png` — Combined combat — PASS
- `33_hero_level_up_1080x2340.png` — Hero level up — PASS
- `20_quest_initial_1080x2340.png` — Quest initial — PASS
- `21_quest_complete_1080x2340.png` — Quest complete — PASS
- `22_quest_reward_1080x2340.png` — Quest reward — PASS
- `23_daily_screen_1080x2340.png` — Daily screen — PASS
- `24_daily_complete_1080x2340.png` — Daily complete — PASS
- `12_boss_ready_1080x2340.png` — Boss ready — PASS
- `13_boss_intro_1080x2340.png` — Boss intro — PASS
- `14_boss_combat_1080x2340.png` — Boss combat — PASS
- `14b_boss_failure_1080x2340.png` — Boss failure — PASS
- `14c_boss_retry_1080x2340.png` — Boss retry — PASS
- `15_boss_victory_1080x2340.png` — Boss victory — PASS
- `16_boss_reward_1080x2340.png` — Boss reward — PASS
- `17_stage_progress_1080x2340.png` — Stage progression — PASS
- `25_chest_acquired_1080x2340.png` — Chest acquired — PASS
- `26_chest_opening_1080x2340.png` — Chest opening — PASS
- `27_chest_reward_1080x2340.png` — Chest reward — PASS
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

`state_evidence.json` — 44 entries linked to captures