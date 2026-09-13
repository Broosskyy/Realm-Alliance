# REALM ALLIANCE — V2.07 AUDIT REPORT

**Basis:** V2.06.1 PASS (build 2061)  
**Scope:** Inventory, Equipment, Loot, Hero Equipment, Production Assets  
**Date:** 2026-09-11

---

## EXECUTIVE SUMMARY

V2.07 baut auf **bestehenden Foundations** auf — keine zweite Architektur.

**Was existiert:**
- Hero `equipment_light` (weapon/charm tiers, gold upgrades, flat power)
- `RewardPipeline` + `ChestRewardSystem` (currency only)
- `InventoryEntitlementService` (IAP/server entitlements — **nicht** RPG bag)
- Production UI art: 8 equipment icons, 8 consumables, 8 rarity frames, 9 slot frames
- `CombatDamageResolver` + `HeroSystem` DPS pipeline

**Was fehlt:**
- Item catalog, loot tables, owned item instances
- General inventory bag + equip flow
- Item grants in `RewardPipeline`
- Stat modifier pipeline for equipment
- `View_Inventory` screen
- Save block for item/equipment state

---

## 1. SYSTEM CLASSIFICATION

| System | Path | Classification | V2.07 Action |
|---|---|---|---|
| `HeroSystem` equipment | `HeroSystem.gd` | **KEEP + DEEPEN** | Bridge to item instances; read `equipment_light` from JSON |
| `RewardPipeline` | `RewardPipeline.gd` | **DEEPEN** | Add `items[]` to grant contract |
| `ChestRewardSystem` | `ChestRewardSystem.gd` | **DEEPEN** | Loot roll + item grant |
| `EconomyAuthorityService` | `EconomyAuthorityService.gd` | **DEEPEN** | Item grant commands |
| `CombatDamageResolver` | `CombatDamageResolver.gd` | **DEEPEN** | Equipment modifier layer |
| `InventoryEntitlementService` | `InventoryEntitlementService.gd` | **KEEP (IAP)** | Do not overload for loot |
| `LoadoutSnapshotService` | `LoadoutSnapshotService.gd` | **KEEP** | Extend when items ship |
| `ObjectiveSystem` | `ObjectiveSystem.gd` | **DEEPEN** | `item_acquired`, `item_equipped` events |
| `QuestSystem` | `QuestSystem.gd` | **LEGACY** | Do not extend |
| `PlayerData.reward_monster_kill` | `PlayerData.gd` | **LEGACY** | Remove if unused |
| `HeroEquipmentPreviewV165` | `ScreenUiAssemblyService.gd` | **PLACEHOLDER** | Make stateful or replace |
| Item/Inventory/Loot systems | — | **MISSING** | **NEW** `ItemSystem` + `ItemInventoryService` |

---

## 2. DATA MODEL GAP

### Present

| File | Contents |
|---|---|
| `data/heroes.json` | `equipment_light`: slots weapon/charm, tier_power_bonus, max_tier 3 |
| `data/chests_v205.json` | Currency tiers: common/rare/boss |
| `data/objectives_v1_52.json` | `chest_tier` side effects |
| `data/online_authority_v186.json` | `server_owns_items: true` policy |

### Missing

- `items_v207.json` (catalog)
- `loot_tables_v207.json` (rolls)
- No `item_id`, `instance_id`, rarity stats in save

### Config drift

`HeroSystem.get_equipment_power()` hardcodes `[0,2,5,9]` — duplicates `heroes.json` `tier_power_bonus` (not loaded from data).

---

## 3. REWARD PIPELINE

Current `_normalize_reward()` (`RewardPipeline.gd` L167–174): gold, gems, spins, shields, realm_keys only.

**Integration points for item loot:**

| Source | Caller | Today |
|---|---|---|
| Monster/Boss defeat | `MonsterDefeatService` | Currency + boss chest acquire |
| Chest open | `ChestRewardSystem.open_chest()` | Currency via `grant_chest()` |
| Quest | `ObjectiveSystem` | Currency + `chest_tier` |
| Daily/AFK/Spin | respective services | Currency only |

