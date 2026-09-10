# V1.24 Village QA Gate

1. Open BUILD: Grünhain ground must be visible behind the four building choices.
2. Townhall, Goldmine, Forge and Luck Temple must all be readable/tappable.
3. Open each upgrade: modal shows stage 1, 2 and 3 simultaneously.
4. Current stage is visually stronger; future stages remain visible but de-emphasized.
5. Upgrade each building from 1→2 and 2→3: art changes immediately and feedback pulse plays.
6. Stage 3 displays MAX and cannot charge Gold again.
7. Insufficient Gold must never change level or art.
8. Goldmine production/claim still works through save/resume.
9. Forge/Townhall/Luck Temple effects remain unchanged from existing P0 rules.
10. TAP and SPIN navigation/save remain regression-free.

Hard fail: missing ground, any building without all 3 stage assets, upgrade charged without level change, wrong displayed stage, or Save Schema drift.
