# REALM ALLIANCE V1.50 — Lane Battle V2

- Deepened Lane Battle as a full gameplay pillar instead of adding another disconnected mode.
- Six data-driven Grünhain attack stages with increasing enemy HP and lane pressure.
- Lane Mastery levels 1–5; XP from deployments and victories.
- Permanent Unit-Tech levels 1–4 using existing Gold; increases deployed unit power.
- Dedicated mastery reward claims with preserved lower unclaimed tiers.
- Added `lane-battle-result-v1` with unique battle_id, stage, win state, rewards, Mastery XP and pending presentation.
- Battle result is saved before presentation; restored result does not re-grant rewards.
- Removed automatic return to HOME after battle finish. Result and next-battle action remain in the Lane Battle pillar.
- Added explicit next attack CTA, tech CTA, mastery CTA and richer stage/mastery HUD.
- Global Progression Hub now includes Lane Battle stage, mastery, tech and wins.
- Halloween cross-mode LiveOps accepts Lane Battle victories.
- Added exactly eight 768×768 RGBA isolated, transparent and swap-ready Lane Battle placeholders.
- Save Schema remains V20.
