# REALM ALLIANCE V1.41 — Journey / Puzzle / Hero Hardening

- Continued the V1.40 transaction-safety work beyond SPIN.
- DICE / Realm Journey now emits a stable `roll_id`, stores a per-roll `roll_seed`, carries `config_version` and a `journey-result-v1` result contract.
- Dice consumption, roll resolution, node reward grant and pending presentation are committed before UI animation.
- Pending Journey presentation is saved inside the existing optional `dice_journey` Save V20 block.
- Interrupted Journey presentation can reopen without rolling again or granting the node reward twice.
- Treasure Portal now also emits a stable `portal_result_id` and config version.
- Journey configuration advanced to `v1.41-journey-02`; balance values were not changed.
- Puzzle `daily_free_attempts` now has a real UTC-day reset using a persisted day key.
- Puzzle reset does not introduce a new currency and keeps existing board/match progress behavior.
- Hero card taps now select a hero only. They no longer spend Gold or upgrade immediately.
- Added an explicit `HELD VERBESSERN` CTA for the selected hero.
- Selected hero is persisted; equipment buttons continue to operate on that explicit selection.
- Hero upgrade CTA handles affordability and level-cap state.
- Added exactly six replaceable V1.41 integration placeholder assets.
- HOME / SPIN / DORF stay the primary navigation.
- Save Schema stays V20.
- Website remains excluded.
