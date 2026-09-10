# V1.26 DICE / Realm Journey / Treasure Portal QA

1. Primary bottom navigation must remain HOME / SPIN / DORF; V1.26 enters through one `REISE` quick action.
2. Open REISE: Grünhain Journey, Dice count, current node and Treasure Portal must be understandable without another submenu.
3. Roll Dice: exactly one Dice is consumed and movement is 1–6 nodes.
4. Landing reward is granted exactly once and matches the displayed result.
5. Exhaust Dice: WÜRFELN becomes unavailable without changing position/reward.
6. Defeat B001 while feature is active: +1 Dice, respecting configured cap.
7. Cross node 12: lap counter increases and exactly one Portal charge is added.
8. Open Treasure Portal: one charge is consumed and configured Gold/Spin reward is granted once.
9. Force-close/relaunch after roll and after Portal reward: position, Dice, laps and Portal charges persist.
10. Reduced Motion must not alter roll/reward results.
11. Regression-check HOME/TAP, SPIN, DORF/BUILD and Grünhain combat.
12. Confirm Events, Rankings and Realm Chest remain hidden until V1.27.

Hard fail: unlimited duplicate rewards, movement without Dice cost, Portal opening without charge, save drift, or added primary navigation clutter.
