# V2.09 Phase 1 Report — Grünhain Curated Encounter Pass

**Status:** PHASE 1 FINAL ACCEPTANCE **PASS**  
**Basis:** V2.09 Phase-0 audit (17/17 production monsters)  
**Save version:** v41 unchanged  
**Runtime report:** `docs/v209_visual_runtime_qa/world_runtime_qa_report.json`  
**Domain report:** `docs/v209_domain_qa/world_domain_qa_report.json`

---

## ACCEPTANCE GATES (separated)

| Gate | Status | Evidence |
|---|---|---|
| Static / Data implementation | **PASS** | Curated catalog, stats, loot tables, legacy deprecation |
| Domain QA | **PASS** (8/8) | `V209WorldDomainQaHost.tscn` |
| Runtime QA | **PASS** (8/8 assertions) | `V209WorldRuntimeQaHost.tscn` — **55.4s** |
| Visual QA | **PASS** | 30 PNGs + pixel analysis in runtime report |
| Regression smoke | **PASS** | TAP, crit, hero, inventory, pipeline, boss, save v41 |
| Save / Reload | **PASS** | Encounter index, hero, region preserved |
| Viewport matrix | **PASS** | 4 profiles × 4 scenarios |
| APK | **NOT EXPORTED** | Per scope |

**Note:** Runtime QA requires a rendering Godot session (not `--headless`) for viewport screenshots. Domain QA remains headless-safe.

---

## ASSET COUNT (corrected)

| Scope | Count |
|---|---|
| Full Greenvale state directory | **17 monsters × 4 states = 68** state PNGs |
| Boss shield extra | **+ `B001_shield.png`** |
| **Total files in states dir** | **69** |
| First-cycle core roles (8 IDs) | **8 × 4 = 32** core state PNGs |

Do **not** describe the full directory as “68 PNG verified” — use **69** when including `B001_shield.png`.

---

## ENCOUNTER SEQUENCE (runtime verified)

Catalog: `v2.09-encounters-01` in `data/encounters_greenvale_p0_v1_4.json`

```
L1  M001 → L2 M012 → L3 M002 → L4 M003 Tough → L5 M004 → L6 M005
→ Hero unlock (account L5 @ M005 defeat)
→ L7 M012 → L8 M003 Tough → L9 M010 Elite → L10 B001 Boss
```

Runtime trace confirms **M010 before B001**, all 10 encounters, `final_monster_level: 11` after boss.

---

## HERO UNLOCK (real runtime)

Captured at **M005 / encounter 6** (not hardcoded):

| Field | Value |
|---|---|
| Account level before → after | 4 → **5** |
| XP before → after | 90 → 55 |
| Granted XP | 70 |
| Knight before → after | locked → **unlocked** |
| Available before M010 | **yes** |

`HeroSystem.sync_progression_unlocks()` required after defeat because QA suspends hero `_process`.

---

## CLASSIFICATION + HP (runtime)

At account progression during flow:

| Role | ID | Classification | Effective HP |
|---|---|---|---|
| Intro | M001 | normal | 88 |
| Small | M012 | normal | 72 |
| Tough | M003 | tough | 142 / 147 |
| Elite | M010 | elite | 211 |
| Boss | B001 | boss | 438 |

Verified: **normal < tough < elite < boss** (no double modifier application).

---

## LOOT SOURCE (runtime RewardPipeline)

| Level | Monster | Metadata source |
|---|---|---|
| 1 | M001 | greenvale_normal |
| 4 | M003 | **greenvale_tough** |
| 9 | M010 | greenvale_elite |
| 10 | B001 | greenvale_boss |

Tough **does not** route to `greenvale_elite`.

**Item timing (runtime):** first possible drop L3 (10% normal); first controlled runtime drop L9 elite (`acc_silver_ring`).

---

## PRODUCTION ASSETS (8 core)

All 8 core roles: **expected path == runtime path**, no legacy placeholders.

Paths under `res://assets/monsters/greenvale/states/{ID}_idle.png`.

---

## VISUAL EVIDENCE

**Core (8):** `01`–`08` in `docs/v209_visual_runtime_qa/`  
**Supplemental:** `09_hero_unlock`, `10_elite_pre_boss`, `10_elite_reward`, `11_boss_combat`, `12_boss_victory`, `13_boss_loot`  
**Viewport matrix:** 16 captures (1080×1920/2340/2400, 1440×3200 × M012/M003/M010/B001)

Pixel analysis: all core shots **ok** (non-flat bright/dark ratios). Boss visually dominant; tough/elite labels readable; no legacy art observed.

---

## ATTACK STATE

Unchanged: attack art exists, **not wired** (no player-HP combat pillar).  
Hook: `docs/v209_asset_convergence/attack_state_hook.md`

---

## QA PERFORMANCE

| Metric | V2.09 Phase 1 |
|---|---|
| Total runtime QA | **55 402 ms** |
| Slowest step | viewport_matrix (**27 999 ms**) |
| Domain QA | ~2.5 s headless |
| Watchdog | 600 s max (bounded step waits) |

---

## REGRESSIONS (runtime smoke)

TAP, crit, hero unlock, hero autodps flag, inventory, equipment API, StatModifierService, RewardPipeline, boss, chest, quest, daily, SPIN, village, AFK, save v41, region progression — all checked.

---

## EXECUTE ACCEPTANCE

```
tools\run_v209_phase1_acceptance.bat
```

Or:

```
godot --headless --path . res://V209WorldDomainQaHost.tscn
godot --path . res://V209WorldRuntimeQaHost.tscn
```

---

## STOP — NO PHASE 2 YET

Phase 1 is **PASS**. Do **not** start Phase 2 features, new regions, or APK export.

Next decision (product):

- Region length / hero timing / TTK / item timing / loot frequency / visual variety  
→ **A)** Final polish & QA, or **B)** small Cycle-2 content pass with reserve monsters

---

## REMAINING (non-blocking)

1. Godot window may linger after runtime QA until manually closed (report + PNGs still written).
2. Cycle 2+ overflow dramaturgy not playtested.
3. `MonsterCatalog` autoload still present for compatibility.
4. `RewardPipeline.gd` NUL unicode warnings (non-fatal, pre-existing).
