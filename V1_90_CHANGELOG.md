# REALM ALLIANCE V1.90 — Production Asset & VFX Integration

- Imported all 23 supplied new asset sheets into `assets/production/v190/`.
- Preserved every original source sheet and extracted 110 isolated production cells with alpha padding.
- Added high-confidence production families for Greenvale nature/world props/resources, four TD tower roles, TD enemies, chest states, progression/reward VFX, combat/TD impacts and REALM SPIN VFX.
- Added `data/v190_new_asset_manifest.json` with source-sheet provenance for every extracted cell.
- Added `runtime_art_bindings_v190.json`; replaced the TAP hit fallback with dedicated impact art and added dedicated SPIN motion/stop/win/jackpot roles.
- Added presentation-only `GameplayVfxService.gd`. It does not decide damage, rewards, odds or economy state.
- Added `ProductionAssetConvergenceV190.gd`: Greenvale ambient and TD enemy placeholder owners now receive high-confidence V1.90 production art at runtime.
- Semantic/production registries now read V1.90 rules/contracts/bindings.
- Source 1.90 / build #90. Save schema remains 35.

## Important
The supplied PNGs contain real alpha channels. Crops were made from fixed sheet cells, alpha-trimmed and padded. Runtime/device validation is still required in Godot; Godot is not installed in this build environment.
