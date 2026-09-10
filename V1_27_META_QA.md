# V1.27 Meta Vertical Slice QA

1. Primary bottom navigation remains HOME / SPIN / DORF.
2. Quick actions expose REISE and META without Daily/Quest/Hero/Attack/Defense clutter.
3. META opens one screen containing Event, Ranking and Realm Chest.
4. Grünhain-Jagd begins at 0/3 bosses.
5. Defeating B001 increments event progress and ranking score exactly once.
6. At 3/3, Event reward becomes claimable; claiming saves immediately and cannot be repeated after relaunch.
7. Boss defeat grants configured Realm Key(s).
8. Completing a Realm Journey lap grants configured Realm Key(s).
9. Realm Chest remains disabled below required keys.
10. Opening Realm Chest consumes exactly required keys, grants reward once, saves immediately and increments opened count.
11. Relaunch after event/chest reward: no duplicate reward and state is retained.
12. Ranking identifies DU and reflects persistent boss-defeat count; treat other rows as local demo data, not online ranking.
13. Regression-check HOME/TAP, SPIN, BUILD, Combat, DICE/Journey and Treasure Portal.
14. Puzzle, Tower Defense and Lane Battle remain outside V1.27.

Hard fail: repeatable event claim, chest reward without key consumption, duplicate boss progress, save drift, or online-ranking claims from placeholder data.
