# REALM ALLIANCE V1.91 — Gameplay Feel & Production VFX Pass

## Scope
V1.91 deepens the V1.90 production assets in live presentation. It does not change gameplay authority, reward odds, economy values or online contracts.

## TAP
- Production hit VFX is now layered on every active tap alongside the existing hit-state sprite, recoil/punch and dynamic damage number.
- Production monster-defeat VFX is layered on defeated monsters before reward presentation.
- Reduced-motion mode keeps concise static feedback.

## REALM SPIN
- Production reel-motion overlay starts with the 3-reel sequence.
- Every reel stop gets its own production stop burst.
- Confirmed outcomes get a win burst; special outcomes additionally get the jackpot effect.
- Existing deterministic reel-stop/result authority remains unchanged.

## Tower Defense
- Successful tower hits now present a deterministic visual tower family cycle (Archer/Mage/Cannon/Nature) using the new projectile + impact assets.
- Projectiles are presentation-only and travel from the TD action area toward the enemy marker.
- Damage and wave resolution remain entirely in TowerDefenseSystem.

## Grünhain World Composition
- Adds five lightweight production decoration props around the village/world view: lantern, signpost, stump, tool crates and mushrooms.
- Decoration ignores input and does not alter village progression/state.

## Registry / Versioning
- Runtime art bindings promoted to `runtime_art_bindings_v191.json`.
- Asset/screen contract snapshots added for V1.91.
- Build bumped to Source 1.91 / Build #91.
