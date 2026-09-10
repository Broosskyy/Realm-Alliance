# V2.01 Mobile Layout Audit

## Reference viewports

| Profile | Detection | Target devices |
|---|---|---|
| small | w≤760 or h≤1650 | ~720×1600 |
| standard | default | 1080×1920 |
| tall | aspect≥2.05 | **1080×2340**, 1440×3200 |

## Single layout owner

All geometry flows through `MobileLayoutOwner.gd` via `ResponsiveLayout.apply()`.

### Property ownership matrix

| Node group | Owner | Properties |
|---|---|---|
| Safe | MobileLayoutOwner | margin L/R/T/B |
| TopBar + pills | MobileLayoutOwner | min size, font sizes |
| BottomMenu | MobileLayoutOwner | height, separation, labels, icons |
| View_TapHero | MobileLayoutOwner | anchor rects, font sizes |
| View_CoinMaster reels | MobileLayoutOwner | position/size (view-relative) |
| View_ClashDorf | MobileLayoutOwner | ground texture, grid, hide ambient |
| Mode views | MobileLayoutOwner | puzzle/hero/lane/td rects |
| FeatureHubOverlay | MobileLayoutOwner | modal box + card heights |
| All overlays | MobileLayoutOwner | `_center_box` sizing |
| Visual styling | ScreenUiAssemblyService | backdrops, icons only |
| Copy/state | RuntimeGuidanceService | text only |

## Disabled conflicting layers

No longer run on boot/resize: V194–V197 apply(), V198/V199 touch passes, FinalAlpha geometry, ScreenComposition geometry, ScreenVisualCalibration, UiPolishService, ResponsiveRuntimePolish.

## Touch target targets (V2.01)

| Control | Min height (dp-equivalent px) |
|---|---|
| Bottom nav buttons | 86–102 |
| Primary CTA (spin/tap) | 96–108 |
| MODI hub cards | 108–132 |
| Overlay buttons | ≥72 |

## Known follow-ups

- Deferred `_apply_mobile_runtime_polish()` ensures valid view sizes before reel/village layout.
- MODI reparent to BottomMenu handled in MobileLayoutOwner (previously ScreenCompositionService).
- QuickActions shortcut row forced hidden in MobileLayoutOwner.
