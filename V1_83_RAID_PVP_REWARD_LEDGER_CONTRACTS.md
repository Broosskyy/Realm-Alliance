# V1.83 Raid / PvP / Reward Ledger Contracts

## Reward Ledger
Every valuable online reward is represented by a server-owned claim entry. claim_id is the idempotency key. The client can request a claim, but it does not mark the reward as claimed until the server returns a committed ledger revision. Duplicate claims are expected to return the same committed server result.

## Guild Raid
The server owns raid phase, phase transitions, global HP, player/guild contribution, contribution thresholds and reward tiers. The client receives presentation-ready tier snapshots but does not decide eligibility.

## Defense Team
The player may choose a local candidate team, but asynchronous PvP uses only a server-published defense snapshot ID/revision. Matchmaking will not start without that server snapshot.

## PvP Season
The server owns league, rating, season points, promotion/demotion thresholds, season end time and season rewards. The client only displays these values and sends battle/matchmaking requests.
