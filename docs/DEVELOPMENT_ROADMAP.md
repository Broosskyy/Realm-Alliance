# REALM ALLIANCE — binding production roadmap

Approved direction: 2026-10-18. The game grows through real gameplay, consistent visuals and meaningful progression together. A new item needs rules, saved ownership, a proper icon, correct visible equipment where applicable, and reward feedback. No milestone is complete because menus or interfaces exist.

## Baseline and order

Work 6.5 is the bounded offline RPG loop: two five-encounter regions, actual loot/chests, inventory, skill ranks, talents, quests and achievements. Verified source/docs: `5ff810a6432544236e6d760023b089f1fd7d9955`; runtime: `8827f0e10be17d736f9cb174e93ec917c7ce436d`. See `work65/REPORT.md` for 849 passing checks and actual browser/native verification. Android export succeeded; a current physical-device playtest and a proven mobile 60 FPS result remain open.

The visual convergence pass is **6.5.1**, not 6.6. Develop and validate each phase before building the next. Keep separate commits, honest open issues and reproducible evidence. Work on feature branches; never automatically merge main or synchronize the Game Factory. Preserve the working Grünhain slice.

## 6.5.1 — UI and visual convergence

Converge all five real areas with the supplied masters: one dark navy fantasy family, restrained cyan/purple/gold accents, rounded translucent panels, reusable nine-slice textures, coherent buttons, tabs, rarity/equipment slots, navigation, dialogs and reward presentation. Open central canonical hero showcase, illustrated map with actual clickable region/stage nodes, dense inventory grid, profile/function/settings page. Respect mobile touch sizes and tall/small/landscape layouts. Animate menu changes with reduced-motion support. Build reusable shop/quest/activity card materials where useful, without exposing unavailable systems as functional menus. Preserve gameplay and save data.

Gate: all five areas form one recognisable visual family matching the masters, with actual scene captures and technical regression/build gates passed.

## 6.6 — Tap Combat 2.0

Every accepted tap starts a real timed attack. Add distinct attack chains, combos, crits/multihits, speed/cooldown rules, reactions, elements/statuses, boss break/stagger/phases and finishers/ultimate scope that can actually be completed. Advance the four existing skills with levels, data-driven attack/magic/defense/buff/debuff/ultimate categories and distinct activation/projectile/slash/impact/status sequences. AUTO skills require explicit configurable opt-in; defaults remain basic attacks only. Add combo/charge/crit/audio feedback with bounded shake and hitstop.

**Before implementing x2/x4, decide and document its actual mechanic** (hits per tap versus speed or temporary damage), unlocks, balance, resource interaction, AUTO behaviour and VFX. This roadmap does not silently select a mechanic.

Gate: basics, combos, skills and specials are mechanically and visually distinguishable, with deterministic hit timing and resource tests.

## 6.7 — Heroes, pets and visible evolution

Realmwächter remains the canonical white-haired masked hero. Start with one additional complete original hero before expanding melee DPS/tank/mage/ranged/support/summoner roles. Each needs portrait, idle/attack/hit/death art, weapon/skills, element/faction, stats, rarity/stars, XP, unlocks and saves. Add meaningful visible awakening/evolution, armor/head/cape/wings/aura/skins and skill evolution, not a number-only change. Implement two distinct companions with actual attacks/heal/shield/passive/loot roles as appropriate, saved growth and unlocks. Build real hero/pet collection and progression screens; prepare later team selection only where needed.

Gate: complete playable and persisted heroes/pets with original production assets and demonstrated progression.

## 6.8 — Loot, chests, inventory, shops and crafting

Expand working item types incrementally: weapons/armor/head/hands/feet/accessories/wings/pet items/materials/fragments/event/set items. Establish common/uncommon/rare/epic/legendary/mythic visual and data rules. Implement useful leveling/upgrades/evolution/enchant/salvage/crafting/attributes/set bonuses/comparison/equip flows. Chest pools and reveals must actually credit saved inventory once. Start functional gold/material/equipment/cosmetic/pet/event shops only with real balances, validated transactions and duplicate reward protection. Later real-money/random paid offers need separate platform/transparency/security work; no fake checkout now. Balance real gold sources/sinks and retain a path to future server authority.

Gate: found loot can be inspected, claimed, compared, improved and used; real in-game purchases debit and credit exactly once.

