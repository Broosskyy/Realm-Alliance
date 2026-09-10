# V1.25 Grünhain Combat QA

1. Verify encounter rotation M001 → M002 → M003 → M004 and repeat until level 10.
2. Verify M002, M003 and M004 have visibly distinct idle silhouettes.
3. Tap each monster: hit state appears, damage feedback remains readable, HP decreases once.
4. Defeat each: defeat state appears before reward presentation.
5. At three encounters before level 10, boss proximity messaging becomes visible.
6. Level 10 must resolve to B001 Mooskönig.
7. B001 must use larger boss presentation plus shield state and boss defeat feedback.
8. Boss reward/bonus Spins must book exactly once before cosmetic waits.
9. Force-close after kill transaction and relaunch: no duplicate reward and next encounter is retained.
10. Reduced Motion must shorten state animations without changing damage, reward or encounter sequence.
11. Regression-check SPIN and BUILD navigation.
12. Confirm no legacy slime naming is shown for M001; canonical name is Waldwinzling.

Hard fail: missing M002/M003/M004/B001 state asset, duplicate kill reward, wrong level-10 boss, HP/reward mismatch, or Save Schema drift.
