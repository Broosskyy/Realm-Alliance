# REALM ALLIANCE V1.58 — Full Visual Integration & Calibration

## Master alignment
- Source version advanced to V1.58 / Master V2.1.
- Preserves the V2.1 product rule: **MEHR CONTENT, NICHT MEHR BEDIENUNG.**
- Keeps the binding policy non-destructive: verified art goes live, uncertain mappings stay unforced.

## Runtime visual integration
- Added `ScreenVisualCalibration.gd` for screen-level hierarchy instead of only global font scaling.
- Home/TAP: larger readable monster title/HP/progress and stronger SPIN CTA.
- SPIN: verified `spin_machine_modular_01/asset_06` is now the live three-reel housing.
- SPIN status/jackpot/winline/action sizing calibrated for mobile.
- Village: building grid spacing and building touch surfaces enlarged without inventing new art mappings.
- Feature Hub: grid spacing, button height and explanatory copy layout calibrated.
- Quest screen and modal stacks receive consistent vertical rhythm and wrapping.
- Calibration reapplies after viewport-size changes.

## Production-art binding
- New `runtime_art_bindings_v158.json`.
- Added verified `spin.machine.frame` binding.
- Added normal/boss monster HP-frame bindings from the existing Monster/Boss HUD kit.
- `ProductionUiBinder` now supports transparent ProgressBar backgrounds so production HP art remains visible behind runtime fill.

## Player-facing copy cleanup
- Monster `HP` display changed to `LEBEN`.
- `AFK` reward message changed to `OFFLINE`.
- Social profile `LV.` changed to `STUFE`.
- Shop no longer exposes internal product type / price-tier codes.
- Shop status is `SHOP-VORSCHAU` rather than `KATALOG-VORSCHAU`.
- Disabled ranking claim no longer exposes validation/backend language; it reads `NOCH NICHT VERFÜGBAR`.
- Initial TSCN labels were calibrated too, preventing technical/old wording from flashing before runtime refresh.

## Intentionally not forced
- No guessed Goldmine visual mapping.
- No fake multi-level Village evolution from unrelated buildings.
- No unverified Monster ID reassignment.
- No return to the deprecated 8-segment wheel.
