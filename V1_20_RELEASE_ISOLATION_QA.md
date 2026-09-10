# V1.20 P0 RELEASE ISOLATION QA

Expected P0 boot:
- Home / Rad / Dorf only.
- HeroSystem processing = false.
- LaneAttackSystem processing = false.
- TowerDefenseSystem processing = false.
- No Daily/Quest/Hero/Attack/Defense signal wiring unless a corresponding feature flag is intentionally enabled.
- Boot diagnostics must remain PASS.

This pass intentionally does not delete P1 systems. It makes the current P0 build dormant with respect to them, reducing accidental balance mutations, background processing and startup coupling before the first real device run.
