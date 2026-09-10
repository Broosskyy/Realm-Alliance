# V1.81 CHANGELOG — Remote SPIN / Combat / Guild Boss / Async PvP

- REALM SPIN now has a true online branch: online mode sends a server request and performs no local RNG or reward booking.
- Remote spin results require request correlation, revision, server time, reel stops and authoritative economy snapshot.
- MainGame waits for server-confirmed spin results before reel presentation and progression hooks.
- Monster defeat now has a true online branch: client may predict damage, but reward/next-monster result waits for server confirmation.
- Remote combat results apply authoritative economy/progression snapshots before presentation.
- Added RemoteGameplayService for server-confirmed SPIN and combat result handling.
- Added GuildBossService with snapshot/attack/reward-claim contracts.
- Added AsyncPvpService with opponent discovery, attack, history and season reward contracts.
- Added response-router routes for remote gameplay, guild boss and async PvP.
- Save schema advanced to v27.
- No fake multiplayer participants, boss state or PvP outcomes.
