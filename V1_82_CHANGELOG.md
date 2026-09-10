# V1.82 CHANGELOG — Inventory / Entitlements / Loadouts / Concurrency / Matchmaking

- Added InventoryEntitlementService with server-owned item and entitlement snapshots.
- Added store receipt validation contract; client callbacks no longer grant products directly.
- Added LoadoutSnapshotService for candidate build, fingerprint, publish and server snapshot reference.
- Guild Boss attacks now require a published loadout snapshot, concurrency token, expected boss revision and request-id correlation.
- Guild Boss responses reject mismatched attack request IDs.
- Async PvP upgraded to matchmaking v2.
- PvP now supports server matchmaking tickets, defense snapshots and season snapshots.
- PvP attacks require a matchmaking ticket, attacker loadout snapshot and opponent defense snapshot.
- PvP season/league state remains server-owned.
- Save schema advanced to v28.
- No fake inventory, entitlement, loadout, opponent or season state is introduced.
