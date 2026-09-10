# REALM ALLIANCE V1.40 — Deterministic SPIN Result Contract

- Hardened the 3-reel SPIN result path around the V2.0 master lock.
- Added explicit result fields: `result_id`, `reward_id`, `reward_type`, `reward_value`, `config_version`, `outcome_seed`, `visual_seed`, `reel_stops`, `reel_stop_ids`, `outcomes`, `visual_symbol_id`, `visual_symbol_index`.
- `segment_id`, `segment_index`, `type` and `amount` remain only as compatibility aliases.
- Reward authority order is now explicit: weighted reward selection → single grant → persisted pending result → visual reel presentation.
- Weighted choice and variable Gold amount now use one stored per-spin `RandomNumberGenerator` seed.
- Reel transient animation no longer calls `randi_range`; presentation frames are deterministically derived from `visual_seed`.
- Resume-safe pending results preserve the final stops and visual seed.
- Pre-V1.40 pending result payloads are normalized without granting rewards again.
- Full-Shield fallback now presents a Gold symbol instead of visually claiming a Shield that was not awarded.
- Reward overlay icon now follows `visual_symbol_index`, keeping overlay, payline and booked reward presentation aligned.
- SPIN config advanced to `v2.0-3reel-p0-06` with a machine-readable result contract.
- Added exactly six replaceable SPIN-contract placeholder assets.
- Save Schema stays V20.
- No new economy values were introduced.
