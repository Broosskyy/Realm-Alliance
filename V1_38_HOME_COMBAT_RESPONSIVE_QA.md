# V1.38 Home / Combat / Responsive QA

1. Monster header is produced by one shared helper and does not lose MONSTER/BOSS context during visual refresh.
2. HOME remains immediately understandable: monster → tap → reward → Realm Spin → progression.
3. HP bar remains centered and readable on portrait layouts.
4. Damage numbers do not rely on random placement.
5. Reduced Motion skips the reward-pulse scale animation.
6. Spin reel center derives from viewport width; no hard-coded `center_x := 540.0` remains.
7. Payline and win-line bounds derive from viewport width.
8. Small profile reduces resource-pill and Settings-button minimum sizes.
9. Feature Hub, Account, Social, Support and Settings overlays are included in responsive fitting.
10. HOME / SPIN / DORF remain primary navigation.
11. Six HOME/HUD placeholder assets exist and are explicitly non-final.
12. Save Schema remains V20.
13. No website artifacts are introduced.
14. Existing V1.37 navigation hierarchy remains intact.

Device caveat: static QA cannot prove real Android safe-area, font wrapping, texture filtering or touch ergonomics. Those remain device-test gates.
