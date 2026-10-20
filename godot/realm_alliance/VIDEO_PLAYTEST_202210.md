# REALM ALLIANCE Godot — Android video playtest (202210.mp4)

Review date: 2026-10-10. Source: 24s portrait Android screen recording supplied in conversation; video file is NOT copied to this public repository.

## Verified visually in the recording
- APK boots and renders Godot stage.
- Wave 3 through wave 6 progression visible.
- Auto-attacks produce enemy damage and gold/kills increment.
- User toggles AUTO off and on.
- Skill shows cooldown.
- Weapon switches Iron → Crystal → Ember and damage value updates.
- Upgrades modify player damage and purchase cost.
- No obvious fullscreen touch ripple in reviewed samples.

## Observed limitations
1. On a tall mobile aspect ratio, large empty top/bottom regions visually separate stage from HUD. This is also reproducible in the layout math of `scripts/main.gd`.
2. Character movement consists mostly of arm-angle swing and idle bob; enemy is a static silhouette with flash/death scale. This is technical placeholder art, not production character animation.
3. Damage feedback is modest, enemy HP was only textual, and bosses share normal placeholder enemy geometry.
4. Current layout has no production navigation, avatar/equipment preview, biome scene art, responsive master-screen hierarchy or server-authoritative state.

## Immediate non-destructive POC fixes on this branch
- Extend background plate for taller portrait devices.
- Increase hero/enemy size moderately while preserving left/right anchors.
- Draw enemy HP bar in scene, with boss color variation.
- Enlarge damage popup.
- Leave gameplay math, public React V2 build, remote storage and mockups untouched.

## Production quality gate
Do NOT consider this a final mockup match. Next release gate requires real REALM art, distinct monster states (Idle/Attack/Hit/Defeated), a modular hero with consistent exported equipment layers, tested phone viewport safe areas, impact VFX, functional UX and real device regression testing. The current CI validates parser/model/build and headless scene only.
