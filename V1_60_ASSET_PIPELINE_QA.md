# V1.60 Asset Pipeline QA

- Master concept lock: V2.1.
- Physical assets indexed: 593.
- Atlas regions indexed: 140.
- Exact duplicate groups: 11.
- Placeholder-named files: 119.
- Placeholder files already resolved by byte-identical production aliases: 5.
- Confirmed immediate new art gaps: 14.
- Generic UI regeneration: blocked by production policy; reuse V4/new atlases first.
- Duplicate handling is non-destructive: canonical + aliases, no deletion.
- Labels remain runtime-owned; no pipeline-generated baked text.
- Screen contracts only auto-bind high/explicitly permitted medium confidence roles.
- Village goldmine remains medium-confidence review, not silently promoted to high.
- Monster resolver enforces Idle / Attack / Hit / Defeated with idle fallback.

## Expected workflow
1. Drop/export new asset into its category folder or production atlas.
2. Godot Editor plugin rescans on project filesystem change, or run `tools/run_asset_pipeline.*`.
3. Generated index identifies category, exact aliases and placeholder resolution.
4. Semantic registry exposes stable roles to screens.
5. Screen binder applies sizing/styling rules.
6. Missing report lists only assets that still need production/review.
