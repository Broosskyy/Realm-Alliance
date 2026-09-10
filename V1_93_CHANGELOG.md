# REALM ALLIANCE V1.93 — Greenvale / TAP / Reward Progression Visual Convergence

## Scope
V1.93 deepens the production-art integration introduced in V1.90–V1.92 without changing combat authority, reward grants, economy rules, save semantics, online contracts or navigation.

## Greenvale world composition
- Added `GreenvaleWorldVisualDirectorV193.gd` as a presentation-only composition pass.
- Replaces the lightweight V1.91 decor layer with a responsive eight-prop composition using existing production assets.
- Uses normalized placement plus bounded responsive scaling so decor remains inside the village/world view on different viewport widths.
- Includes inhabited-world props and nature accents rather than only trees/rocks.
- No decor node is harvestable, collidable or authoritative.

## TAP combat feel
- Added `TapCombatVisualDirectorV193.gd`.
- Normal taps use the production hit VFX with a tighter squash/punch response.
- Already-authoritative high damage can select a stronger production impact; the visual layer does not create critical hits or alter damage.
- Defeat presentation now gets a dedicated production defeat burst plus a short visual collapse/fade response.
- Existing monster idle/hit/defeat state logic remains intact.

## Rewards / progression
- Added `RewardProgressionVisualDirectorV193.gd`.
- Normal monster rewards now get a production gold celebration layer.
- Boss rewards get a stronger celebration plus a four-state production chest sequence: closed → opening → open glow → open.
- Level-up presentation uses production progression VFX.
- The level-20 Frostmark unlock presentation layers the stronger level-up effect with the production unlock vortex.
- These are presentation-only hooks; reward amounts, XP and unlock decisions remain owned by existing gameplay/authority services.

## Runtime art bindings
- Added `data/runtime_art_bindings_v193.json`.
- ProductionAssetRegistry now loads V1.93 bindings.
- Added high-confidence roles for strong TAP impact, reward celebration, major level-up/unlock VFX and all four chest states.

## Version
- Source version: 1.93
- Build: #93
- Master concept: V2.2
- Save version remains 35.
