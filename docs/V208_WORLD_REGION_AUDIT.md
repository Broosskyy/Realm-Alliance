# V2.08 World / Region Audit

## Classification Summary

| Component | Verdict | Notes |
|---|---|---|
| `RegionProgressionSystem` + `regions.json` | **DEEPEN** | V2.08 catalog schema + player state |
| `P0MonsterVisualSystem` + `encounters_greenvale_*` | **DEEPEN** | Region-parameterized catalog loading |
| `EncounterProgressService` | **DEEPEN** | Fixed active-region bug; elite/tough labels |
| `MonsterDefeatService` | **KEEP** | Records region progress on defeat |
| `BossChallengeSystem` | **KEEP** | Region-agnostic boss timer |
| `MonsterCatalog` + `monsters.json` | **LEGACY** | Superseded; boss intro migrated to P0 |
| `LootTableService` | **DEEPEN** | Region-scoped sources (`greenvale_boss`, etc.) |
| `RewardPipeline` | **KEEP** | Uses region loot resolver |
| `SaveGame` v41 | **DEEPEN** | `region_progression` block |
| Frostmark | **PLACEHOLDER** | Unlock preview only |
| World/Map UI | **FUTURE** | Compact region progress panel sufficient for V2.08 |
| `MonsterAssetResolver` | **UNUSED** | Safe removal candidate |

## Grünhain Status

- **14 normal monsters** (M001–M014) in rotation with distinct production assets
- **3 bosses** (B001–B003) every 10 kills
- **Region background** BG001 production-bound
- **Loot** Grünhain-scoped via `greenvale_*` loot sources
- **Classification** normal / tough / elite / boss in encounter catalog

## Gaps Closed in V2.08

1. Region catalog drives encounter path, asset root, background, loot
2. Combat region authority separate from account-unlock preview (Frostmark Lv.20)
3. Encounter progress shows correct region name at all account levels
4. Monster rotation proven with different `monster_id` + assets
5. Region progress persisted in save v41

## Master Concept Alignment

Aligned with `V1_33_REGION_PROGRESSION_QA.md`, `V1_59_ASSET_DECISIONS.md`, and `encounters_greenvale_p0_v1_4.json` as authoritative encounter content. No parallel world architecture introduced.
