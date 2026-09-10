# V1.78 CHANGELOG — Mode Rewards / Goldmine / Remote Sync Preparation

- Goldmine claim now routes through authority with server-clock claim metadata.
- Journey, Puzzle, Tower Defense and Lane mastery rewards route through EconomyAuthorityService.
- Journey Cache uses an authority transaction for shard spend + reward result.
- Tower Defense tech and Lane unit tech upgrades route Gold spend through authority.
- AFK reward claim routes through authority and tracks claim sequence.
- Halloween/LiveOps time now uses ServerClockService.
- Halloween main reward, event quests and event chest use authority transactions.
- Player snapshot upgraded to v2 and includes major progression domain snapshots.
- Added player-sync-request-v1 with known revision, fingerprint and pending intents.
- Added SyncReconciliationService with stale-revision rejection and server-time validation.
- Save schema advanced to v24 with reconciliation metadata.
- No fake remote response and no new player controls.
