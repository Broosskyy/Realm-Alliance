# V1.28 Puzzle QA

1. PUZZLE appears as a Quick Action; HOME / SPIN / DORF remain primary.
2. Puzzle opens as a readable 3×3 board in portrait.
3. First tap selects a cell; second non-adjacent tap moves selection.
4. Adjacent invalid swap reverts and does not consume an attempt.
5. Valid horizontal/vertical 3-match consumes exactly one attempt.
6. Three valid matches grant configured reward exactly once and reset objective progress.
7. Force-close/relaunch retains board, attempts and match progress.
8. Reduced Motion does not alter board/result logic.
9. Zero attempts disables cells and never grants a reward.
10. Regression-check SPIN, Village, Combat, Journey, Portal and META.
11. Current simple glyphs must be treated as placeholders pending final individual Puzzle assets.
12. Tower Defense and Lane Battle must not be exposed by this pass.

Hard fail: reward without three valid matches, invalid swap consuming attempt, duplicate completion reward, board save drift, or primary navigation clutter.
