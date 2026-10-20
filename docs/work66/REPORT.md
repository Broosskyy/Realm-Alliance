# REALM ALLIANCE — Work 6.6

Feature branch `feature/work-6-6-tap-combat`. Canonical Realmwächter and modular weapons/equipment retained. No main merge or Game Factory changes. This is the local Tap Combat 2.0 milestone; 6.7–7.0 and the online 7.1–7.6 roadmap are not claimed implemented here.

## Gameplay, visible progression and feel

- Three actual timed basic actions: cut, rising cut and heavier finisher. The simulation owns each contact; no damage on button press. Pose changes, weapon rotation, slash direction, impacts and weighted damage numbers distinguish the chain.
- x2 unlocks at hero level 3 plus the first Wolkgarten elite; x4 at level 6 plus the Gartenkoloss. Modes schedule 1/2/4 contacts. Total budgets are 1.0/1.25/1.6 times the current chain step, split with deterministic integer remainders. A basic action grants resources, charge, healing and weapon procs once; contacts cannot farm four times the rewards. Existing crystal crit remains one roll per action.
- One bounded manual tap intent during recovery, explicit skills/ultimate get priority. No unbounded queue; intent clears on menu, transition and defeat. AUTO defaults to basic attacks only. Optional AUTO skill policy requires explicit enable plus selected skills; reserve/HP/status conditions are enforced by the gameplay model.
- Sternenfall is a real charged ultimate: level 4 plus Gartenkoloss, 100 earned charge, separate 0.55s windup, one real 4.8× hit and 16s cooldown. It can be queued during AUTO without early charge consumption.
- Boss armor meter, real 1.6s break/telegraph interruption, bounded +25% vulnerability and a cooldown between breaks. One half-HP enrage phase increases actual incoming attack by 20%. Cues correspond to actual state changes.
- Real unlock notifications have priority over generic reward text; the hero page shows the next concrete combat objective. Upgraded weapons get a separate weapon-local light/rune layer, using the existing replaceable sword.
- Attack timing, budgets, unlock gates, combo grace, charge and ultimate definition are in `data/tap_combat.json`, separate from input and rendering. Existing skill ranks continue to affect real skills; higher ranks strengthen impact feedback.

## Cape and wings

The original long rear cape was painted into the body. `HeroCape` now isolates rear cloth using six authored source-space UV masks, and draws that same cloth as a folded separate layer when wings are equipped. The original rear cloth is excluded from the body only in that state. Wings remain behind cape/body and keep their authored clasp socket. Face, armor, foreground arms, scarf and separate sword are preserved. Unequipping wings restores the original full cape. This uses unchanged canonical PNGs, no new full-body skin or baked VFX.

Native Godot captures inspect all six poses with each of the five swords, including actual blade/hand layering. Full native views were captured at 360×800, 720×1280, 720×1560 and 1280×720. These fixture renders deliberately provide XP/equipment for visual inspection and are not proof that those items were earned.

## Tests and build

Local regression gate: **1,024/1,024 checks in 18 suites** (877 existing checks plus 147 new checks). Includes true contact timing, bounded damage/resource budgets, crit/proc frequency, chain reset, partial multihit restore, JSON numeric compatibility, defeat/transition cancellation, input/ultimate priority, opt-in AUTO validation, actual boss break/enrage, future-save protection, cape/face/hand constraints, upgrade FX/off controls and all required touch viewports.

Final runtime source and final CI/browser evidence are recorded in STATUS.md. Version 0.6.6 / Android code 660, existing package `com.avenor.realmalliance.preview` and existing development signing key. Web-first/mobile-first remains unchanged.

## Online direction retained explicitly

Families/guilds, visible co-op heroes, legendary titles and arena/PvP are binding pillars in the roadmap. New actions/damage events include actor, target and stable per-run action IDs; tap and boss runtime modules do not own rendering/input. These are local simulation contracts, not online authority. Future server owns damage, HP, drops, currencies, activity/PvP results. No fake friends, guild membership, online presence, shared boss, matchmaking or rankings were added.

## Limits and next gate

No physical Android playtest or Android video from this runtime is claimed. APK export alone does not prove mobile performance. Hosted Linux software rendering is measured separately; 60 FPS on target hardware remains unproven. Visual sign-off and extended hardware balancing remain review work. Later milestones are developed after this bounded milestone, not represented by decorative menus.
