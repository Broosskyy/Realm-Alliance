# V2.08 Abschlussreport — PASS

**Version:** 2.08.0 (build 2080)  
**Status:** **PASS**  
**APK:** `builds/android/RealmAlliance_V2_08_Test.apk`

---

## STATUS

| Gate | Result |
|---|---|
| Domain QA (World) | **8/8 PASS** |
| Domain QA (V2.07 Items) | **26/26 PASS** |
| Visual Runtime QA | **PASS** (13/13 assertions, ~59s) |
| APK Export | **PASS** |

---

## QA PERFORMANCE / ROOT CAUSES FIXED

| Issue | Root Cause | Fix |
|---|---|---|
| No report / 10h hang | `OS.set_exit_code()` invalid in Godot 4 → Host script failed to load | Removed; `get_tree().quit(code)` only |
| Encounter level drift | QA called `spawn_next_monster()` which increments level | `_reset_encounter()` sets HP directly |
| Hero auto-DPS interference | HeroSystem `_process` advanced encounters during QA | `HeroSystem.set_process(false)` in QA |
| Boss victory timeout | Overlay visibility check raced presentation | Assert on `bosses_defeated` region state |

**Runtime:** 58.7s total (was ~12h blocked runs)

---

## WORLD/REGION ARCHITECTURE

- `regions.json` v2.08 catalog (Grünhain playable, Frostmark preview)
- `RegionProgressionSystem` — combat region, loot sources, player progress, save v41
- `P0MonsterVisualSystem` — region-aware catalog + classification + display_scale
- `EncounterProgressService` — correct region name, elite/tough labels

---

## GRÜNHAIN / ENCOUNTERS / MONSTERS

- M001 → TAP/Hit/Hero → Defeat → M002 (different `monster_id` + asset path)
- Elite M010 at level 11
- Boss B001 at level 10 via BossChallengeSystem
- Production assets: M001–M014, B001–B003, BG001

---

## BOSS / REGION LOOT / SAVE V41

- Boss Ready → Intro → Challenge active → Victory → `bosses_defeated: 1`
- Loot: `greenvale_boss`, `greenvale_elite`, `greenvale_normal`
- Save v41: region + equipment + stats preserved after reload

---

## INVENTORY/EQUIPMENT REGRESSION (V2.07)

- Weapon → TAP real damage ↑
- Accessory → Hero real damage ↑
- Save/Reload → equipment + stats intact

---

## SCREENSHOTS (32)

Core 20 + Viewport matrix 12 in `docs/v208_visual_runtime_qa/`  
`visual_issues: []`

---

## APK

| Feld | Wert |
|---|---|
| Pfad | `builds/android/RealmAlliance_V2_08_Test.apk` |
| Größe | ~834 MB (874,218,638 bytes) |
| package | `com.realmalliance.prototype` |
| versionName | `2.08.0` |
| versionCode | `2080` |
| ABI | `arm64-v8a` |

---

## REMAINING PLACEHOLDERS

- Frostmark region art + encounters
- Region icons, lane/TD maps (see `asset_needs.md`)

---

## NEXT

V2.08 closed. Frostmark content production when assets ready.
