# V2.06 Visual Issue Register

| Screen | Problem | Severity | Master Rule | Fix | Verification Screenshot |
|---|---|---|---|---|---|
| Main HUD | Gold/Spin/Shield pills still scene-embedded UI015–017 | Low | Production assets first | Deferred v4 resource_bars rebind (no layout regression) | `01_main_1080x2340` |
| Heroes | No dedicated portrait art — V151 mastery icons used on cards | Medium | No fake final heroes | Documented in asset_needs.md; V151 icons bound | `28_hero_collection_locked_*` |
| Heroes | Collection uses button cards not separate portrait grid | Low | Mobile game UI | Existing View_Heroes retained; deploy/level UX deepened | `30_hero_deployed_*` |
| Quest/Daily | Functional V2.05 UI; atlas panels applied | Low | UI Foundation | Verified production quest atlas bindings | `20_quest_initial_*` |
| Boss | Failure/retry overlay present from V2.05 | Info | Boss as highlight | No change required | `14b_boss_failure_*` |
| NAV | Legacy Btn_Heroes hidden; MODI hub entry for heroes | Info | TAP/SPIN/DORF/MODI only | Heroes via HubHeroesP0 when SHOW_HEROES | `09_modes_*` |

Issues marked **Fixed in V2.06 implementation** will be closed after runtime QA PASS screenshots are visually inspected.
