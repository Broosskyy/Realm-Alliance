# REALM ALLIANCE V0.4 — MASTERKONZEPT ALIGNMENT

This source version follows the latest master-concept product rules.

## Binding UX contracts
- one dominant action per screen
- portrait/mobile-first
- large touch targets
- no RPG jargon required
- no inventory-management layer
- no deckbuilding layer
- heroes add visible progression, not menu complexity
- depth should come from content and progression, not from many new controls

## Hero V0.4 player-facing model
Each hero exposes only:
1. Name
2. Level
3. Strength
4. Upgrade cost
5. Locked/unlocked state

Internally the system is data-driven and can later support more depth,
but V0.4 deliberately hides unnecessary stats.

## Starting hero roster
- Ritter: unlock Account Lv. 5
- Bogenschützin: unlock Account Lv. 8
- Magier: unlock Account Lv. 12

## Auto combat
Unlocked heroes automatically deal combined damage once per second.
This preserves Tap as an understandable active action while adding idle progression.

## Not included by design
- gear inventory grids
- rarity currencies
- skill trees
- duplicate shards
- hero positioning
- complex team management
- dozens of visible stats

These may only be added later if they can remain understandable for the broad target audience.
