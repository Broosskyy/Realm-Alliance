# V2.07 Item & Equipment Asset Mapping (Phase 2)

Runtime-verified bindings for inventory, equip flow, hero slots, and loot presentation.

| UI Surface | Semantic Role | Production Asset | Rarity Frame | Status |
|---|---|---|---|---|
| Feature Hub · Inventar | `ui.nav.inventory` | `v4.ui.navigation.inventory` | — | BOUND |
| Feature Hub · Helden | `ui.nav.combat` | navigation combat icon | — | REBOUND (was inventory) |
| Inventory card | per-item `icon_asset` | sword / axe / ring / pendant | `ui.slot.rarity.1–4` by rarity | BOUND |
| Inventory detail icon | per-item `icon_asset` | same as card | rarity backdrop | BOUND |
| Hero item weapon slot | equipped weapon `icon_asset` | sword / axe | rarity frame | BOUND |
| Hero item accessory slot | equipped accessory `icon_asset` | ring / pendant | rarity frame | BOUND |
| Monster/Boss reward text | granted item summary | icon via data + text lines | rarity label in text | BOUND |
| Quest chest reward modal | `granted_items` payload | item name + rarity | text | BOUND |
| Legacy tier weapon button | `ui.inventory.equipment.sword` | tier upgrade (gold) | secondary button | KEEP (legacy tier) |
| Legacy tier charm button | `ui.inventory.equipment.pendant` | tier upgrade (gold) | secondary button | KEEP (legacy tier) |
| Hero portrait | placeholder | documented placeholder | — | PLACEHOLDER |

## Item → Icon → Rarity

| item_id | Name | Slot | Icon Role | Rarity Frame |
|---|---|---|---|---|
| `wpn_gruenhain_blade` | Grünhain-Klinge | weapon | `ui.inventory.equipment.sword` | `ui.slot.rarity.1` |
| `wpn_battle_axe` | Kampfaxt | weapon | `ui.inventory.equipment.axe` | `ui.slot.rarity.2` |
| `acc_silver_ring` | Silberring | accessory | `ui.inventory.equipment.ring` | `ui.slot.rarity.1` |
| `acc_guardian_pendant` | Wächter-Anhänger | accessory | `ui.inventory.equipment.pendant` | `ui.slot.rarity.3` |

## Stat contribution split (no double-apply)

| Source | Affects | Applied in |
|---|---|---|
| Hero base + level | `get_power()` base | `HeroSystem` |
| Legacy weapon/charm tier `[0,2,5,9]` | flat power display + hero base | `HeroSystem.get_legacy_tier_power()` |
| Item `hero_damage` flat/% | combat hero hits | `StatModifierService` → `CombatDamageResolver` |
| Item `tap_damage` flat/% | tap hits | `StatModifierService` → `CombatDamageResolver.resolve_tap()` |
| Item `crit_chance` | tap crit | `CombatDamageResolver.resolve_tap()` |
| Item `boss_damage` % | hero hits vs boss | `StatModifierService.apply_damage_modifiers()` |
