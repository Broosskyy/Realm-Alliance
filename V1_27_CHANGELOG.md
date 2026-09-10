# REALM ALLIANCE V1.27 — Events + Rankings + Realm Chest

Master V2.0 meta vertical slice.

- Added one compact META quick action; primary HOME / SPIN / DORF navigation remains unchanged.
- Added Grünhain-Jagd event: defeat 3 Grünhain bosses, then claim a configured reward.
- Added persistent boss-defeat meta progression.
- Added local/demo ranking presentation for the vertical slice. It clearly remains a local placeholder until backend/social services are implemented later.
- Added Realm Keys and Realm Chest loop.
- Boss defeats and completed Realm Journey laps grant configured Realm Keys.
- Realm Chest requires configured keys, consumes them transactionally and grants configured Gold/Spins.
- Event claim and Realm Chest opening save immediately to prevent duplicate reward claims after relaunch.
- Meta state persists as optional Save Schema V20 data.
- V1.23 SPIN, V1.24 Village, V1.25 Combat and V1.26 Journey remain preserved.
- Puzzle, Tower Defense and Lane Battle remain outside this pass and follow next.
- Website remains excluded.
