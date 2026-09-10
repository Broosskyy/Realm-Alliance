# V1.53 Village / BUILD V2 QA

Static acceptance:
- Four existing Grünhain buildings preserved.
- Town Hall gates target levels of Mine, Forge and Luck Temple.
- Goldmine remains time/offline based.
- Forge has six permanent crafts, two craft slots per Forge building level.
- Forge crafts spend existing Gold and increase persisted Tap damage.
- Luck Temple has one UTC-daily blessing and uses existing level-based Spin bonus.
- Village Growth is progression XP, not a new spendable currency.
- Village Growth rewards use existing Gold/Spins/Realm Keys.
- Building upgrades have unique upgrade_id + pending presentation.
- Save happens before upgrade presentation; pending result can restore without a second Gold charge.
- Legacy hidden TownHallButton is no longer an active runtime upgrade path.
- Village function actions feed cross-pillar objective activity.
- Exactly 8 transparent isolated 768×768 placeholders.
- Save V20 unchanged.

Pending:
- Real Godot executable/parser QA.
- Physical Android layout/touch QA.
- Final Recraft village/building/function art.
- Later expansion beyond building level 3 should be introduced data-first, not by duplicating scene logic.
