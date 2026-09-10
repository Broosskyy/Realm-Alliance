# V1.82 Online Economy / Loadout / PvP Contracts

## Inventory & Entitlements
Inventory quantities and non-consumable entitlements are authoritative server snapshots. The client catalog remains presentation/config only. A store callback cannot grant Gold, Gems, Spins, cosmetics or no-ads. A store receipt/token must be validated by the server first.

## Loadout Snapshots
The client can build a candidate loadout from current hero/equipment/progression state. Online competitive/co-op systems use only a server-published snapshot ID and revision. This creates a stable reference for async combat resolution.

## Guild Boss Concurrency
Every boss snapshot carries a boss revision and concurrency token. Attacks include both values plus a unique request ID. Stale or duplicate attacks are expected to be rejected/idempotently resolved server-side. The client rejects mismatched response request IDs.

## Async PvP Matchmaking
The server owns:
- matchmaking ticket
- chosen opponents
- opponent defense snapshot
- rating/league
- season state
- battle result
- reward claim

The client submits an attacker loadout snapshot reference and selected opponent reference only.
