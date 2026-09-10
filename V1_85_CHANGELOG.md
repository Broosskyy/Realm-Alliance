# V1.85 CHANGELOG — Guild Discovery / Moderation / Push / Season Reset / Donation Ledger

- Added GuildDiscoveryService for guild search, applications and invites.
- Added SocialModerationService for server-owned block lists and report submission.
- Added PushNotificationService for Android/iOS registration and server-owned notification preferences.
- Added SeasonResetService for server-owned PvP season reset snapshots and reset acknowledgement.
- Season reset rewards are represented only by RewardLedger claim IDs.
- Guild donations now track request-id idempotency, server receipt IDs and optional RewardLedger claim IDs.
- Added donation receipt recovery route for reconciliation after timeout/reconnect.
- Added response routing for all V1.85 online service contracts.
- Save schema advanced to v31.
- No fake guild search results, moderation outcomes or push rewards are generated.
