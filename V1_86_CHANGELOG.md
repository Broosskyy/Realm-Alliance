# V1.86 CHANGELOG — Chat / Presence / Party / Inbox / Deep Links / Cross-device Sync

- Added server-moderated guild/party/direct chat contracts.
- Added server-owned presence snapshots and own-presence publishing seam.
- Added PartyLobbyService for co-op party create/invite/join/leave/ready flows.
- Added ServerInboxService with revision + sync cursor for cross-device read/ack state.
- Added InviteDeepLinkService with local scheme/target allowlist and mandatory server token resolution.
- Extended PushNotificationService with cross-device notification preference sync.
- Reward-bearing inbox/push messages may only reference RewardLedger claim IDs; they never grant rewards directly.
- Blocked-player snapshots filter chat/presence presentation without inventing server moderation outcomes.
- No additional navigation or player controls added; Master V2.2 principle “MEHR CONTENT, NICHT MEHR BEDIENUNG” remains intact.
- Save schema advanced to v32.
