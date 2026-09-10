# V1.32 Daily + Quests QA

1. TAGESBONUS and AUFGABEN appear in Quick Actions; HOME / SPIN / DORF remain unchanged.
2. Daily view shows current cycle position and current reward.
3. First eligible Daily claim grants exactly the configured reward and immediately saves.
4. A second Daily claim on the same UTC calendar day is rejected.
5. Relaunch after a Daily claim keeps the day claimed and cannot duplicate the reward.
6. Seven successful claims advance through the configured seven-step cycle and wrap.
7. Existing Daily reward values remain identical to the pre-V1.32 source values.
8. AUFGABEN shows all three existing starter quests with progress and claim state.
9. Monster taps increment `tap_10` exactly once per valid tap.
10. Successful authoritative Realm Spins increment `spin_3` exactly once.
11. A successful qualifying upgrade increments `upgrade_1`; the legacy Town Hall path must not double-count one upgrade.
12. Quest reward can only be claimed after target completion and only once.
13. Relaunch retains quest progress and claimed IDs.
14. Reward modal shows Daily/Quest rewards through the existing RewardService path.
15. Regression-check Heroes, Lane Battle, Tower Defense, Puzzle, META, Journey, Combat, Village and SPIN.
16. Current Daily/Quest art remains integration art pending final visual production.

Hard fail: duplicate Daily reward, `claim_reward()` runtime reference, missing SPIN quest progress, duplicated upgrade progress, repeatable quest claim, or primary-navigation clutter.
