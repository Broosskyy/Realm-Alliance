# V2.09 — Grünhain Pacing Report

**Milestone:** Phase 2 (Extended Cycle)  
**Catalog:** `v2.09-encounters-02` · `boss_every_kills: 15`  
**Balance profile:** `GameConfig` early curve + per-monster `stats.xp_reward` / `loot_roll_chance`  
**Baseline combat:** TAP damage 10, no upgrades unless noted

---

## Final Encounter Order (15 encounters)

| L | ID | Name | Class | Eff. HP | XP | Loot source | Roll | Est. TTK (TAP 10) |
|---|---|---|---|---:|---:|---|---:|---:|
| 1 | M001 | Waldwinzling | normal | 88 | 55 | greenvale_normal | 0% | ~9 |
| 2 | M012 | Blatthörnchen | normal | 72 | 50 | greenvale_normal | 0% | ~8 |
| 3 | M002 | Blatthorn | normal | 97 | 55 | greenvale_normal | 10% | ~10 |
| 4 | M003 | Waldkeiler | tough | 142 | 62 | greenvale_tough | 20% | ~15 |
| 5 | M004 | Pilzling | normal | 105 | 64 | greenvale_normal | 12% | ~11 |
| 6 | M005 | Waldkäfer | normal | 121 | 70 | greenvale_normal | 14% | ~13 |
| 7 | M006 | Blätterkauz | normal | 100 | 52 | greenvale_normal | 10% | ~10 |
| 8 | M013 | Waldwolf | tough | 155 | 56 | greenvale_tough | 18% | ~16 |
| 9 | M008 | Moosschildkröte | tough | 168 | 58 | greenvale_tough | 18% | ~17 |
| 10 | M011 | Kristallgolem | tough | 188 | 60 | greenvale_tough | 20% | ~19 |
| 11 | M004 | Pilzling | normal | 108 | 64 | greenvale_normal | 12% | ~11 |
| 12 | M012 | Blatthörnchen | normal | 76 | 50 | greenvale_normal | 0% | ~8 |
| 13 | M003 | Waldkeiler | tough | 152 | 62 | greenvale_tough | 20% | ~16 |
| 14 | M010 | Waldgeist | elite | 223 | 32 | greenvale_elite | 75% | ~23 |
| 15 | B001 | Mooskönig | boss | 438 | 45 | greenvale_boss | 100% | ~44 |

**Structure:** EARLY L1–6 (Phase 1 onboarding preserved) → MID L7–10 (new reserve silhouettes) → LATE L11–13 (tough build-up) → CLIMAX L14 elite → L15 boss.

**M010 remains directly before B001.** No normal encounters between elite and boss.

---

## Phase Structure

| Phase | Levels | Purpose |
|---|---|---|
| EARLY | 1–6 | Intro, first tough at L4, **hero unlock at L6 / kill 6** |
| MID | 7–10 | M006 owl, M013 wolf, M008 turtle, M011 golem — visual + role expansion |
| LATE | 11–13 | Pace contrast + repeated tough M003 |
| CLIMAX | 14–15 | M010 elite → B001 Mooskönig → region completion |

---

## Hero Unlock Timing

| Metric | Phase 1 | Phase 2 (verified runtime) |
|---|---|---|
| Unlock requirement | Account L5 | Account L5 |
| Unlock point | Kill 6 / M005 | **Kill 6 / M005 — unchanged** |
| Account level after L6 | L5 | L5 |
| Before elite? | Yes (L14) | **Yes** |
| Before boss? | Yes (L15) | **Yes** |

Runtime evidence: `docs/v209_visual_runtime_qa/world_runtime_qa_report.json` → `hero_unlock_evidence`.

---

## First Item Timing (10 000-run simulation)

Source: `docs/v209_balance/loot_simulation_phase2.json`

| Metric | Value |
|---|---|
| Runs simulated | 10 000 |
| No item before elite (L14) | **17.6%** |
| ≥1 item before elite | **82.4%** |
| 3+ items before elite (too early risk) | **20.4%** |
| First-item index peaks | L4 (1792), L8 (1065), L3 (1087) |

**Normal vs tough contribution (successful rolls):** normal 5857 · tough 10045 · elite/boss rolls excluded from pre-elite histogram.

**Design intent met:** Equipment is likely before the elite endgame without 50% normal flood.

---

## XP / Gold Curve (runtime trace, TAP baseline)

| Milestone | Encounter | Account level @ start | Notes |
|---|---|---:|---|
| Hero unlock | L6 M005 | 4 → **5** after kill | Knight available L7+ |
| Mid expansion | L10 M011 | 6 | Post-hero tough golem |
| Elite | L14 M010 | 7 | Pre-boss spike |
| Boss | L15 B001 | 7 (183 XP) | Boss still ~44 taps @ TAP 10 |

Gold samples (runtime): L1 54 · L4 113 · L6 136 · L10 216 · L14 335 · L15 680.

Progression is wider than Phase 1 but not over-fed: account L7 at boss with hero deployed, boss HP unchanged at 438.

---

## TTK Curve (simulated scenarios)

Effective HP from `EncounterStatService` / runtime QA `hp_evidence`. TTK ≈ ceil(eff_hp / tap_damage).

| Scenario | L4 M003 | L10 M011 | L14 M010 | L15 B001 |
|---|---:|---:|---:|---:|
| A · TAP only (dmg 10) | ~15 | ~19 | ~23 | ~44 |
| B · TAP + upgrades | ~12 | ~15 | ~18 | ~35 |
| C · TAP + Hero (post L6) | ~10 | ~13 | ~16 | ~30 |
| D · + common equipment | ~8 | ~11 | ~14 | ~26 |
| E · stronger equipment | ~6 | ~9 | ~11 | ~20 |

Boss remains relevant in scenario C (hero mid-cycle): ~30 taps + timer pressure, not trivialized by extended XP alone.

---

## Boss Readiness

| Check | Result |
|---|---|
| Elite immediately pre-boss | L14 M010 → L15 B001 |
| Boss HP block | 438 (data-driven, not sponge-inflated) |
| Boss loot | 100% `greenvale_boss` |
| Region completion trigger | B001 victory (V2.09 gate) |
| B002 / B003 in cycle 1 | **Not used** — future rotation |

---

## Visual Rhythm (silhouette mix)

| Segment | Body plans |
|---|---|
| L1–2 | Small spirit, small squirrel |
| L3–6 | Quadruped, boar, mushroom, beetle |
| L7–10 | **Owl (aerial)**, wolf, **wide turtle**, **tall golem** |
| L11–13 | Mushroom repeat, fast squirrel, boar tough |
| L14–15 | Spectral elite, moss boss golem |

No adjacent owl pair (M007 held). No M014 beside M003 (L4 + L13 spacing).

---

## QA Performance

| Gate | Result | Duration |
|---|---|---|
| Domain QA | **11/11 PASS** | headless |
| Runtime QA | **PASS** (full 15-encounter flow) | **~74.7 s** |
| Phase 1 reference | 8/8 · ~55.4 s | — |

Extended cycle stays within minute-scale acceptance budget.

---

## Attack State

Unchanged from Phase 1: assets present; runtime TAP loop uses hit/defeat only. See `docs/v209_asset_convergence/attack_state_hook.md`.

---

## Run QA

```bash
tools/run_v209_phase2_acceptance.bat
```

Or:

```bash
godot --headless --path . res://V209WorldDomainQaHost.tscn
godot --path . res://V209WorldRuntimeQaHost.tscn
```

Runtime QA requires rendering (no `--headless`).
