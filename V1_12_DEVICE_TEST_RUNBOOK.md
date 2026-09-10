# V1.12 DEVICE TEST RUNBOOK

Use a DEBUG Android build.

1. Fresh Start:
   - select FRISCHER START
   - close TEST
   - verify first monster takes about 10 taps
   - verify reward -> Home -> Wheel CTA

2. 5/10:
   - select 5 / 10
   - defeat monster
   - verify milestone feedback

3. Boss:
   - select BOSS 10 / 10
   - verify Mooskönig intro, HP, defeat and reward

4. Wheel:
   - select WHEEL · 3 SPINS
   - spin exactly three times
   - verify fourth attempt is blocked without false reward

5. Village:
   - select DORF TEST
   - verify all four building modals
   - verify Upgrade works
   - verify Goldmine claim

6. Return:
   - select RETURN TEST
   - close app completely
   - reopen and verify monster HP/resources/village

7. Save Recovery:
   - select SAVE RECOVERY FIXTURE
   - close app
   - reopen
   - verify backup recovery warning and valid state

8. Low Resource:
   - select 0 SPINS / 20 GOLD
   - verify Wheel empty state, insufficient-Gold upgrade state, full-shield fallback.

Do not enable P1 after static PASS. P1 still requires real Core acceptance on device.
