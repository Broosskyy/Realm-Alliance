# REALM ALLIANCE V1.53 — Village / BUILD V2

- Deepened the existing Dorf/BUILD pillar instead of adding a new mode.
- Added Village Growth / prosperity progression levels 1–5 across building upgrades, mine activity, forge crafting and temple blessing.
- Added Town Hall dependency: non-Town-Hall building target level may not exceed current Town Hall level.
- Added real Forge functionality: up to six permanent forge crafts, capped by Forge building level, using existing Gold and increasing Tap damage.
- Added real Luck Temple functionality: one UTC-daily blessing using the existing level-based bonus-spin value.
- Existing Goldmine production remains offline/time based; first claim per UTC day now also contributes Village Growth.
- Added Village Growth claim rewards using existing Gold, Spins and Realm Keys; no new spendable currency.
- Added `village-upgrade-result-v1` with unique upgrade_id and pending presentation for resume-safe committed building upgrades.
- Building upgrade presentation acknowledges the pending transaction only after visible feedback.
- Added boot restore for an unpresented committed Village upgrade.
- AFK presentation waits behind pending Spin/Journey/Puzzle/Defense/Lane/Village results.
- Village UI now includes Growth XP/bar, Forge action, Temple action and Growth reward CTA.
- Building cards and upgrade modal now explain Town Hall prerequisite locks instead of only showing missing Gold.
- Removed the active runtime connection of the legacy hidden TownHallButton upgrade path; compatibility node/function remains in source.
- Cross-pillar objectives count mine claims, forge crafts and temple blessings as Realm activity.
- Global Progression Overview now shows Village Growth, building levels and Forge craft depth.
- Exactly eight isolated transparent 768×768 Village V2 placeholder assets.
- Save schema remains V20.
