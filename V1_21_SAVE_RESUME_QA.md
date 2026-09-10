# V1.21 SAVE / RESUME QA

Real-device acceptance:
- Fresh install -> load source `fresh`.
- Normal restart -> load source `primary`.
- Corrupt primary + valid backup -> load source `backup`, state restored, clean primary recreated.
- Logically invalid primary (e.g. negative Gold) + valid backup -> same recovery behavior.
- Legacy HP=0 fixture -> encounter advances exactly once with no second reward.
- Background / pause / focus-out during Home, Wheel reward and Village upgrade -> restart must preserve committed state.
- Offline Goldmine time must never become negative if the device clock moves backwards.
- Release build must not expose debug fixture controls.

Stop the P0 release candidate if any recovery path loses progression, duplicates rewards, creates negative resources, or repeatedly boots from backup after a successful recovery.
