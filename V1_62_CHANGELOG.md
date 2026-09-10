# V1.62 — FULL UI ASSET CONVERGENCE

- Expanded semantic bindings from the small V1.61 core set to the existing full UI library.
- Added canonical button families: primary, positive, secondary, neutral, danger, reward.
- Added canonical panel families, frames/slots, rarity slots, utility controls, navigation, quest, inventory, village and combat roles.
- Expanded screen contracts across Feature Hub, Settings, Account, Social, Support, LiveOps, Heroes, Lane, Defense, reward/upgrade modals and the existing Quest/Shop/AFK/Progression/Ranking screens.
- Corrected bottom-navigation node IDs to actual scene names (`Btn_Tap`, `Btn_Rad`, `Btn_Dorf`).
- Fixed the V1.61 overlay calibration branch bug where Buttons inside VBox overlays were not reached because the `elif` was nested under the Label branch.
- Runtime labels remain dynamic; no baked UI text introduced.
- Dynamic monster HP / monster state / spin state visuals remain runtime-owned and are not force-overwritten.
