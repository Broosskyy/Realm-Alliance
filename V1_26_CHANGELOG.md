# REALM ALLIANCE V1.26 — DICE + Realm Journey Grünhain + Treasure Portal

Master V2.0 production block.

- Added a lean combined `REISE` surface rather than expanding the primary bottom navigation.
- Primary navigation stays HOME / SPIN / DORF; legacy visible `RAD` wording is removed.
- Added data-driven 12-node Grünhain Realm Journey vertical slice.
- Added DICE rolls with 1–6 movement, limited Dice inventory and node rewards.
- Initial Dice inventory is 3, capped at 5 in the prototype config.
- Grünhain bosses grant one Dice charge while the V1.26 feature is active.
- Completing a Journey lap grants a Treasure Portal charge.
- Treasure Portal consumes one charge and grants its configured reward.
- DICE/Journey/Portal progress persists through existing Save Schema V20 as optional save data.
- Added `dice_result`, `journey_open` and `treasure_portal_open` analytics.
- Reduced Motion preserves result logic and shortens presentation only.
- V1.23 SPIN, V1.24 Village and V1.25 Combat remain preserved.
- Events, Rankings and Realm Chest remain disabled for V1.27.
- Website remains excluded.
