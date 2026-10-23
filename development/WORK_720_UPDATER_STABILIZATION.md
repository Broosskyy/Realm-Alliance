# REALM ALLIANCE 720 - updater stabilization
The 718→719 phone test reported "Download unterbrochen" while attempting a 131,748,445-byte APK.
Root cause candidate verified in source: the shared HTTPRequest had timeout=8 seconds, suitable for metadata but unsuitable for 132 MB download.
Godot recommends timeout=0.0 for large downloads (see docs.godotengine.org classes/class_httprequest.html).

Change set:
- Separate short metadata timeout (8 s) and unlimited APK transfer timeout (0 s). Add threaded request for large file; preserve SHA256 and Android native package/certificate validation. Raise GitHub redirect limit to 12.
- Human-readable HTTP status/result messages and visible download size in MiB.
- Extend FileProvider to app-specific external files directory and native path allowlist to match Godot's possible user:// location. Do not allow arbitrary external storage paths.
- CI unit tests include timeout regression.
- Release 720 is published as a prerelease, **but does not auto-promote OTA manifest**: users on buggy 718 must manually install 720 over the old app once; 719 remains the last manifest version. After 720 installed, release 721 to test complete OTA.
- No new character progression, saves, or art changes.
- No gameplay or Android device testing is inferred from CI. The real device test is still required.
