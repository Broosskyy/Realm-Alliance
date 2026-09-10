# V1.56 Production Art QA

## Automated
- Registry and binding IDs must resolve.
- Project version must be 1.56.
- MainGame must contain live production-art binding markers.
- Spin symbol atlas path must retain legacy fallback for safety.

## Device visual QA
1. Quests: verify row frames do not crop text/buttons and state changes retain the correct art.
2. Shop: verify featured atlas frame remains behind dynamic catalog text.
3. AFK: verify summary and claim art scale without border distortion.
4. Progression: verify overview panel remains readable on 1080x1920 and narrow devices.
5. Rankings: verify tabs remain tappable and text stays above atlas art.
6. Spin: verify all eight new reward symbols render cleanly, payline aligns to middle row, ready/disabled button art swaps without stacking.
7. Confirm that no black/white baked atlas background appears in runtime.

## Lock
Do not replace the full Spin machine frame with an ambiguous atlas region until a visual device pass confirms exact geometry.

## Visual registry corrections completed
- Progression node order corrected to Standard / Locked / Available / Completed.
- AFK standard/bonus reward slots corrected.
- Itemshop price container / offer badge corrected.
- Leaderboard long row / small reward-alert container corrected.
- Spin symbols corrected by visual source-sheet position: Gold, Crystals, XP, Energy, Chest, Materials, Realm Token, Rare Bonus.
