# V2.01 Device QA

**Device reference:** 1080×2340 portrait (emulator Pixel 6)  
**Build:** `build/android/RealmAlliance_V2_01_Test.apk`  
**Godot:** 4.7.2 headless compile PASS

## Static verification

| Check | Result |
|---|---|
| Script compile (headless 3s) | PASS |
| APK export debug signed | PASS |
| Layout owner consolidation | PASS |
| Greenvale View_ClashDorf fix | PASS |
| Asset registry validate (runtime) | PASS (warnings only for known gaps) |

## Visual verification (emulator screenshots)

Screens under `artifacts/v2.01-device-recovery/`:

| Screen | File | Visual result | Notes |
|---|---|---|---|
| TAP | 01_tap_auto.png | **PARTIAL PASS** | Monster/background/HUD present; QuickActions row still visible on capture — re-test after deferred layout |
| SPIN | 03_spin_view.png | **FAIL (nav)** | Nav tap did not switch view in automation — manual verify required |
| DORF | 04_dorf_view.png | **NOT CAPTURED** | Automation landed on TAP — manual verify required |
| MODI | 05_modi_hub.png | captured | Manual review recommended |
| Heroes | 06_heroes_via_modi.png | captured | Mastery icons expected; portraits gap documented |

## Flow checklist (manual required on device)

- [ ] Boot → Welcome → Guest → TAP
- [ ] Monster tap → damage feedback
- [ ] SPIN 3-reel alignment + payline
- [ ] DORF without green circle dominant
- [ ] MODI hub thumb-sized cards
- [ ] Puzzle 3×3 readable
- [ ] TD tower roles visible
- [ ] Lane battlefield spacing
- [ ] Heroes readable (gap state for portraits)
- [ ] Save → restart → resume

## Honest overall status

**NOT full PASS** — architecture and critical bindings fixed; automated screenshots incomplete for SPIN/DORF/MODI navigation. Install `RealmAlliance_V2_01_Test.apk` on 1080×2340 hardware and complete manual flow above.

## Git

No repository — commit SHA N/A.
