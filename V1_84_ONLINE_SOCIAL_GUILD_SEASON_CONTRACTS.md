# V1.84 Online Social / Guild / Season Contracts

## Guild Governance
Roles and permissions are server snapshots. Promote, demote, kick and leadership transfer are server-authorized actions. Client permission checks are presentation/UI gates only.

## Guild Tasks & Donations
Task progress, guild resource pools and contribution results are server-owned. Donations are transactional requests and should eventually use the same economy ledger/transaction infrastructure as other valuable actions.

## Activity & Notifications
The server owns event ordering and notification read state. The client renders sanitized entries only and does not synthesize friends, guild events, ranking changes or rewards.

## PvP Season Settlement
Final league, rank, rating and reward eligibility are calculated server-side. settlement_id identifies the season settlement. The final reward claim uses the central reward ledger and claim_id idempotency.
