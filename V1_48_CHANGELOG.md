# REALM ALLIANCE V1.48 — Grünhain Puzzle V2

- Deepened Puzzle as a full gameplay pillar after Realm Journey V2.
- Preserved the deterministic 3×3 swap/match core and UTC daily-attempt reset.
- Added an 8-stage Grünhain Puzzle progression with data-driven stage names and target-match counts.
- Added Puzzle Mastery levels 1–5 with XP from matches and completed puzzle stages.
- Added claimable Puzzle Mastery rewards with no skipped lower-level reward loss.
- Added a structured `puzzle-complete-v1` completion contract with `completion_id`, stage, rewards, config version and pending presentation.
- Puzzle completion reward/progression is booked before save; pending completion can be re-presented after resume without granting rewards twice.
- Added boot restore for pending Puzzle completion; AFK reward presentation waits behind pending Spin/Journey/Puzzle results.
- Puzzle UI now shows stage identity, dynamic target, Mastery XP/bar and Mastery reward CTA.
- Global Progression Hub now reflects Puzzle stage, Mastery and completed runs.
- Fixed inherited Journey and new Puzzle signal-connection indentation in MainGame.
- Added exactly 8 large 768×768 transparent, isolated and replaceable Puzzle placeholder assets.
- Added explicit V1.48 asset swap map.
- Save Schema remains V20.