## 6.9 — Dungeons, boss challenge and reusable events

Start with two complete differing dungeon activities. Prepare extensible story/endless/gold/XP/material/equipment/pet/elite/boss/event definitions. Implement an honestly labelled local boss challenge with phases, telegraphs, arena/HUD, timer and reward tiers. Do not call a local encounter a shared online World Boss. Raid/group/reward interfaces may prepare future cooperation; synchronized multiplayer requires actual online infrastructure.

First full reusable event package: Halloween region, pumpkin/shadow normal enemies, boss and dungeon/challenge, themed gear/skin/pet, currency/shop/chest, quest chain and real unlock/reward loop. Future winter/spring/summer/anniversary packs should reuse the content model. Avoid unfinished breadth.

Gate: two functioning dungeon types and a complete event loop with enemies, objectives and persistent rewards.

## 7.0 — Complete RPG progression loop

Integrate main/side/event/dungeon/boss/collection/upgrade quests, achievements, talents, hero/skill/equipment/companion/collection advancement, specializations, regions and repeatable endgame into a balanced journey. Implement daily/weekly/login activities only with consistent time rules and repeat-claim protection; competitive online authority is future work. Document pacing from onboarding through first upgrade, weapon, pet, dungeon, evolution, rare chest and special boss. Avoid instant unlock-all and excessive grind.

Gate: connected systems let a player earn rewards, become visibly stronger and unlock new challenges over meaningful sessions.

## Common production contract

- Godot 4.7.2; Web-first and mobile portrait first, Android APK secondary. Preserve existing modules and saves; version domains and migrate with backups before schema changes.
- Gameplay/input/presentation/UI/audio/save/content have separate responsibilities. Stable hero/item/skill/enemy/activity/event IDs; structured data for future server-authoritative accounts and economy without pretending local data is secure online authority.
- The supplied masters are the design reference. Their alternate brown-haired hero is layout inspiration only. No random replacement of the canonical hero.
- Separate body, weapon, equipment and VFX; pose-compatible pivots/sockets and explicit layers. Genuine alpha, consistent scale, spaced sheets, production files and manifest/provenance. Reusable UI, not screenshot-sized fake interfaces.
- Bounded particles/effects, appropriate textures/draw calls/memory, no unnecessary UI rebuilding or critical-frame blocking loads. Audio and VFX intensity options, reduced motion. Measure performance on actual target devices; do not claim 60 FPS from a headless build.
- Each milestone: import/start, script error scan, old/new deterministic tests, save/load/migration, actual Godot captures at 360×800, 720×1280, 720×1560 and 1280×720, touch/desktop input, Web export/browser playtest, Android CI export, report/assets manifest/source commits/downloadable builds. No device-test claim from an export.
- Keep a short complete normal→elite→boss→loot→victory/defeat/restart run as the quality bar. No placeholder menu flood or architecture rewrite.

## Beyond 7.0

Guilds, friends/chat, cooperative dungeons, synchronized raids, PvP/arena/rankings/guild bosses, safe trade, new classes/regions/seasons/endgame remain product direction. None implies current online readiness. Infrastructure, authority, account security and validated economy must exist before those features are represented as online systems.


## Binding online continuation (2026-10-18)

Families/guilds, visible co-op dungeon heroes, legendary titles and arena/PvP are four mandatory main systems. Local 6.6–7.0 is completed first. 7.1: accounts, identity, database, cloud saves and server authority. 7.2: friends, parties, invites, presence, reconnect and first real shared dungeon, with individually visible equipped heroes and shared enemy/wave state. 7.3: families/guild names, crests, ranks, members, chat, levels, quests, shared progression/bosses and later halls. 7.4: real shared World Bosses, raids and group mechanics. 7.5: separately balanced 1v1 PvP, later teams, matchmaking, ranks, seasons, rewards and legendary achievement titles. 7.6+: shared worlds, guild wars, cooperative events and endgame.

Titles have stable IDs, actual unlock conditions and selected display across hero/profile/lobby/arena; no unearned prestige or fictional guild membership. Multiplayer dungeons must support several actor IDs, individual commands/skills/equipment, bounded readable VFX and individual idempotent rewards. The authoritative server later owns damage, HP, drops, currencies, activity progress and PvP results. Web/Android and later iOS share that authority for true crossplay. Local simulation is explicitly offline; no fabricated online features.
