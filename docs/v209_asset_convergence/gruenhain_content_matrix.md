# V2.09 — Grünhain Content Matrix

**Audit date:** 2026-09-12  
**Catalog:** `data/encounters_greenvale_p0_v1_4.json` · `v2.09-encounters-02`  
**Cycle length:** 15 encounters (14 pre-boss + B001)  
**Method:** On-disk assets + domain/runtime QA + reserve audit

---

## Status Legend

| Status | Meaning |
|---|---|
| **ACTIVE CYCLE** | In first Grünhain production cycle rotation |
| **RESERVE** | Production-ready; held in `rotation_overflow` |
| **FUTURE BOSS** | Boss art bound; not in cycle-1 dramaturgy |
| **DEPRECATED** | Non-runtime / legacy only |

---

## Monster Matrix

| ID | Name | Class | Status | Cycle slot | Asset path | Notes |
|---|---|---|---|---|---|---|
| M001 | Waldwinzling | normal | **ACTIVE CYCLE** | L1 | `assets/monsters/greenvale/states/M001_*.png` | Onboarding calibration |
| M012 | Blatthörnchen | normal | **ACTIVE CYCLE** | L2, L12 | `…/M012_*.png` | Fast small silhouette |
| M002 | Blatthorn | normal | **ACTIVE CYCLE** | L3 | `…/M002_*.png` | Agile quadruped |
| M003 | Waldkeiler | tough | **ACTIVE CYCLE** | L4, L13 | `…/M003_*.png` | Heavy boar; spaced repeats |
| M004 | Pilzling | normal | **ACTIVE CYCLE** | L5, L11 | `…/M004_*.png` | Mid humor / loot slot |
| M005 | Waldkäfer | normal | **ACTIVE CYCLE** | L6 | `…/M005_*.png` | **Hero unlock kill** |
| M006 | Blätterkauz | normal | **ACTIVE CYCLE** | L7 | `…/M006_*.png` | Selected reserve — aerial |
| M013 | Waldwolf | tough | **ACTIVE CYCLE** | L8 | `…/M013_*.png` | Selected reserve — predator |
| M008 | Moosschildkröte | tough | **ACTIVE CYCLE** | L9 | `…/M008_*.png` | Selected reserve — wide shell |
| M011 | Kristallgolem | tough | **ACTIVE CYCLE** | L10 | `…/M011_*.png` | Selected reserve — crystal block |
| M010 | Waldgeist | elite | **ACTIVE CYCLE** | L14 | `…/M010_*.png` | Pre-boss elite |
| B001 | Mooskönig | boss | **ACTIVE CYCLE** | L15 | `…/B001_*.png` + shield | Primary cycle boss / region complete |
| M007 | Mooskauz | normal | **RESERVE** | — | `…/M007_*.png` | Owl pair — max one owl in cycle |
| M009 | Waldschleim | normal | **RESERVE** | — | `…/M009_*.png` | Soft blob overlap M001 |
| M014 | Laubkeiler | normal | **RESERVE** | — | `…/M014_*.png` | Keiler pair — not adjacent to M003 |
| M002 | (overflow tag) | — | **RESERVE** | — | — | Listed in `rotation_overflow` for cycle-2+ pool |
| B002 | Pilzmagus | boss | **FUTURE BOSS** | — | `…/B002_*.png` | Boss rotation / higher cycles |
| B003 | Urwaldbestie | boss | **FUTURE BOSS** | — | `…/B003_*.png` | Boss rotation / events |

---

## rotation_overflow (catalog)

```json
["M007", "M009", "M014", "M002"]
```

**FUTURE BOSS (not overflow):** `boss_rotation` continues `["B001", "B002", "B003"]` — only B001 active in cycle 1.

---

## DEPRECATED / NON-RUNTIME

| Item | Status |
|---|---|
| `data/monsters.json` | **DEPRECATED / NON-RUNTIME** — no new data |
| Legacy placeholders (`monster_*_placeholder.png`) | **DEPRECATED** — do not bind |
| `MonsterCatalog` orphan paths | **DEPRECATED** — TAP uses `P0MonsterVisualSystem` only |

---

## Production Coverage

| Tier | Count | Status |
|---|---:|---|
| Normal | 9 | 9/9 PRODUCTION |
| Tough | 4 | 4/4 PRODUCTION |
| Elite | 1 | 1/1 PRODUCTION |
| Boss | 3 | 3/3 PRODUCTION |
| **Active cycle monsters** | **12** + B001 | 13 IDs in rotation |
| **Reserve production art** | 4 held | M007, M009, M014 + overflow M002 tag |

State PNG contract: `{ID}_{idle,attack,hit,defeat}.png` — 68 files + `B001_shield.png`.

---

## Overlap Groups (enforced in validator)

| Group | Members | Cycle rule |
|---|---|---|
| Owl pair | M006, M007 | One owl max — **M006 active, M007 reserve** |
| Keiler pair | M003, M014 | **M014 not adjacent to M003** — M014 reserve |
| Soft blob | M001, M009 | **M009 reserve** |

---

## QA Binding

| Check | Evidence |
|---|---|
| Active asset refs | Domain QA `production_asset_refs` |
| Reserve audit | `docs/v209_phase2/reserve_monster_audit.json` |
| Runtime screenshots | `docs/v209_visual_runtime_qa/` — M006, M013, M008, M011 + core set |
| Viewport risk pass | M006 (small/aerial), M008 (wide), M011 (tall), B001 (large) |

---

## V2.09 Phase 2 Decision

**PROCEED to Final Polish / V2.09 gate.** Central Grünhain combat art complete. Cycle 2 content pass delivered without new systems, new region, or APK.
