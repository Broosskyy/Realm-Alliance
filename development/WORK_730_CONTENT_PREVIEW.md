# REALM ALLIANCE 730 – Content-first test branch

Base: signed 729 source. Existing distribution/realm-715-test and main are unchanged.

New validated PNG armor-art and JSON armor-catalog packages can update independently of an APK *after a 730 install*.
In-game equipment/costume screen displays remote armor as a clearly non-equipable preview, no change to save data or stats.
Production combat can show a downloaded world ornament.
All remote URLs are pinned to distribution/realm-730-test and checked against declared SHA256, size and typed schemas. No remote code.
A v1-v2 catalog revision is regression-tested under the same binary.
This is a bounded preview, not yet a general-purpose modular equipment/item/monster data runtime.

No OTA promotion of 730 to existing 729 phones before on-device acceptance.
