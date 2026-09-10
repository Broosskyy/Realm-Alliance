# V1.29 Tower Defense QA

1. DEFENSE is exposed through Quick Actions, not primary bottom navigation.
2. Open DEFENSE: wave, enemy HP, towers and energy are visible without submenus.
3. Building a tower consumes exactly configured energy.
4. Tower cap is enforced and building below required energy is blocked.
5. Defend is blocked with zero towers.
6. Each defend action applies deterministic tower damage exactly once.
7. Clearing wave 1/2 advances to the next wave and grants configured inter-wave energy.
8. Clearing wave 3 grants the run reward exactly once and locks further defend actions.
9. Relaunch mid-wave retains wave, enemy HP, towers and energy.
10. Relaunch after completion cannot duplicate the completion reward.
11. Regression-check Puzzle and all V1.23–V1.27 systems.
12. Current glyphs are placeholders; do not treat them as final TD assets.
13. Lane Battle remains disabled.

Hard fail: free tower construction, reward before final wave, repeatable completion reward, save drift, or primary-navigation clutter.
