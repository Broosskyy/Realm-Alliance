# V1.85 Social / LiveOps Online Contracts

## Guild discovery
Search, applications, invitations and join eligibility are server-owned. The client can search and submit actions, but cannot locally decide membership.

## Moderation
Blocks are server snapshots. Reports create server records. A report acknowledgement is never proof that another player was punished.

## Push notifications
Device registration and preferences are server-owned. Push payloads are informational only and never directly grant currency/items/rewards.

## Season reset
Season reset, final rating and next starting league/rating are server decisions. Reset acknowledgement is presentation state only. Rewards are claimed separately through RewardLedger claim IDs.

## Guild donations
Donation request_id is an idempotency key. The server returns a receipt_id and may return reward_claim_id. If a network timeout occurs, the client can query the donation receipt using the original donation request ID instead of replaying the donation blindly.
