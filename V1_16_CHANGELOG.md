# REALM ALLIANCE SOURCE V1.16
## P0 BALANCE & SESSION PACING — Master V1.4

No new assets. No P1. No new gameplay system.

### Master values intentionally preserved
- Monster Lv1 HP = 100
- HP growth = 1.085
- Boss HP multiplier = 2.4
- Wheel weights = 22/18/10/20/10/8/7/5
- Village prototype costs remain exactly Master V1.4:
  Rathaus 200/600, Goldmine 150/450, Schmiede 180/550, Glückstempel 180/550.

### Calibrated starting economy
- Starting Gold: 1000 -> 300
- Starting Spins: 50 -> 5

Reason: 1000 Gold allowed nearly the complete first village upgrade layer immediately, while 50 starting Spins could flood the early economy before the Monster -> Reward -> Wheel -> Village loop was learned. The new values still expose both Wheel and Village immediately, but preserve meaningful early choices.

### QA
A deterministic pacing simulator now checks Master-locked values, first-monster taps, Boss 10 tap pressure, starting upgrade affordability, Wheel weights and expected reward value.
