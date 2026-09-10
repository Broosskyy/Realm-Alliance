# REALM ALLIANCE SOURCE V1.20
## P0 RELEASE ISOLATION / HIDDEN-P1 RUNTIME DECOUPLING — Master V1.4

No assets added. No P1 enabled. No gameplay expansion.

- MainGame no longer wires Heroes, Attack, Defense, Daily or Quest runtime signals/buttons unconditionally.
- Optional P1 runtime wiring is now centralized in `_setup_optional_p1_runtime()` and guarded by FeatureFlags.
- HeroSystem processing is fully disabled while `ENABLE_HERO_AUTODPS` is false.
- LaneAttackSystem and TowerDefenseSystem now explicitly start with processing disabled and only activate when started.
- P0BootDiagnostics now fails if hidden Hero/Attack/Defense systems are processing during P0 boot.
- Existing P1 code stays in source for later phases, but the P0 runtime is more isolated from it.
- Build metadata updated to V1.20 / build 30.
