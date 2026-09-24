# PROJECT NULL — Master Expansion Audit

## Scope
Audit against the web-first idle action RPG master directive. This is a living production note, not a rewrite plan.

## Current strengths
- Immediate browser-first combat loop is already functional.
- Persistent local save, levels, XP, gold, essence, mutations, equipment, hero stats, skills, automation toggles, bosses, streaks, chests and relic dust exist.
- Six biome identities and biome enemy families exist.
- Mobile one-screen combat shell and lightweight CSS effects fit the browser-first target.

## Highest-risk debt
1. `src/main.tsx` owns combat orchestration, screens, content presentation and effects. It is already too large.
2. `src/styles/app.css` has accumulated sequential override passes and needs gradual consolidation instead of more blind append-only patches.
3. World metadata is embedded in UI while enemy/item metadata is in `data/content.ts`.
4. Combat uses timeout-driven UI state and can race under rapid/manual/auto input.
5. Skills have no cooldown/state model and currently bypass enemy retaliation.
6. Loot is definition-based and unique-by-id, so repeated drops, rolls, affixes, item levels, salvage and meaningful rarity hunting are impossible.
7. Save schema has no explicit version/migration pipeline.
8. Encounter type is derived mostly from enemy index; random elite/treasure/rift/event encounters do not yet exist.
9. Bosses are mostly stat/size variants; telegraphs/phases/mechanics are missing.
10. No offline progress, missions, achievements, prestige, collection registry, material economy or true relic inventory yet.

## Foundation decisions
- Preserve current game and save key; migrate forward rather than reset.
- Move static game definitions into `src/data/*`.
- Add explicit save schema version and normalization.
- Introduce deterministic scaling helpers before expanding balance.
- Introduce encounter/loot instance models before adding large content pools.
- Keep React as presentation; move combat/reward rules toward `src/game/*`.
- Keep CSS/SVG/WebP-friendly rendering; no heavy rendering dependency.

## Production order
### Phase B — Foundation
- World definitions
- save schema/migrations
- progression/scaling helpers
- encounter definitions
- loot instance foundation
- split UI incrementally

### Phase C — Combat
- combat state machine / attack lock
- cooldown skills
- enemy retaliation parity
- elite/treasure/rift encounters
- boss telegraphs/mechanics

### Phase D — Loot
- item instances
- item level
- rarity rolls
- affixes
- compare
- salvage
- upgrade

### Phase E+ — World/Progression/Retention
Continue in the order defined by the master directive.

## Non-negotiable UX
Combat stays immediately playable, mobile-first and mostly one-screen. Depth belongs behind contextual surfaces, not permanent dashboard clutter.
