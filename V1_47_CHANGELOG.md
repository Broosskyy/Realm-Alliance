# REALM ALLIANCE V1.47 — Realm Journey Progression V2

- Rotated production back into a major gameplay pillar after the Halloween/LiveOps block.
- Expanded Realm Journey without replacing the established deterministic 12-node Grünhain board.
- Added data-driven node profiles: Gold paths, Spin shrines, shrine/encounter/cache/gateway identity.
- Added Journey Mastery levels 1–5 with XP from rolls, completed laps and Treasure Portal opens.
- Added claimable mastery rewards; older unclaimed mastery rewards cannot be skipped when the player advances.
- Added Relikt-Splitter earned from completed laps.
- Added Journey Cache consuming 3 Relikt-Splitter with configurable Gold/Spin reward.
- Journey progression is committed inside the authoritative roll/portal transaction before SaveGame persists.
- Journey screen now shows current node identity, Mastery XP/progress bar, mastery reward CTA and Journey Cache.
- Global Progression Hub now includes Journey Mastery and Relikt-Splitter.
- Added exactly 8 large 768×768 transparent, isolated and replaceable Journey placeholder assets.
- Added explicit V1.47 asset swap map.
- Existing board reward economy and deterministic roll result contract are preserved.
- Save Schema remains V20.
