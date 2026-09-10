# REALM ALLIANCE V1.60 — Automated Asset Pipeline & Semantic UI

V1.60 turns the accumulated production-art library into a maintainable ingestion/binding pipeline instead of continuing manual one-off swaps.

## Added
- `SemanticAssetRegistry.gd`: central semantic facade over production bindings, rules, contracts and generated asset metadata.
- `AssetImportPipeline.gd`: runtime scan/report service.
- `ScreenAssetBinder.gd`: applies known semantic roles to matching screen nodes by contract.
- `UiComponentFactory.gd`: shared runtime construction rules for labels, icons and buttons.
- `MonsterAssetResolver.gd`: canonical four-state monster resolver.
- `VillageAssetResolver.gd`: canonical village mapping with confidence handling.
- `data/generated_asset_index_v160.json`: 593 physical assets + 140 atlas regions catalogued.
- exact hash duplicate canonicalization; duplicates are aliases and never automatically deleted.
- placeholder files that are byte-identical to production art are marked resolved aliases.
- `data/asset_rules_v160.json`: size, NinePatch, label and touch-target policies.
- `data/screen_asset_contracts_v160.json`: semantic screen/node contracts.
- `data/asset_confidence_v160.json`: high/medium/low/hold policy.
- `data/asset_pipeline_missing_v160.json`: confirmed remaining art gaps only.
- Godot Editor plugin `REALM Asset Pipeline` with automatic report generation and a manual “REALM: Assets neu scannen” command.
- standalone `tools/realm_asset_pipeline.py` for Cursor/PC/CI regeneration without third-party Python packages.

## Runtime integration
- `AssetRegistry.production_texture_for()` now routes through the semantic registry first.
- `MainGame` applies `ScreenAssetBinder` after responsive/copy/visual calibration and again after viewport size changes.
- legacy manual bindings remain as safe fallbacks; no speculative medium/low asset is forced live.

## Production rule
New assets are added to the appropriate production folder/atlas, the pipeline rescans, exact duplicates are aliased, semantic high-confidence matches can bind automatically, and only unresolved/medium-confidence items are reported for review.