**Boss loot today:** 2 spins + `ChestRewardSystem.acquire_chest("boss")` — no items.

---

## 4. STAT / MODIFIER GAP

Current power stack for heroes:

```
get_power() = base + level_scaling + get_equipment_power() + specialization_bonus
```

Equipment = flat tier table only. **No tap damage from equipment.** No crit/attack-speed modifiers.

**Target V2.07 pipeline:**

```
base → progression → hero → equipment → temporary → final
```

Implement via `StatModifierService` (new) feeding `CombatDamageResolver` and `HeroSystem`.

---

## 5. PLAYER VS HERO EQUIPMENT

Per `heroes.json` `hero_contract`:
- Equipment is **hero-centric** (weapon/charm per hero)
- `no_new_currency: true` — upgrades stay gold-based for tiers
- V2.07: **hero equipment items** primary; player tap weapon as secondary (1 slot max)

**Slots for V2.07 (start small):**

| Slot | Maps to | Gameplay |
|---|---|---|
| `weapon` | sword icon | Tap damage OR hero damage (per item) |
| `accessory` | pendant (= charm) | Hero power / crit |

Defer armor/helmet/boots/ring to data hooks only until V2.08+ unless scope allows 3 slots.

---

## 6. SAVE / MIGRATION

- Current: `SAVE_VERSION = 39`
- Persisted: `hero_system.equipment` (tiers), `chest_rewards`, `reward_pipeline` sequence
- **Not persisted:** item instances, equipped items, loot history
- V2.07 target: `SAVE_VERSION = 40`, new `item_inventory` block, migrate v39 → v40 preserving hero/meta/quest state

---

## 7. UI STATE

| UI | Status |
|---|---|
| `View_Heroes` | Exists — weapon/charm upgrade buttons |
| `View_Inventory` | **Does not exist** |
| Item details / compare | **Missing** |
| Loot presentation | Currency only via `RewardService` |
| Main screen | No permanent inventory bar (correct per master) |

Nav: `HubHeroesP0` uses `ui.nav.inventory` icon — misleading once real bag exists.

---

## 8. PRODUCTION ASSET SUMMARY

See `docs/v207_asset_convergence/item_asset_mapping.md`.

- **22 production assets** ready for inventory UI
- **0 consumables** used in runtime today
- **6/8 equipment icons** shown decoratively on hero screen
- Rarity frames: only `.2` used (all heroes same frame)

---

## 9. RECOMMENDED V2.07 ARCHITECTURE

```
Loot Sources (Boss/Chest/Quest)
    → loot_tables_v207.json
    → RewardPipeline.grant() + items[]
    → ItemInventoryService (instances, equip state)
    → StatModifierService
    → CombatDamageResolver / HeroSystem
    → Save v40
```

**New autoloads:** `ItemInventoryService` (or `ItemSystem` + inventory facade)  
**Keep separate:** `InventoryEntitlementService` (IAP)

---

## 10. ACCEPTANCE CRITERIA (from spec)

V2.07 done when proven loop:

```
Boss/Chest → Item → Inventory → Equip → Stat↑ → Damage↑ → Save → Reload → preserved
```

---

## 11. WORK ORDER (next steps)

1. `data/items_v207.json` + `data/loot_tables_v207.json`
2. `ItemInventoryService` + `StatModifierService`
3. Extend `RewardPipeline` + `EconomyAuthorityService`
4. Boss + chest item drops
5. `View_Inventory` + item detail UI (production assets)
6. Hero equip flow + DPS/tap impact proof
7. Save v40 migration
8. Economy/drop simulation
9. QA extension + APK `RealmAlliance_V2_07_Test.apk`

---

## REMAINING PLACEHOLDERS (carried)

- Hero portraits (V2.06.1)
- Hero equipment preview strip (decorative)
- Bow/staff weapon art

## NEXT

Begin domain implementation: Item catalog + ItemInventoryService + RewardPipeline extension.
