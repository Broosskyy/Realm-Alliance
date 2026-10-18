# Work 6.7 — rebuilt implementation; visual/build gates pending

The interrupted draft was lost in the environment restart. It has now been reconstructed on the verified Work 6.6 source. The 24 true-alpha hero/companion assets, normalization manifest and exact imagegen prompts are secured separately in commit 76ea5f223fdf17b6d251a9923962dc353931d985.

Implemented: owned hero roster with independent training after first collection unlock; canonical guardian retained; Kaela rune tank, true block healing and class skill definitions; two companions with model-clock windup/cooldowns and separate actor/action IDs; actual damage or bounded healing; combat XP and paid evolution with distinct art; per-pose modular weapon/equipment sockets; interactive collection and confirmation before a new run. Switching never heals a running boss encounter; it begins the region again. Account XP, existing saves, inventory and appearance domains remain compatible.

Local gates: 1,024 existing checks plus 84 new roster/companion checks. Dedicated tests cover real costs and duplicate rejection, individual XP, class stats, block-only heal, deterministic partial pet action JSON reload, no resource/charge farming, death/transition cancellation, evolved effectiveness/art, unknown-schema read-only protection, pose/sword layer checks and four touch viewports.

Visual scene review, actual exported-browser progression and final Web/Android exports are pending. This is an implementation checkpoint, not an accepted 6.7 release. 6.8–7.0 and online systems are not claimed complete. Main and Game Factory remain untouched.
