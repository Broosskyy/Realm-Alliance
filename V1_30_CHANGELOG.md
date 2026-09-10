# REALM ALLIANCE V1.30 — Grünhain Lane Battle Vertical Slice

- Activated the existing two-lane battle scene as a dedicated V1.30 gameplay slice.
- Reused the established LaneAttackSystem/View_LaneAttack instead of creating a duplicate battle implementation.
- Added a compact LANE BATTLE Quick Action; HOME / SPIN / DORF remain the primary navigation.
- Battle duration, energy, unit cost, unit power, enemy pressure and rewards are now data-driven through `data/lane_battle_v1_30.json`.
- Removed the hard runtime dependency on Heroes for this lean slice. V1.30 units use configured base power; deeper Hero integration comes later.
- Player deploys units independently to left or right lane, consuming energy.
- Energy regenerates continuously; lane pressure and enemy pressure are deterministic.
- Win/loss is resolved from enemy/player HP and remaining pressure at timeout.
- Mid-battle state persists: active flag, timer, energy, HP, lane power and lane push.
- Reward booking happens only once on a winning finish and is immediately saved.
- Existing legacy `deploy_hero()` remains as a compatibility alias to `deploy_unit()`.
- Reduced Motion changes result-screen delay only, never battle math.
- V1.23–V1.29 systems remain preserved.
- Current lane map/unit art is existing integration material and is not claimed as final production art.
- Website remains excluded.
