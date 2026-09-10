REALM ALLIANCE V1.59 · MASTER V2.1 · CANONICAL ASSET INTEGRATION

V1.59 replaces guessed/debug-style visual composition with canonical production-asset mapping.
- 14 normal Greenvale monsters + 3 rotating bosses bound with Idle/Attack/Hit/Defeat states.
- High-confidence Village art mapped from V4; Goldmine remains medium-confidence and is documented as a polish gap.
- Secondary mode buttons are collapsed behind one MODI entry, preserving TAP/SPIN/DORF as the persistent core.
- Legacy TapPrompt/Progress art is hidden where runtime text already communicates the state.
- Canonical asset catalog added; exact duplicates audited without destructive deletion.

REALM ALLIANCE V1.58 · MASTER V2.1 · FULL VISUAL INTEGRATION & CALIBRATION

V1.58 extends the V1.57 copy calibration and V1.56 production-atlas binding.
The pass focuses on actual runtime surfaces instead of generating more generic UI art:
Home/TAP hierarchy, verified 3-reel SPIN housing, monster HP presentation, Village/Feature-Hub
spacing, modal stacks, Quest spacing, player-facing shop copy, and responsive re-application.

Production principles:
- Master concept V2.1 is authoritative.
- 3-reel REALM SPIN replaces legacy wheel presentation.
- Existing production atlases are reused; no unnecessary duplicate PNG extraction.
- Runtime text/icons/data stay engine-owned and are not baked into atlas art.
- Unverified Village/monster mappings remain conservative until visual QA confirms them.

See:
- V1_58_CHANGELOG.md
- V1_58_FULL_VISUAL_QA.md
- ScreenVisualCalibration.gd
- data/runtime_art_bindings_v158.json
- data/ui_copy_glossary_v158.json
- docs/V1_58_SCREEN_CALIBRATION_BOARD.png

V1.60 AUTOMATED ASSET PIPELINE
- Open the project in Godot: the enabled REALM Asset Pipeline editor plugin generates a scan report.
- Or run tools/run_asset_pipeline.bat / tools/run_asset_pipeline.sh after adding assets.
- Do not delete duplicates manually. Exact duplicates are recorded as aliases and production/non-placeholder paths win.
- Visible labels stay in Godot/runtime; do not bake German/English text into reusable frame assets.
- High-confidence semantic bindings may be applied automatically; medium remains reviewable; low/hold is never forced live.


V1.61 SCREEN AUTO-COMPOSITION
- Home/TAP, REALM SPIN and Village are now laid out through ScreenCompositionService.
- Primary persistent navigation is TAP / SPIN / DORF / MODI. QuickActions no longer consumes permanent vertical space.
- Existing production assets only; no invented art.
- Village building text is separated from art to prevent overlap.
- Normalized anchors reduce device-specific overlap.
