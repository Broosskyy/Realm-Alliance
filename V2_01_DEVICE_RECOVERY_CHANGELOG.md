# V2.01 Device Recovery Changelog

## Root causes addressed

1. **12+ competing layout passes** on boot and every resize (`ResponsiveLayout`, `ScreenCompositionService`, `ScreenVisualCalibration`, `ResponsiveRuntimePolish`, V194–V200) overwrote the same nodes with conflicting offsets, anchors, and min sizes.
2. **1080×1920 design viewport** on 1080×2340 devices triggered `PROFILE_TALL` without a single owner for tall-safe margins and typography.
3. **DORF green circle**: `V000_village_ground.png` placeholder + oversized `VillageAmbient` tree dominated the village view.
4. **Greenvale props never bound**: `GreenvaleWorldVisualDirectorV193` and `GreenvaleWorldDecorationV191` searched `View_Dorf` instead of `View_ClashDorf`.
5. **SPIN reel geometry**: absolute 1080p pixel coords in `.tscn` fought runtime repositioning from five different scripts.

## Consolidation (V2.01)

| Removed from resize chain | Replaced by |
|---|---|
| `UiPolishService.apply()` | `ScreenUiAssemblyService` (visual only) |
| `ScreenVisualCalibration.apply()` | `MobileLayoutOwner` typography |
| `ResponsiveRuntimePolish.apply()` | `MobileLayoutOwner` scroll/overlay mins |
| `SpinVillageResponsivePolishV194.apply()` | `MobileLayoutOwner` + runtime feedback kept |
| `HomeNavigationRewardPolishV195.apply()` | `MobileLayoutOwner` + transitions kept |
| `ModeGameplayPolishV196.apply()` | `MobileLayoutOwner` mode view tables |
| `FullUiConvergenceV197.apply()` | removed |
| `CoreLoopProductionReadinessV198.apply()` touch pass | `RuntimeGuidanceService.refresh()` |
| `PreAlphaClosureV199.apply()` | merged into `RuntimeGuidanceService` |
| `FinalAlphaConvergenceV200.apply()` geometry | `MobileLayoutOwner` |
| `ScreenCompositionService` home/spin/village | `MobileLayoutOwner` |

**New files:** `MobileLayoutOwner.gd`, `RuntimeGuidanceService.gd`

**Runtime feedback preserved:** V194 spin/village tweens, V195 transitions/rewards, V196 puzzle/hero/lane feedback.

## Screen reconstructions

- **TAP**: anchor-based hierarchy, larger HUD pills/fonts, monster focus rect, debug synergy labels hidden, region panel integrated.
- **SPIN**: view-relative 3-reel layout, machine frame sizing, payline alignment, `WheelTitle` → `REALM SPIN`.
- **DORF**: production `BG001` ground, ambient tree hidden, building grid enlarged, green select glow hidden, V193 props enabled.
- **MODI**: larger hub cards, viewport-relative overlay sizing.
- **Puzzle / Heroes / Lane / TD**: profile-based cell/card/button sizing in `MobileLayoutOwner`.
- **Overlays**: unified `_fit_modal` sizing + minimum label/button typography.

## Asset bindings fixed

- Village ground → `BG001_gruenhain_home_v11.png` (production world background)
- Greenvale decor → `View_ClashDorf` path corrected in V191/V193
- Spin frame/payline → existing production registry paths (unchanged authority)

## Remaining gaps (honest)

- Hero portrait PNGs intentionally missing (`hero_*_portrait_placeholder`) — mastery icons used instead.
- Dedicated village ground production plate still flagged `village_ground_remains_review_not_faked` in asset rules; BG001 used as semantic substitute.
- `preflight.py` not run (Python unavailable in shell PATH).

## Build

- Godot 4.7.2 headless compile: **PASS**
- APK: `build/android/RealmAlliance_V2_01_Test.apk`

## Git

No git repository present in project folder — commit/push not performed.
