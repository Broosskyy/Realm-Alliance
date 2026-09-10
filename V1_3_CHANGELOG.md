# REALM ALLIANCE V1.3
## Runtime Visual States + P10/P12 Core Polish

### Monsters
- M001-M004 now resolve runtime Idle/Hit/Defeat textures.
- B001 resolves Idle/Hit/Shield/Defeat textures.
- manual hits briefly swap to Hit art.
- kills visibly swap to Defeat art before reward.
- Mooskönig gets a short Shield/Special visual after intro.

### Village
- each of the four P0 building cards now has its own TextureRect.
- Lv1/Lv2/Lv3 sprite is resolved from the actual saved building level.
- upgrading a building therefore changes both the number and the art slot.

### Reward feel
- new reward pulse asset and animation.
- defeat state precedes reward.
- normal and boss reward hierarchy remain different.

### P10 Level/Unlock
- compact account-level celebration overlay.
- no new permanent menu.
- appears only when the account level actually increases.

### P12 Settings
- simple Settings overlay.
- Sound, Music and Haptics toggles.
- settings persist in SaveGame.
- no developer options.

### Asset contract
All newly added visual placeholders have Masterlist IDs.
