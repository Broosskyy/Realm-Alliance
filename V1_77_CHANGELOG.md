# V1.77 CHANGELOG — Reward & Upgrade Authority Migration

- Village building upgrades now route Gold spend through EconomyAuthorityService.
- Hero level upgrades and Hero equipment upgrades now route Gold spend through authority.
- Daily Rewards now use an authority reward transaction before claim state is committed.
- Quest reward claims now use authority reward transactions.
- Hero mastery rewards now use authority reward transactions.
- Village forge spend, temple blessing and prosperity rewards now use authority transactions.
- Event rewards and Realm Chest rewards now use EconomyAuthorityService rather than direct PlayerData grants.
- Village daily day key now uses ServerClockService.
- Save schema advanced to v23.
- No new controls and no fake backend.
