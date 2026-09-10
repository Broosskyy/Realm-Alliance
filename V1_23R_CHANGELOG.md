# REALM ALLIANCE V1.23R — 3-Reel SPIN Source Realignment

- Game-source-only pass; website artifacts removed from this package.
- Legacy circular wheel runtime presentation replaced by a 3-reel REALM SPIN machine foundation.
- Existing eight reward families and weighted economy remain compatible.
- New config: `data/spin_3reel_v2_0.json`.
- `WheelSystem.spin()` remains API-compatible but now returns `reel_stops`, `payline_reel` and `presentation`.
- `spin_request` / `spin_result` telemetry upgraded to config `v2.0-3reel-p0-01`.
- Round-wheel rotation, pointer and center-angle presentation are no longer used by MainGame.
- Temporary machine/reel/payline assets are clearly named `*_placeholder`; they are integration scaffolding only.
- Final art must be produced as clean modular assets per Master V2.0.
- Save schema remains V20. Existing V1.23 saves are not intentionally invalidated.
- Next gate: real-device Godot/Android test, then final 3-reel art integration before V1.24 Village.
