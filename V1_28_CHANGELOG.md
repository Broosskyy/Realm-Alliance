# REALM ALLIANCE V1.28 — Grünhain Puzzle Vertical Slice

- Added a lean 3×3 Grünhain Puzzle surface through the existing Quick Actions layer.
- Puzzle does not add another primary bottom-navigation item.
- Tap two adjacent cells to swap; only a resulting horizontal/vertical 3-match is accepted.
- Invalid swaps are reverted without consuming an attempt.
- Valid matches consume one attempt and advance persistent Puzzle progress.
- Three valid matches complete the current Puzzle objective and grant the configured reward once.
- Board, attempts, match progress and deterministic refill seed persist in Save Schema V20.
- Refill is deterministic within the saved session; no hidden near-miss manipulation.
- V1.23–V1.27 systems remain preserved.
- Tower Defense and Lane Battle remain disabled/not exposed until their later vertical slices.
- Current glyphs are runtime integration symbols, not final Puzzle art.
- Website remains excluded.
