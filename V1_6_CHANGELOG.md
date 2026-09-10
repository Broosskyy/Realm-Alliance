# REALM ALLIANCE SOURCE V1.6
## P0.8 TEST / STABILITY PASS — Master V1.4

- removed hidden Daily auto-reward call from P0 startup
- hidden Quest progress no longer runs while Quests are disabled
- hidden Unlock refresh gated behind future P1 flags
- Audio music initialization waits until saved Settings are loaded
- SettingsService indentation/typing normalized
- Wheel no longer plays spin feedback when no spin is available
- Wheel/Reward/Monster/Upgrade flows use a shared input lock against double taps
- navigation refuses transitions while a blocking Core overlay is open
- transient overlays/tweens are reset on scene startup
- save on app pause/close
- safer temporary save-file write before replacement
- Boss reward string normalized to escaped line breaks
- added P0RuntimeContract for local engine validation
- Save version 16
- no new gameplay feature
