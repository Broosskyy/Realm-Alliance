# V2.09 Abschlussreport — Grünhain Production Pass

**Status:** PASS  
**Version:** 2.09.0 (Build 2090)  
**Encounter catalog:** `v2.09-encounters-02`  
**Date:** 2026-09-13

---

## STATUS

V2.09 Final Acceptance **PASS**. Grünhain 15-Encounter Production Cycle, Inventory/Equipment, Boss/Region Completion, Full QA, Android Test APK.

Report: `docs/v209_final_qa/final_acceptance_report.json`

---

## FINAL GREENVALE CYCLE (15)

| Phase | Levels | Encounters |
|---|---|---|
| EARLY | L1–6 | M001 → M012 → M002 → M003 → M004 → M005 |
| MID | L7–10 | M006 → M013 → M008 → M011 |
| LATE | L11–13 | M004 → M012 → M003 |
| CLIMAX | L14–15 | M010 (Elite) → B001 (Boss) |

Hero Unlock: Kill 6 / M005 → Account L5 → Ritter.

---

## ACTIVE MONSTERS

M001, M012, M002, M003, M004, M005, M006, M013, M008, M011, M010, B001

## RESERVE MONSTERS

M007, M009, M014 (+ overflow tag M002)

## FUTURE BOSSES

B002, B003 — not activated in V2.09 cycle 1

---

## HERO PROGRESSION

Runtime verified: Account L4 → L5 at M005 / Kill 6. Knight available before Mid/Late/Elite/Boss.

---

## LOOT BALANCE

10 000-run simulation (`docs/v209_balance/loot_simulation_phase2.json`):

- 82.4% ≥1 item before Elite
- 17.6% no item before Elite
- Peaks L3 / L4 / L8

Sources: `greenvale_normal`, `greenvale_tough`, `greenvale_elite`, `greenvale_boss` — separated.

---

## INVENTORY / EQUIPMENT

- Domain QA: **26/26 PASS**
- Runtime QA: **PASS** — real TAP + Hero stat modifiers, replace/unequip, save/reload

---

## ELITE / BOSS / REGION COMPLETION

- M010 @ L14 directly before B001 @ L15
- B001 HP 438 (data-driven)
- Boss victory → loot → Grünhain region completion → save/reload verified

---

## PRODUCTION ASSETS

17 monsters × 4 states + `B001_shield.png` = 69 PNGs. No active Grünhain placeholders.

---

## DOMAIN QA

| Suite | Result |
|---|---|
| V2.09 World | **11/11 PASS** |
| V2.07 Inventory | **26/26 PASS** |

---

## RUNTIME QA

| Suite | Duration | Result |
|---|---|---|
| V2.09 World (15 encounters) | ~83 s | **PASS** |
| V2.07 Inventory | ~90 s | **PASS** |

---

## REGRESSION QA

TAP, Crit, Heroes, Inventory, Equipment, Stat modifiers, Loot pipeline, Boss, Chest, Quest, Daily, SPIN, Village, AFK, Save, Region progression — smoke PASS.

---

## VISUAL / VIEWPORT QA

Core + reserve screenshots + boss victory/loot. Viewport matrix: 1080×1920/2340/2400, 1440×3200 — M012, M006, M003, M010, B001 risk pass.

---

## SAVE / RELOAD

Mid-cycle and post-B001 verified (Save v41).

---

## QA PERFORMANCE

| Phase | Runtime QA |
|---|---|
| Phase 1 | ~55 s |
| Phase 2 | ~75 s |
| Final | ~83 s world + inventory |

---

## APK

| Field | Value |
|---|---|
| Path | `builds/android/RealmAlliance_V2_09_Test.apk` |
| Size | 1 014 587 634 bytes (~968 MB) |
| Package | `com.realmalliance.prototype` |
| versionName | `2.09.0` |
| versionCode | `2090` |
| ABI | `arm64-v8a` |
| SHA-256 | `8d484ac55b33628b4d29826f5caf1652bdbf50053d7ca118104c6e9b27759cbc` |
| Build | Debug-signed test build (no release keystore) |
| Timestamp | 2026-09-13 05:39:09 local |

---

## APK VALIDATION

Export exit code 0. `aapt dump badging` confirms package, versionCode 2090, versionName 2.09.0, native-code arm64-v8a.

---

## GIT

| Field | Value |
|---|---|
| Repository | `https://github.com/Broosskyy/Realm-Alliance.git` |
| Remote | `origin` |
| Branch | `main` (tracks `origin/main`) |
| Local commit | `79dc8ce63a4caeba4c486aca90ad77bf3a63b69d` |
| Commit message | `feat(realm): complete V2.09 Greenvale production pass` |
| Files changed | 830 files (+113 616 / −726) |
| Working tree | clean |
| APK in git | **no** (`builds/android/*.apk` ignored) |
| Push status | **PENDING** — local `main` ahead of `origin/main` by 1 commit |
| Remote HEAD | *(pending push verification)* |

Security audit: no `.env`, keystore, tokens, or APK staged.

Publish helper: `tools/publish_v209_github.bat` (push + release + APK upload)

---

## GITHUB RELEASE

| Field | Value |
|---|---|
| Tag | `v2.09.0-test` |
| Release name | `REALM ALLIANCE V2.09 Test` |
| Target commit | `79dc8ce63a4caeba4c486aca90ad77bf3a63b69d` |
| Release status | **PENDING** (requires push first) |
| Asset name | `RealmAlliance_V2_09_Test.apk` |
| Asset SHA-256 | `8d484ac55b33628b4d29826f5caf1652bdbf50053d7ca118104c6e9b27759cbc` |
| Direct download URL | *(pending release upload — use `gh release view v2.09.0-test` after publish)* |

---

## KNOWN NON-BLOCKING ISSUES

1. Godot may hang on `quit()` after runtime QA despite complete PASS report + `process_exit.json`.
2. Attack state assets present but unwired (deferred — no fake attack loop).
3. Unicode NUL warnings in some `.gd` autoload scan (cosmetic import noise).
4. Large APK size (~968 MB) — full production asset bundle included.

---

## DEFERRED

- Monster Attack State / Player HP counter-combat
- M007, M009, M014 reserve activation
- B002, B003 boss rotation cycles
- Frostmark gameplay production
- Region icon, Lane/TD maps (P2)

---

## NEXT

V2.09 gate closed. No V2.10 development in this delivery.

---

## FIXES IN FINAL POLISH

- `P0RuntimeContract.gd`: dynamic boss level L15 (removed hardcoded L10 B001 check)
- `CoreAcceptanceService.gd`: elite @ L14 validation aligned with catalog
- `P0MonsterVisualSystem` / `SaveGame` / `MainGame`: force catalog reload after save load
- `V207ItemDomainQa` / `V207InventoryRuntimeQa`: boss defeat tests use `boss_every_kills()`
- `BuildInfo.gd` → 2.09.0 / 2090
- `export_presets.cfg` → V2.09 APK path, debug signing for test build
