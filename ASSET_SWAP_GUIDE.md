# V0.5 Asset Swap Contract

Every placeholder in `res://assets/` is a real production slot.

## Rule
Final artwork should replace the corresponding placeholder at the same logical slot.
Prefer retaining:
- canvas dimensions
- transparency behavior
- pivot / centered composition
- safe margins
- file role

If filenames change, update only `data/asset_manifest.json` and the scene resource reference.
Gameplay code must not need redesign for an art replacement.

## Current production slots
- 1080×1920 region background
- 640×640 transparent monster sprites
- 512×512 transparent hero portraits
- 512×512 transparent village buildings
- 800×800 transparent wheel base
- 180×180 transparent wheel pointer
- 128×128 transparent UI icons
- scalable panel/button placeholders

## Animation-ready convention
Future animated assets use:
`<asset>_idle_01.png`
`<asset>_hit_01.png`
`<asset>_attack_01.png`
`<asset>_death_01.png`

The static placeholder is the fallback frame until animation assets exist.
