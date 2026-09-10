# V1.48 Grünhain Puzzle V2 QA

Static acceptance:
- Existing deterministic 3×3 Puzzle core remains in place.
- UTC daily attempt reset remains in place.
- Eight stage profiles are data-driven.
- Current stage controls the target number of matches.
- Puzzle Mastery levels are capped at 5 and use data-driven thresholds.
- Match XP and completion XP are booked before SaveGame persists the completed state.
- Completion result contains a unique completion_id and pending-presentation flag.
- Pending completion restores presentation without re-granting Gold/Spins.
- Unclaimed lower Mastery rewards remain claimable.
- AFK overlay does not supersede pending Spin/Journey/Puzzle presentation.
- Save load order restores PuzzleProgression before PuzzleSystem so stage-specific target clamping is correct.
- Placeholder kit contains exactly 8 isolated transparent 768×768 assets.
- Save Schema remains V20.

Still pending:
- Real Godot executable/parser validation in this environment.
- Physical Android visual QA.
- Final production/Recraft art replacement.
- Later blockers, boosters and larger puzzle board variants.
