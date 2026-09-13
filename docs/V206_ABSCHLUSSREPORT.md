# REALM ALLIANCE — V2.06 ABSCHLUSSREPORT

**Milestone:** V2.06.0 (build 2060)  
**Basis:** V2.05.0 QA-PASS  
**Datum:** 2026-09-11  
**QA:** PASS (Full ~62s, Smoke ~24s)  
**APK:** `builds/android/RealmAlliance_V2_06_Test.apk`

---

## V2.06 STATUS

**PASS** — Heroes sind aktive zweite Progressionssäule; Visual Convergence Audit abgeschlossen; V2.05 Regression intakt.

---

## MASTER CONCEPT COMPLIANCE

Geprüft gegen: `MASTER_CONCEPT_V2_2.md`, `V2_01_MOBILE_LAYOUT_AUDIT.md`, `V1_87/V1_88_MASTER_V2_2_VISUAL_ALIGNMENT.md`, `data/MASTER_ASSETLIST_V1_4.csv`.

- TAP/SPIN/DORF/MODI Navigation unverändert
- Monster bleibt visueller Fokus (Hero kompakt via Assist-Label)
- Production-assets-first Policy eingehalten
- Keine neue parallele UI-Sprache erfunden

---

## PRODUCTION ASSET AUDIT

**32 priorisierte Runtime-Slots** geprüft → `docs/v206_asset_convergence/production_asset_mapping.md`

| Kategorie | Anzahl |
|-----------|--------|
| PRODUCTION verified | 24 |
| LEGACY (hidden/fallback) | 5 |
| MISSING production match | 1 (Hero portraits) |

---

## ASSET REBINDINGS

- Hero cards: V151 mastery icons (`hero.knight/archer/mage`) — bereits gebunden, beibehalten
- Quest/Daily/Chest: production atlas + `quest_states` PNGs — verified
- M001/B001/BG001: unverändert PRODUCTION via `P0MonsterVisualSystem` / scene
- HUD pills UI015–017: LEGACY embed, dokumentiert für späteres v4 rebind

---

## LEGACY UI CLEANUP

- `P02CoreController`: `HeroesGameButton` an `SHOW_HEROES` gekoppelt
- Legacy `Btn_Heroes` bleibt hidden
- Lane `deploy_hero()` unverändert als LEGACY (Lane units ≠ Tap heroes)

---

## MAIN GAMEPLAY VISUAL STATE

- Hierarchie: Top HUD → Encounter/Boss → Monster → Combat feedback → Bottom nav
- Hero Assist Label kompakt (`HELD · X DPS`)
- Keine permanente Hero-Card auf Main

---

## UI FOUNDATION / COMPONENT CONSOLIDATION

- Bestehende `ProductionUiBinder` + `ScreenUiAssemblyService` + Convergence V187–V193
- Hero collection nutzt bestehende `View_Heroes` + V151 backdrops
- Quest/Daily nutzen shared reward/overlay foundation

---

## HERO ARCHITECTURE

| Komponente | Status |
|------------|--------|
| `HeroSystem.gd` | DEEPENED — deploy, DPS, resolver integration |
| `data/heroes.json` | v2.06 — rarity, role, attack_interval |
| `HeroProgressionSystem` | KEEP — mastery/spec |
| `CombatDamageResolver` | Unified `resolve_damage()` contract |
| Save v39 | `deployed_hero_id` persistiert |

---

## HERO COLLECTION / UNLOCK / DEPLOYMENT

- Unlock: Account Level 5/8/12 (echte Progression, kein QA-only)
- Collection: `View_Heroes` via MODI `HubHeroesP0`
- Deploy: Select → Einsetzen (zweiter Tap auf Karte)
- Auto-deploy bei erstem Unlock

---

## AUTO COMBAT

```
Deployed Hero → CombatDamageResolver (source_type=hero) → PlayerData.damage_monster → Feedback → Defeat → RewardPipeline
```

---

## HERO LEVELING / ECONOMY

- Gold spend via `EconomyAuthorityService.commit_gold_spend_local`
- Power/DPS steigen mit Level + Equipment + Spec
- QA: Level-up kostet Gold, erhöht Power

---

## BOSS / QUEST / DAILY / CHEST INTEGRATION

- Boss: Hero damage via shared resolver; Boss flow regression PASS
- Quest: `hero_deployed` starter objective + GameplayEventService events
- Daily/Chest/AFK/SPIN: V2.05 regression all true

---

## SAVE / MIGRATION

- `SAVE_VERSION = 39`
- Hero: owned, level, equipment, selected, **deployed**
- V2.05 quest/daily/chest/afk/boss data preserved on reload

---

## RUNTIME QA

| Gate | Result |
|------|--------|
| Smoke | PASS |
| Full | PASS |
| TAP determinism | 3/3 |
| Regression | all true |
| Viewport matrix | 4/4 PASS |
| visual_issues | [] |

Evidence: `docs/v206_visual_runtime_qa/`

Key hero screenshots: `28_hero_collection_locked`, `29_hero_unlock`, `30_hero_deployed`, `31_hero_auto_attack`, `32_combined_combat`, `33_hero_level_up`

---

## APK

| Feld | Wert |
|------|------|
| Pfad | `builds/android/RealmAlliance_V2_06_Test.apk` |
| versionName | 2.06.0 |
| versionCode | 2060 |
| Export | Post-QA-PASS |

---

## ASSET NEEDS

→ `docs/v206_asset_convergence/asset_needs.md` (Hero portraits, optional HUD pill v4 rebind)

---

## REMAINING ISSUES

1. Hero portrait production art fehlt (V151 icons als interim)
2. HUD pills noch UI015–017 scene embed
3. P0 boot drift warning in QA (non-blocking)
4. AFK hero modifier — Schnittstelle vorbereitet, nicht aktiv

---

## NEXT

- Hero portrait production pass
- HUD v4 resource bar rebind
- Server-authoritative hero deploy validation
- AFK moderate hero power modifier
