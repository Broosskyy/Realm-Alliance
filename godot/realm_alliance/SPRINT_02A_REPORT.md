# Sprint 02A — Combat Composition & Animation Foundation

## Intent
Improve readability and scene motion in the Godot 4.7.2 portrait gameplay prototype **without redesigning the five approved REALM ALLIANCE mockups** or replacing the existing React/Vite project. This pass is still *placeholder art*. No borrowed copyrighted artwork is introduced.

## Delivered
- Responsive scene bounds are solved centrally by `RACombatLayout.solve()` for narrow, standard and tall portrait displays. Touch zone stays between the HUD and lower action controls.
- Stage and action UI no longer derive from a hardcoded `height * 0.49` offset.
- Arena touch detection uses an invisible `Control` rather than a flat Godot button, preventing button pressed/hover backgrounds on gameplay taps.
- Hero attack now has wind-up, a body lunge and recovery. The weapon stays parented to `RightArmPivot/WeaponSocket` for all frames.
- Enemy uses an idle breathing motion, hit knockback and death fade. Wave spawning restores the actual character scale instead of mistakenly resetting it to `Vector2.ONE`.
- Enemy HP stays directly above the character, procedural impact arcs/sparks are brief, damage numbers are stronger, and a gold reward floats after a kill.
- No full-screen touch/highlight flashes; `RAImpactFX` draws only in the local hit area.
- Existing CombatModel/save-state format and remote/online boundaries are intentionally unchanged.

## Checks
```bash
godot --headless --path godot/realm_alliance --script res://tests/test_combat.gd
godot --headless --path godot/realm_alliance --script res://tests/test_layout.gd
godot --headless --path godot/realm_alliance --script res://tests/test_visual_contract.gd
godot --headless --path godot/realm_alliance --quit-after 120
```
The branch's GitHub workflow must pass these before publishing fresh Web and Android ARM64 debug artifacts. Logs and runs are authoritative; **do not infer success from this document**.

## Manual mobile QA checklist
- Test at least one tall-phone Android device in both touch combat and UI-button flows.
- Confirm repeated rapid taps trigger no colored rectangular focus/touch overlay.
- Observe stage proportions and HUD/action spacing at device resolution, including camera/safe areas.
- Verify weapon swaps do not disconnect from the moving hand at wind-up, impact or recovery.
- Check each wave transition preserves monster size; bosses should be a little larger, not randomly shrink.
- Check skill impact, HP bar, legible damage numbers and the gold reward notice.
- Save, force-close and reload without duplicated gold or regression in wave/equipment.

## Not delivered yet
- Approved combat master visual parity and true production sprites.
- Hero/armor/skin/wings animation system with actual cut-out sprites.
- Final sound, lighting, accessible UI, combat balance, input latency profiling, gamepad support, online economy, multiplayer.
- A public Web play URL (CI produces downloadable artifacts only).

## Next step
Add the approved, transparent source assets with predictable canvas, origin, body part masks and a hand pivot contract. Compare screenshots frame-by-frame with the master mockup, then perform real mobile QA before merge.
