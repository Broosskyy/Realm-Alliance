# V1.33 Region Progression QA

1. HOME shows current region Grünhain and next-region progress.
2. Frostmark target comes from existing `regions.json` and remains Account Lv.20.
3. Progress derives from account level; no second source of truth is saved.
4. Before Lv.20 Frostmark remains locked.
5. At Lv.20 Frostmark reports unlocked and emits region-unlocked telemetry.
6. No Frostmark combat/content is silently substituted with Grünhain content.
7. HOME / SPIN / DORF primary navigation remains unchanged.
8. Daily, Quests, Heroes, Lane Battle, Tower Defense, Puzzle, META, Journey, Village, Combat and SPIN regressions remain green.
9. Save Schema stays V20.
10. Frostmark final art/content remains a later production block.

Hard fail: invented Frostmark economy/content, altered unlock level, navigation bloat, or regression of prior blocks.
