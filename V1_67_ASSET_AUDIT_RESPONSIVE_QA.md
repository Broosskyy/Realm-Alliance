# V1.67 — Asset Audit & Responsive Runtime Polish

## Placeholder audit
Total placeholder-named physical files: 119

- CONFIRMED_MISSING: 14
- SUPERSEDED: 47
- OBSOLETE: 3
- REVIEW: 55

This audit is deliberately conservative. SUPERSEDED and OBSOLETE files are not automatically deleted until a real runtime/device pass confirms that no legacy path still depends on them.

## Confirmed production queue
- `lane_map_greenvale` — Recraft — Portrait/vertical Greenvale lane battle map, no baked UI.
- `unit_archer` — Image generation — Readable battle unit matching hero/monster casual fantasy style.
- `unit_knight` — Image generation — Readable battle unit matching hero/monster casual fantasy style.
- `td_enemy_runner` — Image generation — Small fast enemy, distinct silhouette.
- `td_map_greenvale` — Recraft — Greenvale tower-defense map with clear path/placement areas, no UI.
- `tower_archer` — Recraft — Freestanding archer tower, same village/world material language.
- `tower_mage` — Recraft — Freestanding mage tower, same village/world material language.
- `entry_splash` — Recraft — REALM ALLIANCE branded splash background.
- `entry_welcome` — Recraft — Welcome/login background derived from brand/world direction.
- `realm_emblem` — Recraft — Canonical REALM emblem, transparent.
- `hero_archer_portrait` — Image generation — Niva/archer portrait, transparent.
- `hero_knight_portrait` — Image generation — Brom/knight portrait, transparent.
- `hero_mage_portrait` — Image generation — Ember/mage portrait, transparent.
- `village_ambient_trees` — Recraft — Transparent modular Greenvale tree/vegetation cluster.

## Responsive runtime pass
- Global button minimum: 78 px.
- Primary actions: 96 px.
- Body labels: minimum 18 px.
- Long labels wrap instead of clipping where safe.
- ScrollContainers are vertical-auto and horizontal-disabled.
- Main overlay widths are constrained to the actual viewport.
- Compact-device policy activates below 390 px width or 760 px height.
- Bottom navigation is normalized for TAP / SPIN / DORF / MODI.
- Responsive pass reruns on viewport-size changes.

## Remaining limitation
Godot is not installed in this environment. This is static/source QA; final overlap and safe-area approval still requires a real device/runtime screenshot.
