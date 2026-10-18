# REALM ALLIANCE — Work 6.7.1: Hero Art Direction (first implementation checkpoint)

## Decision and migration

The **white-haired, masked Realmwächter** is the canonical starter and primary hero. Kaela is **no longer a selectable or purchasable hero**, because her stylization does not match the current production art.

Kaela's existing production art is **preserved** under `assets/roster67/kaela/` and her stable old hero ID remains in the catalog, explicitly marked `playable:false`; `npc_kaela_runenhueterin` is registered as an archival NPC concept for later open-world content. This checkpoint does **not** implement an open world or live NPC interaction.

Old saves containing Kaela:
- If Kaela was selected, revert `hero_roster.active` to `realmwachter` on load.
- Keep `hero_roster.owned.kaela`, source and earned Kaela XP intact for future story/legacy handling.
- Compensate the historic Kaela unlock price **exactly once** (+150 gold, +8 shards), tagged `kaela_compensated`.
- Preserve inventory, weapons, gear, pets, stage, run identifier, enemy HP, claims, quests and account XP.
- The normal masked guardian is shown in combat and the Wesen hero portrait.
- Test/QA mode showcases the guardian with Himmelsfuchs instead of forcing Kaela.
- Do not alter existing `main` or merge unfinished work into stable branches.

## Canonical playable-hero visual contract

An additional hero becomes playable **only** when their complete original production set has been created, checked and integrated. Required:
- Identity, silhouette, outfit and coloring that **belong to the same fantasy RPG** as the white-haired masked guardian, while remaining recognizable and different.
- Six synchronized weapon-free alpha cutouts: `idle`, `ready`, `windup`, `attack_contact`, `recovery`, `hit`, plus `defeated` and a matching portrait.
- Same normalized coordinate space as the existing production rig (640 × 512), consistent foot/ground alignment and proportions across every state.
- Own hand, back, head and chest socket positions per pose; no weapon or VFX baked into the hero body.
- Separate weapon grip/rotation review on all five current swords, armor and wings.
- Working tap, x2/x4, skill timeline, incoming hits, pet effects, HUD/collection previews and save/load.
- Real sprites and visual smoke checks — never reinterpret Kaela's assets, recolor her as a fake new hero, or enable an empty catalog slot.

**Future first playable hero concept:** Runenpaladin (heavily armored sword-and-shield defender), gold/steel/blue rune materials and distinctive helm. This is a proposed art direction, **not currently a playable hero or a completed asset pack**. Generate and review the full sprite set before enabling the new ID.

## Wesen/UI direction

The tab design and collection panels use the existing cohesive navy/gold fantasy kit. Kaela is removed from playable cards. Himmelsfuchs and Morgenphönix remain in the companion tab with functional acquisition and evolution. In-place switching still preserves the active encounter without healing or duplicating rewards.

## Quality gates

- `test_roster67.gd`: old-Save Kaela-to-guardian migration, preserved inventories and boss progress, one-time compensation, pets, and actual guardian rig.
- `test_admin_qa.gd`: QA cannot inject retired Kaela into normal playable roster or save.
- Existing model regression, UI tests, native scene smoke and Android/Web export must be green.
- Final visual inspection on a physical Android device remains required.

This is **Work 6.7.1 stage 1** (retirement + migration + UI correction), not acceptance of a new hero or a new open world.
