# REALM ALLIANCE V2.02 — Runtime Recovery Changelog

## Status: PASS (runtime acceptance)

Milestone focus: **runtime recovery**, not new features.

## Runtime fixes

| Area | Fix |
|------|-----|
| **Viewport / portrait** | Reference viewport `1080×2340`, `stretch/aspect=expand` for full-screen mobile scaling |
| **GameplayVfxService** | Preload wiring in `MainGame.gd`, `TapCombatVisualDirectorV193.gd`, `RewardProgressionVisualDirectorV193.gd` — fixes compile/runtime VFX calls |
| **Navigation** | Instant view switch when `reduced_motion` enabled; transition overlay ignores input when hidden |
| **TAP input** | Monster button z-index + explicit `MOUSE_FILTER_STOP`; layout owner hides legacy QuickActions row |
| **UI layers** | QuickActions hidden + non-interactive; MODI remains in bottom nav via `MobileLayoutOwner` |
| **Core transition** | `CoreTransitionP0` uses `MOUSE_FILTER_IGNORE` when inactive |

## Asset integration (runtime-verified)

| Slot | Production asset | Action |
|------|------------------|--------|
| M001 Waldwinzling | `assets/monsters/greenvale/states/M001_*.png` | BEHALTEN — idle/hit/defeat via `P0MonsterVisualSystem` |
| TAP background | `BG001_gruenhain_home_v11.png` | BEHALTEN |
| HUD pills | `UI015/016/017_resource_*_pill.png` | KORREKT BINDEN via TopBar |
| SPIN machine | Production atlas `spin.machine.frame` | KORREKT BINDEN via `ProductionUiBinder` |
| Village buildings | V153 production village art | BEHALTEN |

## Gameplay tests executed (automated runtime)

- Boot → MainGame with fresh profile
- TAP → HP decreased (M001)
- Navigation → TAP / SPIN / DORF / MODI hub / back
- SPIN → reel flow started
- Village → `View_ClashDorf` opened
- Save/resume → gold persisted across reload
- Viewports: 1080×2340, 1080×2400, 1080×1920

Report: `docs/v202_runtime_qa/acceptance_report.json`

Run acceptance:
```powershell
tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --scene res://V202RuntimeAcceptanceHost.tscn --display-driver windows --audio-driver Dummy
```

## APK (release gate passed)

- `builds/android/RealmAlliance_V2_02_Test.apk`
- Package: `com.realmalliance.prototype`
- versionName `2.02.0`, versionCode `202`

## Known issues

- `ScreenUiAssemblyService.refresh_village_loop_state` logs errors if dependent script reload order fails during hot test cycles — function exists; clean boot OK
- Automated viewport screenshots require full display pipeline; use device screenshots for final visual sign-off
- Puzzle save array typing warning on load (non-blocking)

## Next

1. Manual device QA on 1080×2340 with APK install
2. Visual polish pass on SPIN jackpot / boss defeat overlays
3. GitHub Release asset upload for V2.02 APK (file >100 MB)
