# REALM ALLIANCE V2.00 — Alpha Vertical Slice / Final Pre-APK Run

V2.00 is the final source-convergence run before APK/device testing.

- Added `FinalAlphaConvergenceV200.gd` as a presentation-only final convergence layer.
- REALM SPIN now derives Reel1/Reel2/Reel3, payline, win-line and machine-frame geometry from the actual runtime view size instead of relying only on legacy fixed 1080-style offsets.
- Grünhain village ambient composition is view-relative and deliberately layered below the building grid while selection feedback stays above it.
- Transient monster presentation is normalized on convergence to reduce stale defeat/hit transform carry-over.
- Four-tab navigation is re-enforced as TAP / SPIN / DORF / MODI; legacy Heroes/Attack/Defense bottom-menu nodes are hidden in the scene itself to prevent first-frame flashes.
- Runtime production-art bindings were versioned to `runtime_art_bindings_v200.json`; production registry now loads the V2.00 binding snapshot.
- Full static asset integrity pass verifies all literal resources, images, JSON, registry entries, atlas regions and active production bindings.
- Source version `2.00`, Build `#200`; save schema remains `35`.
- Gameplay/economy/reward/online authority was not changed by the V2.00 presentation layer.
- Godot runtime, Android export and device QA remain intentionally pending because the current environment has no Godot executable.
