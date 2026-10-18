# Work 6.6 — decided rules before implementation

Baseline: c6e30a4a3658b31e3aba683896481757113aaea0, Godot 4.7.2. Feature branch feature/work-6-6-tap-combat. No main/Game Factory writes.

## Game-feel contract

Manual taps and AUTO basic attacks use a three-step chain (cut, rising cut, finisher). Contacts come from simulation time, never button press. Bounded manual input buffering protects intentional taps during recovery and gives skills priority. UI labels distinguish queued versus accepted actions; no unbounded tap queue. Manual action/skill intent clears on menu, defeat and encounter change.

x1/x2/x4 means 1/2/4 scheduled contacts per basic attack, not simulation speed. x2 unlocks at hero level 3 after the first elite, x4 at level 6 after the Wolkgarten boss. Unlocked modes are selectable without consumable cost. Total basic damage budgets are 1.0/1.25/1.6 times the matching chain step; each is split across the contacts, with integer remainder distributed deterministically. Momentum, rage, lifesteal, weapon procs, combo advancement and crit rolls occur once per action; repeated contacts cannot multiply those rewards. Surplus contacts are cancelled on death, transition or defeat and never hit a newly spawned enemy. AUTO uses the selected basic mode, with no skill spending unless the player explicitly enables configurable skill rules. A chosen mode cannot change a pending action.

Basic chain resets after a short inactivity window and on encounter/restart/defeat. Third chain step has a distinct heavier follow-through and bounded damage bonus. Existing skill rank system remains real; improve its visible charge/impact strength with rank. Crystal's deterministic fourth-action crit remains distinct; no invented crit labels.

Boss stagger requires actual basic/skill contacts. A break interrupts an active telegraph, pauses attacks briefly and opens a bounded damage window. A boss gets one advertised enrage phase below half HP. Neither state is an always-on visual. An explicit charged ultimate is earned through real attacks, has its own contact time, consumes charge once and cannot auto-fire.

## Visual progression

Canonical hero/body, swords and equipment unchanged. Pose-authored cape masks split only the rear cloth from the same source texture. With wings equipped, the detached rear cloth folds around its shoulder attachment and the body excludes the original rear cloth. Head, armor, arms, scarf and weapon are untouched. Wings stay behind the body, with reviewed pose-local placement. Without wings, the original body image renders unchanged. Weapon upgrade tiers get a separately rendered bounded blade light/trail, not a baked-in new body/weapon image. Reduced/off VFX remains honoured.

## Social/online direction

Families/guilds, visible cooperative dungeon heroes, legendary titles and arena/PvP are mandatory product pillars. 7.1 accounts/cloud saves/server authority; 7.2 friends/parties/invites/visible players/first real co-op; 7.3 families with ranks/chat/quests/shared progression; 7.4 shared bosses/raids; 7.5 separate PvP balance/seasons/ranks/titles; 7.6+ shared worlds/guild wars/events/endgame. No local simulation is labelled online multiplayer.

Use stable actor/instance/action IDs and explicit command/event boundaries now. Preserve existing single-player domain modules, version new progression data, migrate older saves additively and protect unknown schemas. Future server owns damage/HP/loot/currencies/instance progress/PvP. Client presentation stays independent. Never fabricate friends, guild membership, online presence or leaderboard entries in local UI.
