# V2.02.1 Visual Runtime Acceptance

**Status:** PASS  
**Date:** 2026-09-10  
**Godot:** 4.7.2-stable · Windows display driver · OpenGL3

## Godot runtime method

Production flow via autoload `VisualRuntimeQa`:

1. `BootFlow.tscn` → guest start → `MainGame.tscn`
2. Real inputs: TAP, SPIN, DORF, MODI, Settings overlay, back navigation
3. Screenshot capture: root viewport `get_texture().get_image()` after `RenderingServer.force_draw()` + frame waits
4. Programmatic validation: resolution, dark/bright pixel ratios, asset node binding

Run command:

```powershell
tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --scene res://V2021VisualRuntimeQaHost.tscn --display-driver windows --rendering-driver opengl3 --audio-driver Dummy
```

## Screenshot evidence

| File | State | Size | Analysis |
|------|-------|------|----------|
| `01_main_1080x2340.png` | Main after boot | 1080×2340 | PASS — full viewport, M001, Grünhain BG, HUD |
| `02_tap_hit_1080x2340.png` | After TAP | 1080×2340 | PASS — HP 90/100, -10 damage |
| `03_defeat_reward_1080x2340.png` | Defeat/reward | 1080×2340 | PASS |
| `04_spin_open_1080x2340.png` | SPIN open | 1080×2340 | PASS — 3-reel machine frame |
| `05_spin_result_1080x2340.png` | SPIN result | 1080×2340 | PASS |
| `06_village_1080x2340.png` | Village | 1080×2340 | PASS — 2×2 building grid |
| `07_modes_1080x2340.png` | MODI hub | 1080×2340 | PASS |
| `08_overlay_1080x2340.png` | Settings | 1080×2340 | PASS — overlay above gameplay |
| `09_return_main_1080x2340.png` | Return main | 1080×2340 | PASS |
| `01_main_1080x2400.png` | Viewport matrix | 1080×2400 | PASS |
| `01_main_1080x1920.png` | Viewport matrix | 1080×1920 | PASS |
| `01_main_1440x3200.png` | Viewport matrix | 1440×3200 | PASS |

## Visual issues found & fixed

| Issue | Fix |
|-------|-----|
| FROSTMARK panel obscuring monster | Hide `RegionProgressPanel` until ≤8 levels from unlock |
| Monster rendered above Settings overlay | Overlay `z_index = 100` |
| P0 TEST debug button visible | Hidden via `MobileLayoutOwner` |
| Village buildings overlapping (440×420 cells) | Grid cells resized to ~400×240 |
| Screenshot pipeline non-functional | `VisualRuntimeQa` autoload + force_draw + headed Godot |

## Asset verification (runtime screenshots)

| Asset | Verified on screenshot |
|-------|------------------------|
| M001 Waldwinzling | YES — main, tap, defeat |
| Grünhain background | YES — all main states |
| Gold/Spin/Shield HUD plates | YES |
| SPIN machine frame | YES — spin open/result |
| Village building art | YES — village screen |

## Viewport matrix

| Profile | Main gameplay | Full flow |
|---------|---------------|-----------|
| 1080×2340 | PASS | PASS (9 states) |
| 1080×2400 | PASS | — |
| 1080×1920 | PASS | — |
| 1440×3200 | PASS | — |

## Remaining minor items (non-blocking)

- Village building label text occasionally clips under art at smallest cell sizes
- Some P1 script strict-type warnings in optional mode directors (non-P0 paths)

## APK

`builds/android/RealmAlliance_V2_02_1_Test.apk` — version 2.02.1 (code 2021)
