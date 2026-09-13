# V2.09 Phase 2 Report — Compact Cycle-2 Content Pass

**Date:** 2026-09-12  
**Build on:** V2.09 Phase 1 PASS  
**Scope:** Grünhain content breadth only — no new systems, no APK, no Frostmark gameplay

---

## STATUS

| Gate | Result |
|---|---|
| **Phase 2 overall** | **PASS** |
| Domain QA | **11/11 PASS** |
| Runtime QA | **PASS** (~74.7 s) |
| Catalog | `v2.09-encounters-02` · 15 encounters |

Reports: `docs/v209_domain_qa/world_domain_qa_report.json`, `docs/v209_visual_runtime_qa/world_runtime_qa_report.json`

---

## RESERVE MONSTER AUDIT

Documented in `docs/v209_phase2/reserve_monster_audit.json`. All six reserves have full 4-state production art. Runtime screenshots captured for activated IDs during full QA.

| ID | Assessment |
|---|---|
| M006 | Selected — aerial silhouette, readable at scale 0.97 |
| M007 | Reserve — owl pair overlap with M006 |
| M008 | Selected — wide defensive shell |
| M011 | Selected — tall crystal block, late-mid tough |
| M013 | Selected — lean predator wolf |
| M014 | Reserve — keiler pair; not adjacent to M003 |

---

## SELECTED MONSTERS

**4 activated:** M006 (L7), M013 (L8), M008 (L9), M011 (L10).

Stat roles via existing fields only: normal/fast aerial, tough predator, tough tank, tough high-reward stone.

**Not activated:** M007, M009, M014, B002, B003.

---

## FINAL ENCOUNTER CYCLE

```
L1–6   M001 → M012 → M002 → M003 → M004 → M005     [Phase 1 onboarding]
L7–10  M006 → M013 → M008 → M011                   [Reserve mid block]
L11–13 M004 → M012 → M003                          [Late tough build-up]
L14–15 M010 → B001                                 [Elite → Boss]
```

`boss_every_kills: 15` · `rotation_overflow`: M007, M009, M014, M002

---

## VISUAL VARIETY

Mid block introduces owl, wolf, turtle, golem — four distinct body plans after onboarding. No owl pair, no M014 beside M003, no M009 blob filler.

---

## STAT BLOCKS

Data-driven only per monster entry in encounter catalog. No Sonderhardcodes. Classifications: normal / tough / elite / boss only.

---

## HERO PACING

Kill 6 / M005 → Account L5 → Knight unlock. **Unchanged by extension.** Runtime verified (`hero_unlock_evidence`).

---

## ITEM TIMING

10 000-run loot simulation (`docs/v209_balance/loot_simulation_phase2.json`):

- 17.6% runs with no item before elite
- 82.4% with ≥1 item before elite
- First-item peaks at L3, L4, L8

Balanced via tough/normal `loot_roll_chance` tuning — not 50% normal flood.

---

## LOOT SIMULATION

Tool: `tools/simulate_v209_gruenhain_loot.py`  
Tracks first-item index, pre-elite item count, source contribution, pre-boss histogram.

---

## XP / GOLD CURVE

Account L5 @ hero · L6–7 mid cycle · L7 @ elite/boss start. Boss gold 680. Progression wider but not over-fed.

Detail: `docs/v209_balance/gruenhain_pacing_report.md`

---

## TTK

Boss B001 ≈ 44 taps @ TAP 10; ~30 with hero — still relevant with 45 s timer. Full scenario table in pacing report.

---

## ELITE BUILD-UP

M010 @ L14 directly before B001 @ L15. No extra normals between. `greenvale_elite` 75% roll.

---

## BOSS BALANCE

B001 remains cycle-1 climax. HP 438 unchanged (not sponge-inflated). B002/B003 reserved for future rotation.

---

## REGION COMPLETION

B001 victory triggers Grünhain completion, rewards, save. Verified save/reload post-boss in runtime QA.

---

## PRODUCTION ASSETS

All active monsters use `assets/monsters/greenvale/states/` only. 69 PNG files (68 states + B001 shield). No new placeholders.

---

## DOMAIN QA

11/11 PASS — cycle length, order, refs, stats, assets, hero timing, M010 pre-boss, loot sim, overflow, deprecated guard.

---

## RUNTIME QA

15-encounter natural flow PASS (`flow_ok: true`). All regression smoke PASS. Fix: `_await_boss_combat_ready()` for elite→boss handoff and boss victory screenshots.

---

## VISUAL QA

Screenshots for M006, M013, M008, M011 + M001, M003, M010, B001 + `14_boss_victory`, `15_boss_loot`. Viewport matrix PASS (risk silhouettes).

---

## SAVE / RELOAD

Mid-cycle and post-B001 reload PASS.

---

## REGRESSIONS

TAP, crit, heroes, inventory, equipment, modifiers, loot, boss, chest, quest, daily, SPIN, village, AFK, save, region progression — smoke PASS.

---

## QA PERFORMANCE

Phase 1 ~55.4 s → Phase 2 **~74.7 s** for 15 encounters. Minute-scale budget maintained.

---

## REMAINING ISSUES

1. **Low:** Transient `Boss interval broken` boot log when loading stale save before QA reset (catalog valid after reset).
2. **Low:** Godot may hang on quit after QA (reports already written).
3. **Documented:** Attack state assets present but unwired (`attack_state_hook.md`).

---

## READY FOR FINAL V2.09 GATE

**PASS** — ready for Final Polish → Full Acceptance → APK.

No Phase 3 system sprint. No APK in Phase 2.
