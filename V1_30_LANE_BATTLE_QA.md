# V1.30 Lane Battle QA

1. LANE BATTLE appears only in Quick Actions; primary HOME / SPIN / DORF navigation remains unchanged.
2. Opening a fresh battle starts a 45-second two-lane run with full configured energy and HP.
3. Left/Right deployment consumes exactly configured energy.
4. Deployment is blocked when energy is insufficient.
5. Energy regenerates over time and never exceeds the configured maximum.
6. Left and right lane pressure update independently.
7. Enemy/player HP change deterministically while the run is active.
8. Force-close/relaunch during a run restores active state, timer, HP, energy, lane power and push.
9. Reopening LANE BATTLE while a saved run is active resumes it instead of starting a fresh run.
10. Win grants configured Gold/XP once and immediately saves.
11. Relaunch after a win cannot duplicate the win reward.
12. Loss grants no win reward.
13. Reduced Motion does not alter battle results.
14. Regression-check Tower Defense, Puzzle, META, Journey, Combat, Village and SPIN.
15. Existing lane graphics remain integration art pending the later final-art pass.

Hard fail: free deployment, duplicate completion reward, active run reset on reopen, save/resume drift, or extra primary-nav clutter.
