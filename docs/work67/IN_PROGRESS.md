# Work 6.7 — implementation in progress, NOT accepted

Checkpoint 2026-10-18. Base: tested Work 6.6 documentation head b1cff364e13d0c5eee707288c82b5be87f47414f.
Runtime builds remain c7f655836779a01276bdc990c815ba7078344ba4 / CI run 39149460669. This branch has no approved 6.7 build yet.

## Secured and verified 6.6
- Real timed three-step tap chains, earned x2/x4, charged ultimate, opt-in AUTO skills, boss break/enrage.
- Canonical cape split/fold with wings and separate weapon-upgrade glow.
- 1,024/1,024 deterministic checks, Web and debug APK exports.
- Exact exported-browser natural progression: three runs, 15 kills, both region bosses, x2/x4, ultimate, earned equipped wings, steel level 2, vitality talent, skill rank 2, one chest, quest, full reload.
- Four required viewports and all five pages, 48 native rig/action captures.
- Hosted software-renderer sample median 50 ms / p95 66.7 ms. Physical Android and 60 FPS target-device verification remain open.
- No main merge or Game Factory changes.

## Local draft 6.7 (not yet committed as runtime)
A local draft adds a second original hero (Kaela, rune tank) and two companions (sky fox damage / dawn phoenix healing), separate transparent production sprites, roster/pet data domains, per-hero combat XP after first collection unlock, real unlock costs, companion training/evolution, deterministic companion windup/cooldown/runtime checkpoints, alternate source-space sockets, and native collection UI. Switching actors/companions starts a fresh run and retains account/equipment progress.

The 24 alpha sprite files were generated and normalized, not just mocked up. Original guardian stays the default and five swords stay separate. Draft files:
- data/roster67.json
- scripts/systems/{hero_roster,companion_progress,companion_runtime}.gd
- scripts/presentation/{hero_visual_catalog,companion_visual}.gd
- scripts/ui/roster_dialog.gd
- assets/roster67/{kaela,skyfox,sunbird} and manifest.json
- integration edits to combat_session, main, combat_hud, production_hero, hero_attachments, hero_cape.

The existing 18 suites passed with the first integrated draft. Further event/XP presentation changes were then made and a dedicated test_roster67.gd gate was being added.

## Actual blocker / next action
The execution environment stopped responding while creating/running the dedicated 6.7 gate; even independent pwd/file/image reads stopped returning. Its test result is unknown. Local draft/code/assets could not be read back, packaged, visually verified, or pushed. Do not treat this documentation commit as an implemented 6.7 release.

On resume, inspect the existing local draft first; recover/finish the dedicated test gate, render all alternate poses/swords, inspect actual collection interactions and trained/evolved companions, re-run all suites, then export and test Web/APK. Do not publish untested 6.7 artifacts as current.

## Remaining roadmap
6.7 needs the gates above. 6.8 (inventory/shop/crafting), 6.9 (dungeons/event loop), 7.0 (connected progression/balancing) are not completed by this checkpoint. The four future binding pillars remain families/guilds, visible cooperative players, legendary titles, PvP; local actor/action IDs are not server authority.
