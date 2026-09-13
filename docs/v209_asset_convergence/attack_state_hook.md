# V2.09 Attack State Hook

## Status

All 17 Grünhain production monsters ship `attack` state crops. **Runtime combat does not display attack states in V2.09.**

## Reason

Source audit found **no monster-attack / player-HP combat pillar** in active TAP flow:

- `MainGame._show_monster_state()` is only invoked with `"hit"` on player TAP.
- Boss flow uses `"shield"` (mapped to attack texture) — not a monster attack cadence.
- No `monster_attack`, player damage, or attack timer systems exist in gameplay code.

## Prepared hook

When a real monster-attack system lands:

1. Call `P0MonsterVisualSystem.texture_for(level, "attack")` during the authored attack window.
2. Gate with `EncounterStatService.attack_state_supported()` once player-HP damage is implemented.
3. Optional per-monster timing can live in encounter `stats.attack_interval` without MainGame hardcodes.

## Do not

- Play decorative attack flashes on every TAP hit.
- Fake attack animation without gameplay consequence.
