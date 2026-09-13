# REALM ALLIANCE — V2.06.1 ABSCHLUSSREPORT

**Milestone:** V2.06.1 (build 2061)  
**Basis:** V2.06.0 QA-PASS  
**Datum:** 2026-09-11  
**QA:** PASS (Full ~90s, Smoke ~21s)  
**APK:** `builds/android/RealmAlliance_V2_06_1_Test.apk`

---

## STATUS

**PASS** — Legacy HUD pills UI015–017 werden zur Laufzeit durch v4 `resource_bars` ersetzt. Hero-Portrait-Slots sind production-ready vorbereitet (Placeholder gebunden). Kein Feature-Drift.

---

## HUD REBIND

| Slot | Legacy | V2.06.1 Production | Role |
|------|--------|-------------------|------|
| `GoldPillP0` | UI015 | `resource_bars_06` | `ui.hud.resource.gold` |
| `SpinPillP0` | UI016 | `resource_bars_03` | `ui.hud.resource.spin` |
| `ShieldPillP0` | UI017 | `resource_bars_08` | `ui.hud.resource.shield` |

Implementierung: `ProductionAssetConvergenceV2061.gd` → `ProductionUiBinder.apply_texture()` nach V193, vor `ScreenUiAssemblyService`. Scene-ext_resources bleiben als Fallback, sind im Runtime-Slot nicht aktiv.

Label-Padding: anchors `0.38–0.90`, zentriert.

---

## HERO PORTRAITS

| Hero | Asset | Status |
|------|-------|--------|
| Knight | `hero_knight_portrait_placeholder.png` | PLACEHOLDER (slot bound) |
| Archer | `hero_archer_portrait_placeholder.png` | PLACEHOLDER (slot bound) |
| Mage | `hero_mage_portrait_placeholder.png` | PLACEHOLDER (slot bound) |

- `HeroPortraitV2061` TextureRect auf Collection-Cards
- `HeroMasteryBadgeV2061` behält V151 mastery icons als Interim-Badge
- Keine neuen finalen Portraits generiert

---

## ASSET MAPPING

Siehe `docs/v2061_asset_convergence/production_asset_mapping.md`, `asset_needs.md`, `visual_issue_register.md`.

---

## MASTER UI CHECK

- Top: Player / Progression / Resources — v4 bars sichtbar
- Upper mid: Region / Encounter / Boss — unverändert
- Center: Monster — unverändert
- Lower mid: HP / Combat / Rewards — unverändert
- Bottom: Combat / Upgrades / Navigation — unverändert
- Keine neue visuelle Überladung

---

## VISUAL FIXES

- HUD resource bar runtime rebind (V2061)
- Hero portrait slot wiring + mastery badge separation
- QA asset verification: legacy UI015–017 detection + v4 bar path check

---

## RUNTIME QA

| Gate | Result |
|------|--------|
| Smoke | PASS (~21s) |
| Full | PASS (~90s) |
| Tap determinism | 3/3 |
| Regression (boot/nav/spin/save/tap) | ALL PASS |
| `visual_issues` | `[]` |

Asset verification (Full): gold/spin/shield HUD → v4 `resource_bars`; hero portraits → placeholder slots verified.

---

## SCREENSHOTS

Evidence: `docs/v2061_visual_runtime_qa/`

| Shot | Inhalt |
|------|--------|
| `01_main_1080x2340` | Main mit v4 Resource Bars |
| `34–36_hud_*` | HUD bars / gold / spin+shield |
| `28–33`, `37` | Hero collection, locked, detail, deploy, combat, level up |
| `12–15` | Boss flow |
| `19_main_reload` | Main after reload |
| Viewport matrix | 1080×2340, 2400, 1920, 1440×3200 |

---

## VIEWPORT MATRIX

All profiles PASS — siehe `visual_acceptance_report.json` → `viewport_matrix`.

---

## APK

- **Datei:** `builds/android/RealmAlliance_V2_06_1_Test.apk`
- **Version:** 2.06.1 / build 2061
- Export nach finalem QA PASS

---

## REMAINING PLACEHOLDERS

| ID | Slot |
|----|------|
| `HERO_KNIGHT_PORTRAIT` | Collection + deploy indicator |
| `HERO_ARCHER_PORTRAIT` | Collection |
| `HERO_MAGE_PORTRAIT` | Collection |

HUD spin bar: v4 lightning motif (akzeptiert, dokumentiert in visual_issue_register).

---

## NEXT

**V2.07** — Inventory / Equipment / Loot (Feature-Start nach abgeschlossenem V2.06.1 visual milestone).
