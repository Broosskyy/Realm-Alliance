# V2.07 Abschlussreport — PASS

**Version:** 2.07.0 (build 2070)  
**Status:** **PASS**  
**APK:** `builds/android/RealmAlliance_V2_07_Test.apk`

---

## STATUS

| Gate | Result |
|---|---|
| Domain QA | **26/26 PASS** |
| Inventory Visual QA | **PASS** |
| Full Visual Runtime QA (V2.06 harness) | **PASS** |
| APK Export | **PASS** |

---

## QA ASSERTION FIX

### Previous False Positive
`hero_damage_did_not_rise`

### Root Cause
Die Inventory-QA erwartete einen Hero-Damage-Anstieg beim Equip einer **Weapon**, obwohl `wpn_gruenhain_blade` im Item Catalog nur `tap_damage` modifiziert.

### Fix
`V207InventoryRuntimeQa.gd` liest jetzt Item-Definitionen (`modifiers[].stat`) und validiert:
- **Weapon** → `tap_preview` / `tap_real` steigen, Hero unverändert (kein Modifier-Leak auf Preview-Stats)
- **Accessory** → `hero_effective` / `hero_real` steigen, TAP Preview unverändert
- **Replace / Unequip / Save-Reload** mit separaten Assertions
- Negative Verifikation ohne Crit-RNG-Flakiness auf `*_real` Leak-Checks für nicht betroffene Stats

---

## RUNTIME EVIDENCE (letzter QA-Lauf)

| Messpunkt | Before | After |
|---|---|---|
| TAP preview | 11 | 26 (Weapon equip) |
| TAP real | 11 | 26 |
| Hero effective | 6 | 14 (Accessory equip) |
| Hero real | 6 | 14 |
| TAP after Battle Axe replace | 26 | 33 |
| TAP after Weapon unequip | 33 | 11 |
| Save/Reload TAP | 26 | 26 |
| Save/Reload Hero | 14 | 14 |

**Weapon:** `wpn_gruenhain_blade` → nur `tap_damage +15`  
**Accessory:** `acc_silver_ring` → nur `hero_damage +8`  
**Replace:** `wpn_battle_axe` ersetzt Blade, vorherige Instanz unequipped  
**Unequip:** Battle Axe entfernt, Accessory-Hero-Buff bleibt  
**Save/Reload:** equipped mapping + Instanzen erhalten, Modifier rekonstruiert

---

## INVENTORY / EQUIPMENT / COMBAT

- `View_Inventory` mit Filter, Sort, Detail, Equip/Unequip
- MODI → INVENTAR + Hero Item Slots
- `StatModifierService` → `CombatDamageResolver` (TAP + Hero)
- Legacy Tier Power getrennt von Item Equipment Power

---

## BOSS / CHEST LOOT

- Boss: `acc_guardian_pendant` via `RewardPipeline.grant_monster_defeat`
- Chest: `wpn_gruenhain_blade` via `ChestRewardSystem.open_chest`
- Reward UI zeigt echte Items (Icon/Name/Rarity via Text)

---

## DOMAIN QA

`docs/v207_domain_qa/domain_qa_report.json` — 26/26 PASS

---

## VISUAL QA

`docs/v207_visual_runtime_qa/inventory_qa_report.json` — **PASS**  
`visual_issues: []`

### Screenshots (12 Kern + 12 Viewport)
- Inventory, Weapon Detail, Weapon Equipped, TAP Combat
- Accessory Detail, Accessory Equipped, Hero Combat
- Both Slots, Replacement, Boss Loot, Chest Reward, After Reload
- Viewport Matrix: 1080×1920, 1080×2340, 1080×2400, 1440×3200

---

## APK

| Feld | Wert |
|---|---|
| Pfad | `builds/android/RealmAlliance_V2_07_Test.apk` |
| Größe | ~748 MB (784,490,805 bytes) |
| package | `com.realmalliance.prototype` |
| versionName | `2.07.0` |
| versionCode | `2070` |
| ABI | `arm64-v8a` |
| Export | Signed debug APK, erfolgreich verifiziert |

---

## REGRESSIONS

Keine Regressionen in Domain QA oder Full Visual Runtime QA.

---

## REMAINING ISSUES

- Hero Portraits bleiben dokumentierte Placeholder
- P0 boot diagnostic meldet `HeroSystem processing during P0` (bestehend, nicht V2.07-blockierend)

---

## NEXT

V2.07 ist abgeschlossen. Kein Phase-3-Milestone erforderlich.
