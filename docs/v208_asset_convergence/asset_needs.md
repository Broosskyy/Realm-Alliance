# V2.08 Asset Needs

**Post Runtime QA (PASS):** Grünhain M001–M014 + B001–B003 + BG001 verified in runtime.  
Only genuinely missing production assets listed below.

| ID | Type | Region | Gameplay Role | Required States | Current Placeholder | Priority |
|---|---|---|---|---|---|---|
| frostmark_bg | background | frostmark | Combat/home backdrop | 1080×1920 static | none | P1 — after region content |
| frostmark_region_icon | icon | frostmark | Region map/selection | 256×256 | text label only | P2 |
| greenvale_region_icon | icon | greenvale | Region map/selection | 256×256 | text label only | P2 |
| lane_map_greenvale | map | greenvale | Lane Battle mode | production map | `lane_map_greenvale_placeholder.png` | P2 |
| td_map_greenvale | map | greenvale | Tower Defense mode | production map | `td_map_greenvale_placeholder.png` | P2 |
| frostmark_encounters | monster set | frostmark | TAP rotation | 4-state sheets each | none | P1 — blocked on art |

**Note:** M001–M014 + B001–B003 production state crops exist and are runtime-bound. Original 2×2 source sheets are documented in `V1_59_ASSET_DECISIONS.md` but not shipped in-repo.
