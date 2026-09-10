# REALM ALLIANCE V1.49 — Tower Defense V2

- Deepened Tower Defense as the next major gameplay pillar.
- Replaced the inherited misuse of the bottom navigation DEFENSE button as the in-run fight action with a dedicated `TDFightButtonP0`.
- Added six data-driven Grünhain Defense campaign stages with increasing enemy HP bonuses.
- Added Defense Mastery levels 1–5 with XP from cleared waves and completed runs.
- Added permanent Tower-Tech levels 1–4, paid with existing Gold, increasing tower damage without introducing another permanent currency.
- Added claimable Defense Mastery rewards with lower unclaimed rewards preserved.
- Added `td-run-result-v1` authoritative completion contract with unique `run_id`, stage, rewards, Mastery XP and pending presentation.
- Run progression and rewards are booked before save; pending completion can be restored without double granting.
- Added dedicated restart/next-stage flow after a completed Defense run.
- Added stage, mastery, tower-tech and completed-run state to the global Progression Hub.
- Halloween LiveOps now also accepts cleared Tower Defense waves as a seasonal activity source.
- Updated UI polish for dedicated Defense action buttons.
- Added exactly 8 large 768×768 transparent, isolated and replaceable Tower Defense placeholder assets.
- Added explicit V1.49 asset swap map.
- Save Schema remains V20.
