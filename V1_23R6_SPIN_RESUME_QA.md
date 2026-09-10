# V1.23R6 SPIN Resume / Duplicate-Grant QA

1. Note Gold/Spins/Shields before a SPIN.
2. Start SPIN and force-close after reward booking but before closing reward overlay.
3. Relaunch.
4. Expected: SPIN screen opens with exact persisted reel result and reward overlay.
5. Expected: wallet/resource values equal the already-booked result exactly once.
6. Close reward overlay.
7. Force-close/relaunch again.
8. Expected: no reward overlay is restored and no reward is booked again.
9. Repeat for Gold, Shield, Bonus Spins and Jackpot.
10. Repeat with Reduced Motion enabled.

Hard fail: any duplicate reward, changed visible reel result, missing pending result after process return, or Save Schema change away from V20.
