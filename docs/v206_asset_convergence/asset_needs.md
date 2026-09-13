# V2.06 Production Asset Needs

Assets with **no suitable production match** after full repository audit.

## Hero Portraits (Priority: High)

| Asset ID | Purpose | Screen | Required States | Aspect | Visual Family | Current Placeholder |
|---|---|---|---|---|---|---|
| `HERO_KNIGHT_PORTRAIT` | Collection + deploy indicator | View_Heroes, Main HUD assist | idle | 1:1, min 512px | V151 mastery style / Grünhain casual | `assets/heroes/hero_knight_portrait_placeholder.png` (unbound) |
| `HERO_ARCHER_PORTRAIT` | Collection | View_Heroes | idle | 1:1 | same | `hero_archer_portrait_placeholder.png` |
| `HERO_MAGE_PORTRAIT` | Collection | View_Heroes | idle | 1:1 | same | `hero_mage_portrait_placeholder.png` |

**Notes:** Do not generate final KI heroes in-source. V151 mastery icons (`V151_001–003`) are used as interim production-bound card icons.

## HUD Resource Pills (Priority: Low)

| Asset ID | Purpose | Screen | Notes |
|---|---|---|---|
| `HUD_GOLD_PILL_V4` | Top bar gold | Main | `v4.ui.resource_bars` exists; scene still uses UI015 |
| `HUD_SPIN_PILL_V4` | Top bar spins | Main | UI016 legacy embed |
| `HUD_SHIELD_PILL_V4` | Top bar shields | Main | UI017 legacy embed |

## Quest/Daily Dedicated Art (Priority: Low — functional with atlas)

V2.05 uses production quest atlas + `quest_states` PNGs. Optional future dedicated card frames if design team wants distinct quest/daily visual tier beyond `quest_01` atlas.
