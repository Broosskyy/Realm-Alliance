# Godot donor projects — technical gate, not blanket integration

## Candidate A: Lost Ramko
URL: https://github.com/Boyquotes/Lost-Ramko

**Status:** Examined upstream README, LICENSE, CREDITS, project.godot, main/combat scenes and combat code; **not executed**.

- Godot 4.6 portrait 720×1280; tap / auto damage / waves / bosses / skills / prestige / pets / achievements / local saves.
- The code is MIT licensed with attribution obligations. Bundled assets have **mixed rights**; third-party Zerie files cannot be redistributed as standalone packs, and separate original-provider terms may apply.
- Combat uses AnimatedSprite2D; no fully modular armor / weapon rig exists.
- Upstream config uses Mobile renderer; for REALM's web-first release switch to GL Compatibility and test.
- Several large central scripts make a blind fork-and-reskin fragile. Do not copy all of its architecture/UX into REALM.

**Verdict:** A useful opt-in gameplay donor/reference after local Godot and Web smoke test. Do not ship its art.

## Candidate B: SELODEV / free starter
https://github.com/seloc0des/free-starter-godot

**Status:** Source/license presence inspected; no compatibility tests.

- Componentized RPG features, potentially useful for inventory/loot/crafting/quests.
- Its state, inventory and save design must not run alongside a separate competing authority without an explicit adapter and IDs.
- No approval to copy all dependencies into this slice.

## Candidate C: AATTAAI Godot importer
https://github.com/boneboxid/AATTAAI

**Status:** README/license verified, **not installed**.
- MIT-licensed importer for Adobe Animate atlas/cutout timelines; slot texture override and node attachments.
- Not a direct solution for REALM's existing full-body PNG poses. Its input requirements mean we need correctly separated and aligned source parts first.

## Initial sprint decision
A dependency-free, original, small Godot combat POC is created in this repository to de-risk native/Web/Android output and the hand/socket architecture before selecting a donor. It preserves the React V2 production runtime unchanged.

## Explicit exclusions
- No unlicensed code/assets.
- No imported branded characters, borrowed logos, copied interface art or monetization systems.
- No promises that the mockups or online game are implemented.
- No simultaneous rollout of full RPG subsystems before successful build and combat test.
