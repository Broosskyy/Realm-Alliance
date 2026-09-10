# V1.40 Deterministic SPIN Contract QA

1. Every new successful spin receives a unique runtime `result_id`.
2. `reward_id`, `reward_type` and `reward_value` describe the booked reward independently of legacy segment aliases.
3. `outcome_seed` is stored with the result and drives authoritative weighted/variable reward RNG.
4. `visual_seed` is stored and drives transient reel presentation deterministically.
5. `SpinReelPresenter` contains no runtime `randi_range` calls.
6. Three final reel stops and three stable reel stop IDs are stored.
7. `outcomes` records reel index, stop index, stop ID, symbol ID and payline row for all three reels.
8. The center-row payline remains the only P0 payline.
9. Full Shield capacity converts the Shield result to Gold fallback and uses a Gold visual symbol.
10. Reward overlay icon uses `visual_symbol_index`, matching the final payline.
11. Pending spin presentation is saved before animation and acknowledged only when reward overlay closes.
12. Legacy pending payloads are normalized without reward re-grant.
13. Reduced Motion uses the same final result/stops as standard animation.
14. Save Schema remains V20.
15. Real Godot/device runtime verification remains required.
