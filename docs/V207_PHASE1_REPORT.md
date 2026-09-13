# REALM ALLIANCE — V2.07 PHASE 1 REPORT

**Milestone:** V2.07.0 Phase 1 (build 2070)  
**Basis:** V2.06.1 PASS  
**Scope:** Item catalog + inventory domain + RewardPipeline items  
**APK:** Not exported (Phase 1)

---

## STATUS

**PASS** — 12/12 domain tests (static + Godot runtime)

Report: `docs/v207_phase1_domain_qa/domain_qa_report.json`

---

## ITEM CATALOG

- File: `data/items_v207.json`
- Items: 4 (weapon ×2, accessory ×2)
- Rarities: common, uncommon, rare (+ epic valid in schema)
- Slots: weapon, accessory
- Production icons: sword, axe, ring, pendant

---

## ITEM INSTANCE MODEL

Instance fields: `instance_id`, `item_id`, `acquired_source`, `acquired_at`, `equipped`, `equipped_to`, `slot`, `enhancement_level`

Equipment is instance-based; stackables deferred.

---

## ITEM INVENTORY SERVICE

- `ItemInventoryService.gd` (autoload)
- Grant, idempotency, equip/unequip foundation, save/load

---

## REWARD PIPELINE EXTENSION

- `_normalize_reward()` validates items
- `grant()` grants currency then items via `ItemInventoryService.grant_from_transaction()`
- Result includes `granted_items`, `instance_ids`, inventory before/after

---

## LOOT TABLES

- `data/loot_tables_v207.json`
- Sources: `normal_monster`, `boss`, `chest_common`, `chest_rare`, `chest_boss`
- `LootTableService.gd` with QA forced-roll hook

---

## BOSS/CHEST INTEGRATION

- Boss defeat: `grant_monster_defeat(is_boss=true)` rolls `boss` loot table
- Chest open: `_reward_for_tier()` rolls `chest_{tier}` loot table
- Both flow through `RewardPipeline` only

---

## STAT MODIFIER FOUNDATION

- `StatModifierService.gd` — modifier contract + flat/percent aggregation stubs

---

## SAVE V40

- `SAVE_VERSION = 40`
- Block: `item_inventory` with instances, equipped map, grant idempotency metadata

---

## MIGRATION

- V39 saves load with empty `item_inventory`
- Hero weapon/charm tiers unchanged (no tier→item migration in Phase 1)

---

## PRODUCTION ASSETS

All 4 catalog items bind to existing `ui.inventory.equipment.*` roles.

---

## DOMAIN TESTS

- Static: `tools/validate_v207_item_domain.py`
- Runtime: `V207ItemDomainQaHost.tscn`

---

## READY FOR PHASE 2

- Inventory UI (`View_Inventory`)
- Equip flow UI
- `StatModifierService` → `CombatDamageResolver` / `HeroSystem` impact
- Hero equipment integration
- Full visual QA + APK
