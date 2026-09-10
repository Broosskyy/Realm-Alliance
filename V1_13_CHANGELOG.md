# REALM ALLIANCE SOURCE V1.13
## TECHNICAL / CORE POLISH — Master V1.4

No asset integration. No P1 feature enablement.

- monster kill is now one durable transaction: reward -> boss extras -> advance next encounter -> save
- defeat art stays pinned to the defeated encounter even though the next encounter is already persisted
- Continue no longer advances the monster a second time
- V1.12 HP=0 rewarded save states are repaired on load without granting another reward
- Save schema bumped to V19 for the migration/hardening pass
- WheelSystem has an internal transaction guard
- wheel UI locks before mutation to block same-frame double spin
- village upgrades and Goldmine claims have internal transaction guards
- transaction state is saved before cosmetic signals/animations
- transient reset restores wheel/monster transforms
- Core runtime contract now checks monster HP/level invariants
- test harness includes legacy_zero_hp migration fixture
