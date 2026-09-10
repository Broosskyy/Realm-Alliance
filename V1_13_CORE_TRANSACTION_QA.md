# V1.13 CORE TRANSACTION QA

## Monster kill / resume
1. Kill a normal monster.
2. Background/close app during defeat or reward presentation.
3. Restart.
4. Expected: reward exists exactly once and next encounter is active with HP > 0.
5. Continue after reward must never skip an extra monster.

## Legacy V1.12 migration
Use `legacy_zero_hp` profile, save, restart.
Expected: loader advances once to the next encounter, grants no reward, persists repaired state.

## Wheel
Rapidly tap SPIN.
Expected: exactly one spin is consumed and exactly one reward is granted per accepted animation.
Background during animation and restart: committed reward/spin count remains.

## Village
Rapidly tap VERBESSERN or Goldmine ABHOLEN.
Expected: only one successful mutation per available transaction.

## Boss
Kill encounter 10 and background during defeat/reward.
Expected: boss Gold/XP and +2 Spins exactly once, next encounter persisted.

## Gate
Do not enable Daily, Quests, Heroes, Attack, Defense, Events or Shop.
This remains P0 Core hardening under Master V1.4.
