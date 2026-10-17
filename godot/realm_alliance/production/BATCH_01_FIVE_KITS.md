# REALM ALLIANCE — Production Batch 01: Five Kits, One Shared Style
Status: **READY FOR ASSET DESIGN / NOT YET RENDERED OR INTEGRATED**. Source selections are candidates.  
Game: Godot 4.7.2, portrait fixed combat, separate REALM identity, BRAMBLE style production foundation.

## Shared gates for ALL five kits
- Art/texture reviewed at actual target frame and at gameplay size on Android; compare with REALM's approved **Kampf** master.
- Truly transparent RGBA backgrounds (straight alpha), no captions, UI or scene in character/item sheets, no white/black halo, no cut silhouettes.
- 32+ px sheet gutters and outer margin; individual character frames keep 24+ px edge safety.
- Original source/reference files retained and every extracted runtime file has provenance, hash, canvas, pivot, socket and preview.
- Files and directions do NOT become `APPROVED` solely because a GitHub file exists.
- Export to Godot's `res://assets/production/<kit-id>/` only after adapter, asset license/provenance, visual QA and import tests.
- All new content uses a unique `RA_...` ID; no misleading rename of BRAMBLE-specific identities.

## Kit 01 — RA-HERO-CORE-01 / Realmwächter
**Reuse:** BRAMBLE original player base family as *style and anatomy reference*, not necessarily as Realm's final protagonist:
- `assets/game/characters/base/male/directions/front.png`, `front_right.png`
- `assets/game/characters/animations/male/attack_melee/00_male_ready.png`
- `assets/game/characters/animations/male/attack_melee/01_male_windup.png`
- `assets/game/characters/animations/male/attack_melee/02_male_swing.png`
- `assets/game/characters/animations/male/attack_melee/03_male_recover.png`
- `assets/animation_frames/characters/male/07_hit_recoil.png`

**New project-specific output:** 1 canonical Realmwächter look compatible with separate armor/helmet/weapon and later wings/evolution. First approved view + six body poses: idle, ready, windup, contact, hit, defeated; optionally recovery as a seventh keyed/engine-driven state. Matching 512×512 transparent PNGs and an explicit socket JSON for ground/hand_r/weapon_main/head/back/hit/loot, depth and per-pose transform. Test 3 attack phases on mobile before expanding to 8 directions.

**Accept:** no baked sword, no weapon-hand separation at contact, grounded feet, face/armor alignment and silhouette matching BRAMBLE quality.

## Kit 02 — RA-WEAPON-STARTER-01 / 5 Starter Weapons
**Reuse/adapt candidates:** `assets/equipment/weapons/sword.png`, `curved_sword.png`, `staff.png`; start with **sword** to verify hand socket. Bramble currently contains 8 separately exported weapon types, but no claim that all are aligned to REALM's combat pose.

**New Realm output:** five unique starter weapon identities (working names): Iron Guard, Crystal Edge, Ember Blade, Thorn Cutter, Rune Saber. Separate source textures (prefer 512×512 transparent on a canonical weapon-safe canvas) with per-weapon metadata: grip point, blade tip, local rotation/scale, idle/windup/contact/recovery front/behind depth policy. The user can equip/recolor/swap equipment in gameplay without modifying the hero sprite.

**Accept:** correct grip in all attack phases; no scale hacks for mounting. Weapon part does not float, lag behind or cut through the head by accident. Generate five final variants only after one sword passes.

## Kit 03 — RA-MONSTER-GRUENHAIN-01 / Early Zone
**Style references only:** BRAMBLE `assets/game/monsters/moorling/actions/`, `assets/game/monsters/rootling/directions/front.png` and `assets/game/monsters/crystal_beetle/`. Existing BRAMBLE monsters are separate IP identities; they are not renamed into Realm characters.

**New Realm identities (working names):** Waldwinzling, Mooswolf, Pilzkriecher, Dornenling; first boss: Hainschrat. All must be visibly distinct silhouettes, not recolors of BRAMBLE's rootling/guardian.

**Exact sheet contract:** **one separate high-resolution 2×2 sheet PER monster**, exactly four authored state images with identical character and coherent proportions: `Idle/Ready`, `Attack`, `Hit/Damage`, `Defeated`. Transparent straight alpha, generous horizontal/vertical separation, no labels or stage, extracted into four independent runtime PNGs plus optional richer animation after approval. Boss gets its own larger sheet, readable warning/attack telegraph, impact and death.

**First gate:** one full four-pose normal monster plus one controlled combat proof. Then complete remaining four without changing identity/style.

## Kit 04 — RA-STAGE-GRUENHAIN-01 / Portrait Combat Arena
**Candidate reusable BRAMBLE neutrals:** `assets/game/world/terrain/seamless/meadow.png`, `earth.png`; `assets/game/world/vegetation/glow_stump.png`, `thornberry_bush.png`, `swamp_willow.png` only if camera angle/provenance fits.

**New Realm composition:** independent transparent or opaque layers as appropriate:
1. sky/distant world backdrop;
2. forest silhouette/midground/ruin forms;
3. central readable character plane and grounded combat floor;
4. separate foreground foliage/depth;
5. optional low-cost ambience overlay.

Design for target Godot logical viewport 720×1280 with portrait safe areas and ability to crop tall-phone layouts. **Never** export a screenshot with HUD/hero baked into the stage. Do not adopt BRAMBLE's navigable open-world collision/grid as REALM's fixed-stage layout.

**Accept:** enemy/player silhouettes and hit numbers have contrast; no dead vertical bands, foreground cannot hide target or buttons, stage fits multiple phone aspect ratios. Actual assets replace `scripts/stage_art.gd` only after review.

## Kit 05 — RA-COMBAT-VFX-01 / Shared Impact Set
**High-priority BRAMBLE source candidates:**
- `assets/game/combat/vfx/melee_slash_sequence/frames/00_glint.png` through `07_motes_fade.png` (8 individually stored frames);
- `assets/game/combat/vfx/magic_support/frames/07_violet_impact.png` for a future magic example.

**New adaptation/output:** Godot `AnimatedSprite2D` or dedicated VFX scene with stable contact anchor and sequence timing. Separate routine slash, strong skill slash, hit spark, critical impact, boss telegraph/impact, minimal reward sparkle. Export actual reusable single RGBA frames; avoid sheets at runtime if singles already exist.

**Accept:** strike/contact/HP reduction are synchronized; effect center follows target and world-stage transform; no fullscreen blue touch rectangle or prolonged bloom; Web and Android maintain readable low-end performance.

## Sequence / effort-saving rules
**Gate A — proof:** one existing BRAMBLE sword, one 8-frame slash, one selected character-view reference and one neutral terrain layer. Produce a single honest screenshot/video on real Android.
**Gate B — first production identity:** Realmwächter separate body+weapon, one new original enemy with all four states, localized portrait stage.
**Gate C — expand:** remaining weapon designs, monsters/boss, skill+crit effects; then armor/helmet and upgraded looks.
**Gate D — polish:** compare user-provided master mockup, animation cadence and visual line-up; only promote `APPROVED` after manual device review.

## Next batch (NOT part of this output)
`RA-ARMOR-01`: leather/guardian/runic looks with registered 512×512 overlays; `RA-UI-COMBAT-01`: actual Kampf master HUD instead of technical buttons. Do not import BRAMBLE UI as-is.

## Known blockers
No final source sprite inspection, in-game screenshot approval, binary import or license verification has been performed as part of this documentation. Specific BRAMBLE directions/combat cels can be incomplete; treat missing art as a new asset-production request, not a mirrored or fabricated frame.
