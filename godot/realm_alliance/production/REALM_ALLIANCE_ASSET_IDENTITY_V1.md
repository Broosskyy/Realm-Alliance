# REALM ALLIANCE — Asset Identity & Shared-BRAMBLE Style v1.0

Status: **Production planning approved as direction; individual assets remain unapproved pending visual/source QA.**  
Game runtime: Godot 4.7.2, fixed portrait combat, optional Web + Android.  
**Do not conflate REALM ALLIANCE with BRAMBLE or the Bramble/Kein-Name fusion.**

## Shared canonical style
Reference **BRAMBLE's existing art production standard**, not a new invented palette. Canonical docs (isolated change branch, not Bramble main):
- [AVENOR Shared Game Art Bible](https://github.com/Broosskyy/Bramble/blob/feature/avenor-shared-game-art-standard-01/docs/shared_art/AVENOR_SHARED_STYLE_BIBLE_V1.md)
- [Bramble Identity and Reuse Policy](https://github.com/Broosskyy/Bramble/blob/feature/avenor-shared-game-art-standard-01/docs/shared_art/BRAMBLE_IDENTITY_AND_REUSE_POLICY.md)
- Existing [BRAMBLE Asset Scale Bible](https://github.com/Broosskyy/Bramble/blob/main/docs/production/BRAMBLE_ASSET_SCALE_BIBLE.md) and [Pose/Socket Bible](https://github.com/Broosskyy/Bramble/blob/main/docs/production/BRAMBLE_POSE_SOCKET_BIBLE.md)

**Shared foundation:** anime/chibi fantasy proportions, consistent render/shading/materials, crisp silhouette, transparent full RGBA production singles, persistent pivots and state-aware weapon/armor sockets. Honor BRAMBLE exceptions per asset. No generic AI-fantasy visual reinterpretation.

## REALM ALLIANCE identity: deliberately distinct
- Existing approved primary screens remain **Kampf, Abenteuer, Wesen, Beute, Mehr**. They are more important than borrowing BRAMBLE's UI.
- Combat is fixed-stage portrait; attacks/auto/skills/monster HP/gold/upgrade feedback should be clearly legible. No 2.5D world camera implementation is required for this screen.
- **Realmwächter** is the original canonical hero identity for the combat slice. Use BRAMBLE base anatomy only if design consistency and rights are verified; armor, head/face, wings, evolution and other identifying details must form a separate REALM design.
- Example zone name: **Grünhain** is currently a production working name, not a claim that a complete region already exists in canon. Maintain a separate REALM monster roster and distinctive hero evolution art.
- Bramble's named Moorling / Rootling / Root Guardian and location-specific story symbols are BRAMBLE-only by default; if crossovers are ever intentional, record explicit game design approval.
- Neutral equipment base: 8 BRAMBLE separated types exist, but only **sword** is the initial socket verification source; additional named/rare weapon designs are produced for REALM specifically.
- REALM's UI stays faithful to its own approved combat master rather than adopting Bramble's world HUD or minimap.

## Fixed-stage camera & sprite adaptation
BRAMBLE authored multi-direction source sprites for a ~38° oblique orthographic world; REALM currently uses screen-space `Node2D` geometry in `scripts/hero_rig.gd`.

**Do not just paste BRAMBLE's directional body on top of the current polygon rig.** Implement an `RABodyPresentation` adapter later, driven by:
1. One chosen and visually approved BRAMBLE-style target-facing view;
2. Body keyposes `idle / windup / contact / recover / hit / defeated`;
3. Separate weapon blade/handle sprite anchored by named `hand_r` / `weapon_main` metadata per pose, no permanent combined sword/body image;
4. Matching armor, helmet, accessories and wings per pose if these layers are equipable;
5. Ground/contact reference identical across all cels, explicit on-screen visual-size target and attack/VFX origins;
6. Portrait gameplay screenshot comparisons, not only successful export status.

The hand socket already exists in the technical prototype. Its coordinates must be authored from the *real* source artwork rather than copying polygon placeholder offsets.

## Production single specification
- Default humanoid source family: 512×512 RGBA straight alpha, ground pivot (256,464). Wayfarer M04.31B special family uses (256,468): never silently mix the two.
- Keep 24 px transparent safe silhouette padding for single poses; on review/source sheets use ≥32 px gutter and ≥32 px outer margin, separated independent transparent elements and **no text**.
- Treat equipment/animation parts as registered layers, not random crops of artwork. Save a semantic JSON record for every `body / equipment / facing / pose / pivot / grip / depth` tuple.
- Monster standard animation can be 1 view if the fixed arena never turns, but each enemy identity needs honest `idle, attack, hit, defeated` keyposes or approved authored/procedural combination. Boss identity adds attack warning/telegraph and phase reaction.
- No duplicate fake backgrounds, white edge halos, asset-sheet text, extra presentation shadows, off-canvas sword tips or actor feet that drift.

## Priority
1. Prove one **hero + one BRAMBLE sword + one BRAMBLE slash VFX** renders and aligns against REALM portrait mockup.
2. Add one neutral stage asset layer and a project-specific enemy, then perform Android/Web acceptance.
3. Scale to complete kits and stage variants only once the above is genuinely usable; do not repeat years of re-generating incompatible art.

## Explicit non-goals for this planning change
No import or binary duplication yet; no claim of image QA, checked asset ownership, final mockup parity or completed new art. No changes to `Bramble/main` or `Realm-Alliance/main`; keep game systems, saves, and approved master mockups unchanged.
