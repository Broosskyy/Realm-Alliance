# REALM ALLIANCE V1.33 — Region Progression Foundation

- Continued from V1.32.
- Activated no invented region gameplay. Existing `data/regions.json` remains authoritative.
- Existing region contract confirmed: Grünhain unlock level 1; Frostmark unlock level 20.
- Added `RegionProgressionSystem.gd` as a data-driven region/unlock reader.
- Added compact HOME region progression showing progress from Grünhain toward Frostmark.
- At Account Lv.20 Frostmark is marked unlocked, but no fake Frostmark encounters, village, backgrounds or economy are introduced.
- Added `region_unlocked` telemetry at the existing Lv.20 boundary.
- Primary navigation remains HOME / SPIN / DORF.
- Save Schema remains V20; region unlock is derived from existing account level and needs no duplicate persistent state.
- V1.23–V1.32 gameplay blocks remain preserved.
- Website remains excluded.
