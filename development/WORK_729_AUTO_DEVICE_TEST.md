# REALM ALLIANCE 729 - Android 728 → 729 automatic update acceptance

Release 729 deliberately changes only version and test metadata from 728. It preserves saves, profiles, equipment, offline play, PNG and JSON content, app package and original signing identity.

**Device test:** Install signed 728 over existing 720 (without uninstall). On next launcher start, 728 reads the signed 729 test manifest, triggers the separate HTTPRequest automatically, displays accurate MiB and percentage, validates file bytes/SHA-256, then requests Android OS installation confirmation. Android confirmation is mandatory and not bypassed. On relaunch of 729 verify gameplay/save state and 'Spielinhalte aktuell'.

Do not claim real Android device OTA succeeded until screenshot/feedback confirms it. CI success verifies source/tests/build/release/manifest only.
