# REALM ALLIANCE V1.97

## Full convergence pass
- Added `FullUiConvergenceV197.gd` as a presentation-only cross-screen convergence layer.
- Normalized safe-area spacing, primary-view container rhythm, overlay sizing, touch targets and minimum copy readability.
- Reasserted the four-tab navigation contract: TAP / SPIN / DORF / MODI; legacy Heroes/Attack/Defense buttons remain hidden.
- Reapplies convergence after viewport changes.
- Removed 15 stale direct placeholder texture ext_resources plus other unused scene ext_resources from `MainGame.tscn`; no active scene reference depended on them.
- No balance, reward, economy, save-schema or authority behavior changed.

## QA
Static QA passes. Runtime/device QA is still required in Godot because the current environment has no Godot executable.
