# REALM ALLIANCE V1.17 — P0 RC DEVICE RUNBOOK

This build is a P0 Core acceptance candidate under Master V1.4. It is not a P1 content build.

## Required device pass
Test on a small phone, a 1080×1920 reference device, and a tall phone if available.

### Fresh start
- Delete save / use fresh profile.
- Expect 300 Gold, 5 Spins, 0 Shields.
- First monster starts at 100 HP and needs 10 taps at 10 damage.
- Only Home, Rad, Dorf are part of the visible Core.

### First cycle
- Play encounters 1–10 without debug skipping.
- Verify reward exactly once per kill.
- Verify milestone guidance and boss proximity.
- Boss 10 must appear correctly and not leave a stale HP=0 encounter after background/resume.

### Wheel
- Rapid-tap DREHEN.
- Exactly one accepted spin per transaction.
- Background during spin/reward, resume, verify resource state is durable.

### Village
- Upgrade each of the four P0 buildings when affordable.
- Rapid-tap upgrade and Goldmine claim.
- No duplicate charges/rewards.
- Lv1/Lv2/Lv3 state remains valid after restart.

### Resume / recovery
- Background during monster reward.
- Background during wheel reward.
- Background during village upgrade.
- Restart after legacy_zero_hp fixture.
- Restart after corrupt-primary/valid-backup fixture.

### UX
- First action obvious with one hand.
- No precision tap needed.
- No P1 navigation/content visible.
- Reduced Motion and damage-number settings behave correctly.

A P0 Core PASS requires no duplicate rewards, no negative resources, no stuck input lock, no broken save recovery, no skipped encounter, and no visible P1 leakage.
