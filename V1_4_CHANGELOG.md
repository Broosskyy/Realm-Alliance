# REALM ALLIANCE SOURCE V1.4
## CORE CLOSURE / MOBILE TEST PREP

### Visible P0 cleanup
- Topbar is now exactly Gold / Spins / Shields + compact Settings.
- Account profile remains non-prominent.
- Bottom navigation is Home / Rad / Dorf.
- Daily, Quests, Heroes, Attack and Defense remain hidden.
- Hidden Hero Auto-DPS is disabled so P1 cannot alter P0 balance.

### Home / Monster
- P0MonsterVisualSystem is authoritative for names and states.
- old three-monster MonsterCatalog naming no longer drives visible Home UI.
- large 660×660 monster tap area remains.
- normal and Boss flow use the same clear interaction.

### Boss closure
- Boss intro logged locally.
- Boss defeat has stronger reward hierarchy.
- B001 defeat grants +2 guaranteed Spins in addition to normal boss reward.
- Boss reward visibly shows the RW001 chest production slot.

### Navigation / transitions
- three P0 navigation icons added.
- compact Settings icon added.
- short shared Core transition overlay added.
- no elaborate screen animation that slows the loop.

### Analytics
Local prototype event logger for:
game_start
first_tap
monster_defeat
wheel_open
wheel_spin
village_open
building_upgrade
boss_start
boss_defeat

### Save
Save version 14.

### Production
Every added placeholder has a concrete V1.4 Masterlist ID.
