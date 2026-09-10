# V1.86 Social / Co-op / Inbox Contracts

## Chat
Guild, party and direct chat use server-created message IDs and server moderation. Client text is length-limited for UX only; backend moderation remains authoritative.

## Presence
Friend/player presence and last-seen use server snapshots/server time. Presence is informational and never used as reward/economy authority.

## Party / Co-op Lobby
Party membership, leader, ready states and valid joins are server-owned. Invite tokens never bypass server membership validation. This is the foundation for future co-op PvE without requiring realtime combat networking yet.

## Server Inbox
Inbox state is revisioned and cursor-synced across devices. Read/ack actions are server mutations. Reward messages reference RewardLedger claim IDs rather than carrying grant logic.

## Invite Deep Links
Only allowlisted `realmalliance://` targets are accepted locally, and all invite tokens are resolved server-side before navigation or join actions.

## Push Sync
Push registration remains device-specific while preferences/sync cursor can converge across devices. Push payloads are informational only.
