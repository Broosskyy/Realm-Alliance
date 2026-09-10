# V1.68 CHANGELOG — Dynamic UI State Hardening

- Fixed medium-confidence semantic loading for the existing standard shop card and progression bar.
- Shop visual strip now follows the actual PurchaseService catalog instead of being a fixed demo strip.
- AFK reward visuals now follow pending reward state and only show the bonus slot when the progression bonus is actually applicable.
- Progression node visuals now derive state from real ProgressionOverviewSystem tracks instead of always showing one of every state.
- Removed SpinButton from the static screen contract. Spin ready/disabled art remains exclusively runtime-owned by `_apply_spin_button_art_v156()`.
- Added explicit policy that medium-confidence assets require opt-in.
- No new artwork and no fake missing assets.
