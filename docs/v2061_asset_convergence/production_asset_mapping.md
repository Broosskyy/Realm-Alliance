# V2.06.1 Production Asset Mapping

Milestone: visual production rebind on approved V2.06.0 base. No gameplay drift.

| Runtime Slot | Legacy Asset | V2.06.1 Production Asset | Role ID | Status |
|---|---|---|---|---|
| HUD Gold Pill `GoldPillP0` | `UI015_resource_gold_pill.png` | `resource_bars_06.png` | `ui.hud.resource.gold` | **REBOUND** |
| HUD Spin Pill `SpinPillP0` | `UI016_resource_spin_pill.png` | `resource_bars_03.png` | `ui.hud.resource.spin` | **REBOUND** |
| HUD Shield Pill `ShieldPillP0` | `UI017_resource_shield_pill.png` | `resource_bars_08.png` | `ui.hud.resource.shield` | **REBOUND** |
| Hero Knight portrait slot | V151 mastery icon only | `hero_knight_portrait_placeholder.png` | `hero.knight.portrait` | **PLACEHOLDER** |
| Hero Archer portrait slot | V151 mastery icon only | `hero_archer_portrait_placeholder.png` | `hero.archer.portrait` | **PLACEHOLDER** |
| Hero Mage portrait slot | V151 mastery icon only | `hero_mage_portrait_placeholder.png` | `hero.mage.portrait` | **PLACEHOLDER** |
| Hero mastery badge | — | `V151_001–003` | `hero.*.mastery` | **PRODUCTION** (badge on card) |
| Monster / Boss / Nav / SPIN / Village | — | unchanged from V2.06 | — | **KEEP** |

## Implementation

- `ProductionAssetConvergenceV2061.gd` applies HUD textures via `ProductionUiBinder.apply_texture()` at runtime (scene ext_resources UI015–017 are overridden, not active in play).
- Hero cards receive `HeroPortraitV2061` TextureRect children + `HeroMasteryBadgeV2061` for interim mastery icons.
- Label anchors on HUD pills adjusted to `0.38–0.90` for v4 bar icon housing.

## Remaining placeholders

| Asset Need | Slot | Notes |
|---|---|---|
| `HERO_KNIGHT_PORTRAIT` | Collection / deploy | Placeholder bound, labeled K |
| `HERO_ARCHER_PORTRAIT` | Collection | Placeholder bound, labeled A |
| `HERO_MAGE_PORTRAIT` | Collection | Placeholder bound, labeled M |

No new placeholder art generated in V2.06.1.
