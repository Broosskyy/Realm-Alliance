# REALM ALLIANCE — Canonical Hero / Sword / VFX Contract (2026-10-16)

## Original visual master is authoritative
The selected **canonical hero** is the *white-haired, black-face-masked Realmwächter* in black/gold fantasy armor with a long blue-violet cape, as presented in the **original extracted asset overlay** (user reference `203101.jpg`).

**Do not substitute the later brown-haired anime knight, or reinterpret costume proportions, hair, mask, cape or armor on a new sprite sheet.** This is a visual identity lock for the combat demo.

## Required art separation
1. Hero PNGs: `idle`, `ready`, `windup`, `attack_contact`, `recovery`, `hit`. **No sword and no attack visual effects baked into any hero frame.**
2. Weapons: `steel`, `crystal`, `ember`, `rune_gold`, `shadow_violet` are independently replaceable `Sprite2D` children attached to a hand-socket for **every** hero keypose. Measure the actual `weapon_grip` coordinate; do not fake attachment with random offsets.
3. VFX: slash arcs, hit flashes, crit and dust are independently spawned, positioned and timed from gameplay events. This must not be in the hero frame.
4. Golem: four separated poses, character remains the same identity. Combat background: separate opaque image, **never include UI/hero/golem baked in**.
5. Large transparent working gutters: minimum 128px external sheet border and 192px blank canvas gap between *independent individual sprite canvases*. Original RGBA pixels must remain unmodified. For runtime use extracted single textures, never grid-crop at arbitrary dimensions.

## Current local art package (prepared, NOT yet in GitHub)
`REALM_ALLIANCE_CANONICAL_ASSET_BATCH_01_V2.zip`
contains:
- 6 real white-haired, masked, weapon-free hero PNGs (640×512)
- 5 independently rendered sword PNGs (1152×384, horizontal base direction)
- 4 Golem PNGs (736×736)
- 1 Wolkgarten world plate (941×1672)
- original source sheets, large-gap **transparent** catalog sheets, SHA-256 manifest, and QA preview.
- Separate, **uncut** VFX *reference only*. The candidate source VFX sheet has border interference / touching glow; its elements are not approved as production cutouts.

The zip has not been uploaded to this repository; do NOT claim the new character art is already running in Godot. The existing Godot 4.7.2 branch must remain buildable until these PNGs are imported.

## Integration acceptance gates
- The ZIP directory `godot/realm_alliance/assets/production/` can be copied into this Godot project as-is.
- Install a reversible scene adapter `ProductionHero` with the existing `impact`, `action_finished`, `equip_weapon`, `set_upgrade_tier`, `play_attack` API.
- Pose changes must not shift the ground anchor (local pixel `(320,488)`); character source canvas same across all states.
- Verify sword grip and layer depth in idle **and** windup/contact/recovery; never leave the weapon floating.
- Preserve the fallback `BramblePreviewHero` and game state until production sprites are explicitly accepted.
- Verify 20/20 model tests, responsive layout and Android/Web build, followed by a **real-device visual recording** against approved combat masters.
