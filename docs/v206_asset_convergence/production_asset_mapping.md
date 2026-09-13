# V2.06 Production Asset Mapping

Audit basis: `data/runtime_art_bindings_v200.json`, `data/MASTER_ASSETLIST_V1_4.csv`, `V2_01_ASSET_RUNTIME_AUDIT.csv`, runtime QA screenshots.

| Runtime Slot | Current Asset | Production Asset Found | Status | Action |
|---|---|---|---|---|
| TAP Background | `BG001_gruenhain_home_v11.png` (scene) | `assets/world/greenvale/BG001_gruenhain_home_v11.png` | PRODUCTION | KEEP |
| Monster M001 | `P0MonsterVisualSystem` states | `assets/monsters/greenvale/states/M001_*.png` | PRODUCTION | KEEP |
| Monster Boss B001 | `P0MonsterVisualSystem` states | `assets/monsters/greenvale/states/B001_*.png` | PRODUCTION | KEEP |
| HUD Gold Pill | `UI015_resource_gold_pill.png` (scene) | `assets/production/ui_v4/resource_bars/*` | LEGACY | REBIND (v4 bars via binder — deferred low risk) |
| HUD Spin Pill | `UI016_resource_spin_pill.png` (scene) | `assets/production/ui_v4/resource_bars/*` | LEGACY | REBIND |
| HUD Shield Pill | `UI017_resource_shield_pill.png` (scene) | `assets/production/ui_v4/resource_bars/*` | LEGACY | REBIND |
| Monster HP (normal) | Runtime binder | `ui.monster.hp.normal` → `monster_boss_hud/small_hp_bar.png` | PRODUCTION | KEEP |
| Monster HP (boss) | Runtime binder | `ui.monster.hp.boss` → `monster_boss_hud/hp_bar.png` | PRODUCTION | KEEP |
| Boss progress bar | Runtime binder | `ui.home.boss_progress` | PRODUCTION | KEEP |
| Bottom Nav icons | Scene + `MobileLayoutOwner` | `assets/production/ui_v4/navigation/*` | PRODUCTION | KEEP |
| SPIN machine frame | `SpinMachineFrame` | `atlas:spin_machine_modular_01` | PRODUCTION | KEEP |
| SPIN symbols | 3-reel atlas | `atlas:spin_symbols_01/*` | PRODUCTION | KEEP |
| SPIN legacy wheel W101–108 | Scene hidden | legacy wheel segments | LEGACY | KEEP hidden |
| Village buildings | `P0VillageVisualSystem` | `assets/village/greenvale/production/*.png` | PRODUCTION | KEEP |
| Village ground | Scene/runtime | `BG001_gruenhain_home_v11.png` | PRODUCTION | KEEP |
| MODI hub tiles | `ScreenUiAssemblyService` | `hub.*` / `ui.nav.*` roles | PRODUCTION | KEEP |
| Quest panels | Runtime binder | `atlas:quest_01/*` + `quest_states/*.png` | PRODUCTION | KEEP |
| Daily emblem | Runtime binder | `objective.daily` / `daily_quest.png` | PRODUCTION | KEEP |
| Chest open sequence | `RewardProgressionVisualDirectorV193` | `v190/rewards/chest_states/*.png` | PRODUCTION | KEEP |
| Chest legacy RW001 | Scene fallback | `assets/rewards/RW001_small_chest.png` | LEGACY | KEEP as fallback |
| AFK overlay | `ScreenUiAssemblyService` | `atlas:afk_01/*` + `ui.afk.*` | PRODUCTION | KEEP |
| Hero mastery icons | `ProductionAssetConvergenceV187` | `V151_001–003` on hero cards | PRODUCTION | KEEP |
| Hero portraits | Not bound | `hero_*_portrait_placeholder.png` | MISSING | NO PRODUCTION MATCH (see asset_needs.md) |
| Hero weapon/charm UI | Runtime binder | `V151_005–006` | PRODUCTION | KEEP |
| Player XP bar | Runtime HUD | production progression bars | PRODUCTION | KEEP |
| Settings icon | Runtime binder | `ui.icon.settings` | PRODUCTION | KEEP |
| Reward overlays | `RewardProgressionVisualDirectorV193` | shared reward panel roles | PRODUCTION | KEEP |
| Legacy Btn_Heroes nav | Scene | hidden | LEGACY | REMOVE visibility (done) |
| Legacy QuickActions | Scene | hidden via layout owner | LEGACY | KEEP hidden |

**Slots audited:** 32 priority runtime slots  
**Production verified:** 24  
**Legacy retained (hidden/fallback):** 5  
**Missing production match:** 1 (hero portraits)
