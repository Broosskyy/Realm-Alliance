# V1.23R5 — REALM SPIN Real-Device Acceptance Gate

Master basis: REALM ALLIANCE V2.0, chapters 154/169/170.

Test on the actual Android APK in portrait.

1. Open SPIN: within one second, three reels and the large SPIN CTA must be obvious.
2. Test small/standard/tall portrait heights: no clipped reel symbol, payline, jackpot header or CTA.
3. Spin repeatedly: reels animate and stop left → center → right without layout jumps.
4. Final center payline: all three center symbols must match the reward shown/booked.
5. Verify all eight reward families remain distinguishable.
6. Spend last Spin: dedicated No-Spins state appears and closes cleanly.
7. Trigger Jackpot: jackpot feedback appears before the reward overlay.
8. Enable Reduced Motion: no long reel animation; result remains clear.
9. Background/resume during idle and after a completed spin: no duplicate grant.
10. Verify TAP and BUILD navigation still work and Save Schema V20 resumes correctly.

FAIL gate: any mismatch between visible payline and booked reward, clipped CTA/reel, duplicate reward, blocked navigation, or old circular wheel.
