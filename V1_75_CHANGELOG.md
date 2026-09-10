# V1.75 CHANGELOG — Master V2.2 / Online Authority Foundation

- Master concept advanced to V2.2 with online/multiplayer authority rules.
- Added OnlineAuthorityService, ServerClockService and OnlineSessionState.
- Save schema advanced to v21 with authority/clock metadata.
- Daily and Village time paths use ServerClockService.
- Monster defeat/reward, Event reward and Realm Chest now emit authority-ready request/result metadata.
- Purchases now create an authority intent and remain blocked without real store/server verification.
- Added migration matrix for Economy, SPIN, Sync, Guilds, Coop and PvP.
- No fake backend, fake multiplayer players or new controls.
