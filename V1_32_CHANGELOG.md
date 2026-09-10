# REALM ALLIANCE V1.32 — Daily + Quests Vertical Slice

- Activated the existing TAGESBONUS and AUFGABEN surfaces through Quick Actions.
- HOME / SPIN / DORF remain the primary bottom navigation.
- Reworked the broken Daily claim path into a working data-driven implementation.
- Preserved the existing 7-day reward values from source and moved them into `data/daily_quests_v1_32.json`.
- Daily claim is limited to one successful claim per UTC calendar day and advances the existing seven-step reward cycle.
- Added a visible 7-day cycle indicator and current reward preview.
- Preserved the existing three starter quests and their reward values, but moved them into the same data-driven V1.32 config.
- Quest progress is persistent and claims remain one-time.
- Added the missing successful-SPIN progress hook for `spin_3`.
- Fixed the duplicated legacy Village upgrade progress increment.
- Tap-damage upgrades now also satisfy the existing “etwas verbessern” starter quest.
- Added Daily/Quest open, claim and progress presentation telemetry.
- Quest list now has an explicit completion summary.
- Save Schema remains V20; existing `daily_streak`, `last_daily_claim_unix` and `quest_system` data remain compatible.
- V1.23–V1.31 systems remain preserved.
- Current Daily card/UI art is existing integration material, not a final art lock.
- Website remains excluded.
