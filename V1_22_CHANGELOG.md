# REALM ALLIANCE SOURCE V1.22

## Master V1.6 Realignment Pass

Base: V1.21 Save / Resume Lifecycle Hardening + P0 Art Integration 01.

### Changed
- Source metadata aligned to V1.22 / Master Concept V1.6 / build 32.
- Fresh-account starting Spins changed from 5 to 10. Existing V1.21 saves retain their saved Spin balance.
- Wheel runtime now loads `data/wheel_p0_v1_6.json`.
- V1.6 weights: 24 / 18 / 10 / 14 / 8 / 12 / 9 / 5.
- Segment semantics: Gold S / Gold M / Gold L / Shield / Attack / Bonus Spins / Puzzle Bonus / Jackpot.
- Attack remains a safe Gold fallback until Lane Battle is enabled.
- Puzzle Bonus remains a safe Gold fallback until Puzzle runtime is enabled.
- Jackpot uses the existing special reward path until chest presentation is produced.
- Added an explicit V1.6 runtime/product contract reserving Puzzle, Tower Defense and Lane Battle without enabling hidden P1/P2 processing.

### Preserved
- V1.21 save schema V20 and all save/resume lifecycle hardening.
- Backup recovery and primary re-promotion.
- HP=0 legacy repair without duplicate rewards.
- P1 runtime isolation.
- Accepted Grünhain/M001/UI art integration.

### Art production gate
The next production block is the real V1.6 SPIN art set. Current wheel graphics remain placeholders until that set is generated and approved.
