# V1.61 — Screen Auto-Composition & Existing Asset Integration

- Added `ScreenCompositionService.gd`.
- Reflowed Home/TAP, 3-Reel SPIN and Village with normalized anchors and non-overlapping zones.
- Moved MODI into the persistent bottom navigation; QuickActions is hidden.
- Bottom navigation now uses existing REALM assets for TAP / SPIN / DORF / MODI.
- Home permanently removes duplicate TapPromptArt and hides the old TapUpgradeButton from the core screen.
- Boss progress receives an existing production progress housing.
- SPIN machine/reels/payline/button are composed as one coherent device using existing atlas content.
- Village building labels are rendered separately from building art so runtime status text no longer covers the artwork.
- Fixed a V1.60 `ScreenVisualCalibration._calibrate_overlay_stack` branch indentation bug that prevented Button calibration inside overlay stacks.
- No new invented visual assets were added.
