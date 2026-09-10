# V1.41 Journey / Puzzle / Hero QA

1. A Journey roll consumes exactly one die before presentation.
2. Every successful roll stores `roll_id`, `roll_seed` and `config_version`.
3. Node reward is granted once before the pending result is saved.
4. `pending_result` is included in `DiceJourneySystem.export_save_data()`.
5. Resume presentation reads the stored result and does not call `roll()`.
6. Journey presentation acknowledgement clears only presentation state and does not reverse rewards.
7. Dice RNG is scoped to a per-roll `RandomNumberGenerator`.
8. Existing Journey board size, node rewards, starting dice, max dice and portal reward remain unchanged.
9. Puzzle attempts reset when the UTC day key changes.
10. Puzzle daily day key persists in Save V20.
11. Hero card tap is selection-only.
12. Hero upgrade uses a dedicated explicit CTA.
13. Selected hero persists and drives equipment upgrade controls.
14. Hero upgrade CTA disables when locked, unaffordable or at level cap.
15. Save Schema remains V20.
16. Real Godot/Android runtime verification is still required.
