# V1.83 CHANGELOG — Raid Tiers / PvP Seasons / Defense Team / Reward Ledger

- Added RewardLedgerService with server-owned claim entries and claim-id idempotency.
- Reward claims no longer rely on client-side claimed state; server revision decides the committed ledger state.
- Added DefenseTeamService with local team candidate, publish flow and server defense snapshot ID/revision.
- Guild Boss upgraded to guild-raid-v2 with server-owned phase data, contribution tiers and reward tiers.
- Guild Boss attacks continue to require concurrency token + published loadout snapshot.
- Async PvP upgraded to pvp-season-v2.
- PvP matchmaking now also requires a published server defense-team snapshot.
- Added PvP league snapshot, season progress, promotion/demotion state and dedicated defense-team routes.
- Save schema advanced to v29.
- No fake raid tiers, league entries, rewards or defense opponents.
