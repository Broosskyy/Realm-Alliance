# REALM ALLIANCE SOURCE V1.21
## P0 SAVE / RESUME LIFECYCLE HARDENING — Master V1.4

No new assets. No P1 enabled. No gameplay expansion.

- Save schema bumped from V19 to V20 for lifecycle metadata.
- Primary saves are now structurally validated before acceptance.
- Valid JSON with impossible P0 values (negative Gold/Spins, invalid Shields, invalid monster bounds) is rejected.
- A valid backup is used when the primary is malformed OR logically invalid.
- Successful backup recovery now recreates a clean primary save while preserving the backup until the atomic write succeeds.
- Legacy HP=0 repair remains supported and does not duplicate rewards.
- Save sequence, load source and last-save result are exposed for debug diagnostics.
- Added a debug fixture for logically invalid primary + valid backup.
- Boot diagnostics now include save load source/recovery/sequence.
- Build metadata updated to V1.21 / build 31.
