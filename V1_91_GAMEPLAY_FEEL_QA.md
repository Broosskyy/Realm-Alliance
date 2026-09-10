# V1.91 Gameplay Feel QA

Static QA status: PASS.

Validated:
- V1.91 registry JSON parses and all non-hold bound assets resolve in the production registry.
- MainGame hooks exist for TAP hit, defeat, SPIN motion/stop/win/jackpot and TD projectile/impact presentation.
- VFX service is presentation-only and contains no reward, damage, odds or economy mutation.
- Grünhain decoration uses production asset IDs and mouse-filter ignore.
- Source version/build are 1.91 / 91.

Runtime/device QA: NOT EXECUTED because a Godot executable is not available in this environment. Visual scale, clipping and final timing should therefore be verified in the next Godot/device run.
